# Router
locals {
  router_client_port = 8080
  router_labels = merge(local.module_labels, {
    component = "router"
  })
}

resource "kubernetes_service" "router_service" {
  metadata {
    name = "${local.module_name}-router"
    namespace = var.namespace
    labels = local.router_labels
  }
  spec {
    selector = local.router_labels
    port {
      port = local.router_client_port
      target_port = local.router_client_port
      name = "router"
    }
  }
}

resource "kubernetes_deployment" "router" {
  depends_on = [kubernetes_deployment.coordinator_overlord]
  wait_for_rollout = true

  metadata {
    name = "${local.module_name}-router"
    namespace = var.namespace
    labels = local.router_labels
  }
  spec {
    selector {
      match_labels = local.router_labels
    }
    template {
      metadata {
        labels = local.router_labels
      }
      spec {
        container {
          name = "server"
          image_pull_policy = "IfNotPresent"
          image = var.server_image
          args = ["router"]

          env_from {
            config_map_ref {
              name = kubernetes_config_map.config.metadata[0].name
            }
          }
          env {
            name = "druid_plaintextPort"
            value = local.router_client_port
          }

          port {
            container_port = local.router_client_port
            name = "client"
          }

          readiness_probe {
            initial_delay_seconds = 20
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
