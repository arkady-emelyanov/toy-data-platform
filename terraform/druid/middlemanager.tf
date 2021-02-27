#
# Druid MiddleManager
# @see: https://druid.apache.org/docs/latest/design/middlemanager.html
#
locals {
  middlemanager_client_port = 8084
  middlemanager_labels = merge(local.module_labels, {
    component = "middlemanager"
  })
}

resource "kubernetes_stateful_set" "middle_manager" {
  depends_on = [kubernetes_deployment.coordinator]
  wait_for_rollout = true

  metadata {
    name = "${local.module_name}-middlemanager"
    namespace = var.namespace
    labels = local.middlemanager_labels
  }
  spec {
    service_name = "${local.module_name}-middlemanager"
    replicas = 1

    selector {
      match_labels = local.middlemanager_labels
    }

    template {
      metadata {
        labels = local.middlemanager_labels
      }
      spec {
        container {
          name = "server"
          image_pull_policy = "IfNotPresent"
          image = var.server_image
          args = ["middleManager"]

          env_from {
            config_map_ref {
              name = kubernetes_config_map.config.metadata[0].name
            }
          }
          env {
            name = "druid_plaintextPort"
            value = local.middlemanager_client_port
          }

          port {
            container_port = local.middlemanager_client_port
            name = "client"
          }

          volume_mount {
            mount_path = "/opt/druid/var"
            name = "${local.module_name}-middlemanager"
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
        name = "${local.module_name}-middlemanager"
        namespace = var.namespace
        labels = local.middlemanager_labels
      }
      spec {
        storage_class_name = var.storage_class
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = var.middlemanager_disk_size
          }
        }
      }
    }

  }
}
