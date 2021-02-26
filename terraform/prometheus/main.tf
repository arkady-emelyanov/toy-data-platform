locals {
  module_name = "prometheus"
  module_labels = {
    app = local.module_name
  }

  data_path = "/data"
  conf_path = "/conf"

  endpoint = "${local.module_name}.${var.namespace}.svc.cluster.local:${var.http_port}"
  prometheus_yaml = templatefile("${path.module}/configs/prometheus.yaml", {
    http_port = var.http_port
  })
  config_hash = sha1(local.prometheus_yaml)
}

resource "kubernetes_config_map" "config" {
  metadata {
    name = local.module_name
    namespace = var.namespace
    labels = local.module_labels
  }

  data = {
    "prometheus.yaml" = local.prometheus_yaml
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
    service_name = local.module_name
    replicas = 1
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
          command = [
            "/bin/prometheus",
            "--web.listen-address=:${var.http_port}",
            "--config.file=${local.conf_path}/prometheus.yaml",
            "--storage.tsdb.path=${local.data_path}",
            "--storage.tsdb.retention.time=2d",
          ]

          port {
            container_port = var.http_port
            name = "http"
          }

          env {
            name = "__CONFIG_HASH"
            value = local.config_hash
          }

          liveness_probe {
            http_get {
              path = "/-/healthy"
              port = "http"
            }
          }
          readiness_probe {
            http_get {
              path = "/-/ready"
              port = "http"
            }
          }

          volume_mount {
            mount_path = local.data_path
            name = "prometheus-storage"
          }
          volume_mount {
            mount_path = local.conf_path
            name = "prometheus-config"
          }
        }

        volume {
          name = "prometheus-config"
          config_map {
            name = kubernetes_config_map.config.metadata[0].name
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "prometheus-storage"
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
