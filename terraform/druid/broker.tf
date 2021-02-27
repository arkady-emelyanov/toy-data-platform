#
# Druid Broker
# @see: https://druid.apache.org/docs/latest/design/broker.html
#
locals {
  broker_client_port = 8080
  broker_labels = merge(local.module_labels, {
    component = "broker"
  })
}

resource "kubernetes_deployment" "broker" {
  depends_on = [kubernetes_deployment.coordinator]
  wait_for_rollout = true

  metadata {
    name = "${local.module_name}-broker"
    namespace = var.namespace
    labels = local.broker_labels
  }
  spec {
    replicas = 1
    selector {
      match_labels = local.broker_labels
    }
    template {
      metadata {
        labels = local.broker_labels
      }
      spec {
        container {
          name = "server"
          image_pull_policy = "IfNotPresent"
          image = var.server_image
          args = ["broker"]

          env_from {
            config_map_ref {
              name = kubernetes_config_map.config.metadata[0].name
            }
          }
          env {
            name = "druid_plaintextPort"
            value = local.broker_client_port
          }

          port {
            container_port = local.broker_client_port
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
