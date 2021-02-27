# MiddleManager
locals {
  middlemanager_client_port = 8084
  middlemanager_labels = merge(local.module_labels, {
    component = "middlemanager"
  })
}
// StatefulSet
// @see: https://github.com/helm/charts/blob/master/incubator/druid/templates/middleManager/statefulset.yaml
resource "kubernetes_deployment" "middlemanager" {
  depends_on = [kubernetes_deployment.coordinator_overlord]
  wait_for_rollout = true

  metadata {
    name = "${local.module_name}-middlemanager"
    namespace = var.namespace
    labels = local.middlemanager_labels
  }
  spec {
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

          // /status/health
        }
      }
    }
  }
}
