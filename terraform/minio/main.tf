#
# Module installs MiniO as StatefulSet
# Bucket platform will be also created
# Docker image source: https://github.com/minio/minio
#
locals {
  module_name = "minio"
  module_labels = {
    app = local.module_name
  }

  data_path = "/data"
  bucket = "platform"

  endpoint = "${local.module_name}.${var.namespace}.svc.cluster.local:${var.http_port}"
  username = random_string.access_key.result
  password = random_string.secret_key.result

  endpoint_alias = "http://${local.username}:${local.password}@${local.endpoint}"
}

resource "random_string" "access_key" {
  length = 10
  min_upper = 10
  upper = true
  special = false
}

resource "random_string" "secret_key" {
  length = 20
  min_upper = 20
  upper = true
  special = false
}

resource "kubernetes_config_map" "environment" {
  metadata {
    name = local.module_name
    namespace = var.namespace
    labels = local.module_labels
  }

  data = {
    MINIO_ACCESS_KEY = local.username
    MINIO_SECRET_KEY = local.password
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name = local.module_name
    namespace = var.namespace
    labels = local.module_labels
  }
  spec {
    selector = local.module_labels
    port {
      port = var.http_port
      target_port = var.http_port
      name = "http"
    }
  }
}

resource "kubernetes_stateful_set" "deployment" {
  wait_for_rollout = true

  metadata {
    name = local.module_name
    namespace = var.namespace
    labels = local.module_labels
  }

  spec {
    replicas = 1
    service_name = local.module_name
    pod_management_policy = "OrderedReady"
    update_strategy {
      type = "RollingUpdate"
    }

    selector {
      match_labels = local.module_labels
    }

    template {
      metadata {
        labels = local.module_labels
      }
      spec {
        container {
          name = "server"
          image_pull_policy = "IfNotPresent"
          image = var.server_image
          args = ["server", "--address", ":${var.http_port}", local.data_path]

          port {
            container_port = var.http_port
            name = "http"
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.environment.metadata[0].name
            }
          }

          liveness_probe {
            http_get {
              path = "/minio/health/live"
              port = "http"
            }
          }
          readiness_probe {
            http_get {
              path = "/minio/health/live"
              port = "http"
            }
          }

          volume_mount {
            mount_path = local.data_path
            name = "minio-storage"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "minio-storage"
        namespace = var.namespace
        labels = local.module_labels
      }
      spec {
        storage_class_name = var.storage_class
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = var.disk_size
          }
        }
      }
    }

  }
}

resource "kubernetes_job" "create_bucket" {
  depends_on = [kubernetes_stateful_set.deployment]
  wait_for_completion = true

  metadata {
    name = "${local.module_name}-create-bucket"
    namespace = var.namespace
    labels = local.module_labels
  }
  spec {
    template {
      metadata {
        labels = local.module_labels
      }
      spec {
        restart_policy = "Never"
        container {
          name = "job"
          image_pull_policy = "IfNotPresent"
          image = var.command_image
          command = ["mc", "mb", "--ignore-existing", "platform/${local.bucket}"]

          env {
            name = "MC_HOST_platform"
            value = local.endpoint_alias
          }
        }
      }
    }
  }
}
