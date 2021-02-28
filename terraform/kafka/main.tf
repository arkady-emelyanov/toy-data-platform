locals {
  module_name = "kafka"
  module_labels = {
    app = local.module_name
  }

  client_port = 9092
  log_dirs = "/kafka"

  server_domain = "${local.module_name}.${var.namespace}.svc.cluster.local"
  output_servers_list = [
  for i in range(0, var.cluster_size):
  "${local.module_name}-${i}.${local.server_domain}:${local.client_port}"
  ]
}

resource "kubernetes_service" "headless" {
  metadata {
    name = local.module_name
    namespace = var.namespace
    labels = local.module_labels
  }
  spec {
    cluster_ip = "None"
    selector = local.module_labels
    port {
      port = local.client_port
      target_port = local.client_port
      name = "client"
    }
  }
}

resource "kubernetes_config_map" "entrypoint" {
  metadata {
    name = local.module_name
    namespace = var.namespace
    labels = local.module_labels
  }

  data = {
    "entrypoint.sh" = file("${path.module}/scripts/entrypoint.sh")
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
    replicas = var.cluster_size
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
        volume {
          name = "entrypoint"
          config_map {
            name = kubernetes_config_map.entrypoint.metadata[0].name
          }
        }

        container {
          name = "server"
          image = var.server_image
          image_pull_policy = "IfNotPresent"
          command = ["bash", "/app/entrypoint.sh"]

          readiness_probe {
            tcp_socket {
              port = "client"
            }
          }
          liveness_probe {
            tcp_socket {
              port = "client"
            }
          }

          volume_mount {
            mount_path = local.log_dirs
            name = "kafka-disk"
          }
          volume_mount {
            mount_path = "/app"
            name = "entrypoint"
          }

          port {
            container_port = local.client_port
            name = "client"
          }
          env {
            name = "KAFKA_ZOOKEEPER_CONNECT"
            value = var.zookeeper_servers
          }
          env {
            name = "KAFKA_LISTENERS"
            value = "INT://:${local.client_port}"
          }
          env {
            name = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP"
            value = "INT:PLAINTEXT"
          }
          env {
            name = "KAFKA_ADVERTISED_LISTENERS"
            value = "INT://:${local.client_port}"
          }
          env {
            name = "KAFKA_INTER_BROKER_LISTENER_NAME"
            value = "INT"
          }
          env {
            name = "KAFKA_AUTO_CREATE_TOPICS_ENABLE"
            value = "false"
          }
          env {
            name = "KAFKA_CREATE_TOPICS"
            value = var.topics
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "kafka-disk"
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
