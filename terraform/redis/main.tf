locals {
  module_name = "redis"
  module_labels = {
    app = "redis"
  }

  client_port = 6379
  endpoint = "${local.module_name}.${var.namespace}.svc.cluster.local:${local.client_port}"
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
      port = local.client_port
      target_port = local.client_port
      name = "client"
    }
  }
}

resource "kubernetes_deployment" "redis" {
  wait_for_rollout = true

  metadata {
    name = local.module_name
    namespace = var.namespace
    labels = local.module_labels
  }
  spec {
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
          image = var.server_image
          image_pull_policy = "IfNotPresent"
          args = ["--port", local.client_port]

          port {
            container_port = local.client_port
            name = "client"
          }

          readiness_probe {
            exec {
              command = ["redis-cli", "-p", local.client_port, "ping"]
            }
          }
          liveness_probe {
            exec {
              command = ["redis-cli", "-p", local.client_port, "ping"]
            }
          }
        }
      }
    }
  }
}
