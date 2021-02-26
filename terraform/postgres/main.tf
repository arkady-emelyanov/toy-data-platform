locals {
  module_name = "postgres"
  module_labels = {
    app = local.module_name
  }

  client_port = 5432
  init_path = "/docker-entrypoint-initdb.d"
  data_path = "/var/lib/postgresql/data"

  // generate initialize parameters
  postgres_password = random_string.postgres_password.result
  druid_database = "druid"
  druid_user = "druid"
  druid_password = random_string.postgres_password.result
  redash_database = "redash"
  redash_user = "redash"
  redash_password = random_string.postgres_password.result
}

resource "random_string" "postgres_password" {
  length = 10
  special = false
}

resource "random_string" "druid_password" {
  length = 10
  special = false
}

resource "random_string" "redash_password" {
  length = 10
  special = false
}

resource "kubernetes_config_map" "init" {
  metadata {
    name = "${local.module_name}-init"
    namespace = var.namespace
    labels = local.module_labels
  }

  data = {
    POSTGRES_PASSWORD = local.postgres_password
    DRUID_DATABASE = local.druid_database
    DRUID_USER = local.druid_user
    DRUID_PASSWORD = local.druid_password
    REDASH_DATABASE = local.redash_database
    REDASH_USER = local.redash_user
    REDASH_PASSWORD = local.redash_password
  }
}

resource "kubernetes_config_map" "scripts" {
  metadata {
    name = "${local.module_name}-scripts"
    namespace = var.namespace
    labels = local.module_labels
  }

  data = {
    "databases.sh" = file("${path.module}/scripts/databases.sh")
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

resource "kubernetes_stateful_set" "deployment" {
  wait_for_rollout = true

  metadata {
    name = local.module_name
    namespace = var.namespace
    labels = local.module_labels
  }

  spec {
    service_name = local.module_name
    replicas = 1
    pod_management_policy = "OrderedReady"
    update_strategy {
      type = "RollingUpdate"
    }

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
          image_pull_policy = "IfNotPresent"
          image = var.server_image

          port {
            container_port = local.client_port
            name = "client"
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.init.metadata[0].name
            }
          }

          volume_mount {
            mount_path = local.data_path
            name = "postgres-storage"
          }
          volume_mount {
            name = "postgres-scripts"
            mount_path = local.init_path
          }

          readiness_probe {
            exec {
              command = [
                "/usr/local/bin/pg_isready",
                "-Upostgres",
                "-h127.0.0.1",
                "-p${local.client_port}",
              ]
            }
          }
          liveness_probe {
            exec {
              command = [
                "/usr/local/bin/pg_isready",
                "-Upostgres",
                "-h127.0.0.1",
                "-p${local.client_port}",
              ]
            }
          }
        }

        volume {
          name = "postgres-scripts"
          config_map {
            name = kubernetes_config_map.scripts.metadata[0].name
            default_mode = "0777"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "postgres-storage"
        namespace = var.namespace
        labels = local.module_labels
      }
      spec {
        storage_class_name = var.storage_class
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = var.disk_size
          }
        }
      }
    }
  }
}
