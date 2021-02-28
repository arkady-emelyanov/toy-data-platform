#
# Install Druid Coordinator (and Overlord)
# (druid_coordinator_asOverlord_enabled should be set to "true")
#
# @see: https://druid.apache.org/docs/latest/design/coordinator.html
# @see: https://druid.apache.org/docs/latest/design/overlord.html
#
locals {
  coordinator_client_port = 8080
  coordinator_labels = merge(local.module_labels, {
    component = "coordinator"
  })
}

resource "kubernetes_deployment" "coordinator" {
  wait_for_rollout = true

  metadata {
    name = "${local.module_name}-coordinator"
    namespace = var.namespace
    labels = local.coordinator_labels
  }
  spec {
    selector {
      match_labels = local.coordinator_labels
    }
    template {
      metadata {
        labels = local.coordinator_labels
      }
      spec {
        container {
          name = "server"
          image_pull_policy = "IfNotPresent"
          image = var.server_image
          args = ["coordinator"]

          env_from {
            config_map_ref {
              name = kubernetes_config_map.config.metadata[0].name
            }
          }
          env {
            name = "druid_plaintextPort"
            value = local.coordinator_client_port
          }

          port {
            container_port = local.coordinator_client_port
            name = "client"
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
  }
}
