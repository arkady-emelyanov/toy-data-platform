locals {
  overload_client_port = 8080
  overlord_labels = merge(local.module_labels, {
    component = "overlord"
  })
}

resource "kubernetes_deployment" "coordinator_overlord" {
  wait_for_rollout = true

  metadata {
    name = "${local.module_name}-overlord"
    namespace = var.namespace
    labels = local.overlord_labels
  }
  spec {
    selector {
      match_labels = local.overlord_labels
    }
    template {
      metadata {
        labels = local.overlord_labels
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
            value = local.overload_client_port
          }

          port {
            container_port = local.overload_client_port
            name = "client"
          }

          readiness_probe {
            initial_delay_seconds = 10
            http_get {
              path = "/status/health"
              port = "client"
            }
          }
          liveness_probe {
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
