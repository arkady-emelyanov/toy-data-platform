# Historical
locals {
  historical_client_port = 8080
  historical_labels = merge(local.module_labels, {
    component = "historical"
  })
}

# StatefulSet
# @see: https://github.com/helm/charts/blob/master/incubator/druid/templates/historical/statefulset.yaml
resource "kubernetes_deployment" "historical" {
  depends_on = [kubernetes_deployment.coordinator_overlord]
  wait_for_rollout = true

  metadata {
    name = "${local.module_name}-historical"
    namespace = var.namespace
    labels = local.historical_labels
  }
  spec {
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

          // /status/health
        }
      }
    }
  }
}
