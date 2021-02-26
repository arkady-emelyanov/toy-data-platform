locals {
  module_name = "redash"
  module_labels = {
    app = local.module_name
  }

  client_port = 5000

  redis_url = "redis://${var.redis_endpoint}/${var.redis_database}"
  postgres_url = "postgresql://${var.postgres_username}:${var.postgres_password}@${var.postgres_endpoint}"
}

resource "kubernetes_config_map" "config" {
  metadata {
    name = local.module_name
    namespace = var.namespace
    labels = local.module_labels
  }

  data = {
    REDASH_REDIS_URL = local.redis_url
    REDASH_DATABASE_URL = local.postgres_url
    REDASH_WEB_WORKERS = "1"
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
      port = local.client_port
      target_port = local.client_port
      name = "client"
    }
  }
}

resource "kubernetes_deployment" "server" {
  metadata {
    name = local.module_name
    namespace = var.namespace
    labels = local.module_labels
  }
  spec {
    replicas = 1
    selector {
      match_labels = local.module_labels
    }
    template {
      metadata {
        labels = local.module_labels
      }
      spec {
        init_container {
          name = "install"
          image_pull_policy = "IfNotPresent"
          image = var.server_image
          args = ["manage", "database", "create_tables"]

          env_from {
            config_map_ref {
              name = kubernetes_config_map.config.metadata[0].name
            }
          }
        }

        container {
          name = "server"
          image_pull_policy = "IfNotPresent"
          image = var.server_image
          args = ["server"]

          port {
            container_port = local.client_port
            name = "client"
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.config.metadata[0].name
            }
          }

          readiness_probe {
            http_get {
              path = "/ping"
              port = "client"
            }
          }

          liveness_probe {
            http_get {
              path = "/ping"
              port = "client"
            }
          }
        }
      }
    }
  }
}
