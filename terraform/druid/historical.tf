#
# Druid Historical
# @see: https://druid.apache.org/docs/latest/design/historical.html
#
locals {
  historical_client_port = 8080
  historical_labels = merge(local.module_labels, {
    component = "historical"
  })
}

resource "kubernetes_stateful_set" "historical" {
  depends_on = [kubernetes_deployment.coordinator]
  wait_for_rollout = true

  metadata {
    name = "${local.module_name}-historical"
    namespace = var.namespace
    labels = local.historical_labels
  }
  spec {
    service_name = "${local.module_name}-historical"
    replicas = 1

    selector {
      match_labels = local.historical_labels
    }
    template {
      metadata {
        labels = local.historical_labels
      }
      spec {
        container {
          name = "server"
          image_pull_policy = "IfNotPresent"
          image = var.server_image
          args = ["historical"]

          env_from {
            config_map_ref {
              name = kubernetes_config_map.config.metadata[0].name
            }
          }
          env {
            name = "druid_plaintextPort"
            value = local.historical_client_port
          }
          port {
            container_port = local.historical_client_port
            name = "client"
          }

          volume_mount {
            mount_path = "/opt/druid/var"
            name = "${local.module_name}-historical"
          }

          readiness_probe {
            http_get {
              path = "/status/health"
              port = "client"
            }
          }
          liveness_probe {
            period_seconds = 30
            http_get {
              path = "/status/health"
              port = "client"
            }
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "${local.module_name}-historical"
        namespace = var.namespace
        labels = local.historical_labels
      }
      spec {
        storage_class_name = var.storage_class
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = var.historical_disk_size
          }
        }
      }
    }

  }
}
