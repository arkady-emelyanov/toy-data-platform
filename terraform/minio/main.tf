locals {
  module_name = "minio"
  module_labels = {
    app = local.module_name
  }

  bucket = "platform"
  endpoint = "${local.module_name}.${var.namespace}.svc.cluster.local:${var.http_port}"
  alias = "http://${random_string.access_key.result}:${random_string.secret_key.result}@${local.endpoint}"
}

resource "random_string" "access_key" {
  length = 20
  upper = true
  min_upper = 20
  special = false
}

resource "random_string" "secret_key" {
  length = 20
  upper = true
  min_upper = 20
  special = false
}

resource "kubernetes_config_map" "environment" {
  metadata {
    name = local.module_name
    namespace = var.namespace
    labels = local.module_labels
  }

  data = {
    MINIO_ACCESS_KEY = random_string.access_key.result
    MINIO_SECRET_KEY = random_string.secret_key.result
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

resource "kubernetes_persistent_volume_claim" "pvc" {
  wait_until_bound = true

  metadata {
    name = local.module_name
    namespace = var.namespace
    labels = local.module_labels
  }
  spec {
    storage_class_name = "standard"
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "250Mi"
      }
    }
  }
}

resource "kubernetes_deployment" "deployment" {
  wait_for_rollout = true

  metadata {
    name = local.module_name
    namespace = var.namespace
    labels = local.module_labels
  }

  spec {
    replicas = 1
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
          command = [
            "/usr/bin/docker-entrypoint.sh",
            "server", "--address", ":${var.http_port}",
            "/data"
          ]

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
            mount_path = "/data"
            name = "minio-storage"
          }
        }

        volume {
          name = "minio-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_job" "create_bucket" {
  depends_on = [kubernetes_deployment.deployment]
  wait_for_completion = true

  metadata {
    name = local.module_name
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
            value = local.alias
          }
        }
      }
    }
  }
}
