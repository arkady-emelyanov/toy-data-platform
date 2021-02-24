locals {
  module_name = "zookeeper"
  module_labels = {
    app = local.module_name
  }

  client_port = 2181
  server_port = 2888
  leader_port = 3888

  logs_path = "/datalog"
  data_path = "/data"
  conf_path = "/conf"

  server_list_raw = [
  for i in range(0, var.cluster_size):
  {
    server = join(".", ["server", sum([i, 1])])
    host = "${local.module_name}-${i}.${local.module_name}.${var.namespace}.svc.cluster.local"
    ports = "${local.server_port}:${local.leader_port}"
  }]

  config_server_list = [
  for s in local.server_list_raw:
  format("%s=%s:%s", s["server"], s["host"], s["ports"])
  ]

  output_servers_list = [
  for s in local.server_list_raw:
  format("%s:%s", s["host"], local.client_port)
  ]
}

resource "kubernetes_config_map" "config" {
  metadata {
    name = "${local.module_name}-config"
    namespace = var.namespace
    labels = local.module_labels
  }

  data = {
    "log4j.properties" = file("${path.module}/configs/log4j.properties")
    "zoo.cfg" = templatefile("${path.module}/configs/zoo.cfg", {
      client_port = local.client_port
      logs_path = local.logs_path
      data_path = local.data_path
      server_list = local.config_server_list
    })
  }
}

resource "kubernetes_config_map" "entrypoint" {
  metadata {
    name = "${local.module_name}-entrypoint"
    namespace = var.namespace
    labels = local.module_labels
  }

  data = {
    "entrypoint.sh" = file("${path.module}/scripts/entrypoint.sh")
    "probe.sh" = file("${path.module}/scripts/probe.sh")
  }
}

resource "kubernetes_service" "service" {
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
    port {
      port = local.server_port
      target_port = local.server_port
      name = "server"
    }
    port {
      port = local.leader_port
      target_port = local.leader_port
      name = "leader"
    }
  }
}


resource "kubernetes_stateful_set" "deployment" {
  metadata {
    name = local.module_name
    namespace = var.namespace
    labels = local.module_labels
  }
  spec {
    service_name = local.module_name
    replicas = var.cluster_size
    pod_management_policy = "Parallel"

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
        termination_grace_period_seconds = 5
        security_context {
          run_as_user = 1000
          fs_group = 1000
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.config.metadata[0].name
          }
        }
        volume {
          name = "entrypoint"
          config_map {
            name = kubernetes_config_map.entrypoint.metadata[0].name
          }
        }

        container {
          name = "server"
          image_pull_policy = "IfNotPresent"
          image = var.server_image
          command = ["bash", "/app/entrypoint.sh"]

          port {
            container_port = local.client_port
            name = "client"
          }
          port {
            container_port = local.server_port
            name = "server"
          }
          port {
            container_port = local.leader_port
            name = "leader"
          }

          env {
            name = "ZOO_CONF_DIR"
            value = local.conf_path
          }

          volume_mount {
            mount_path = local.conf_path
            name = "config"
          }
          volume_mount {
            mount_path = "/app"
            name = "entrypoint"
          }
          volume_mount {
            mount_path = local.logs_path
            name = "${local.module_name}-logs"
          }
          volume_mount {
            mount_path = local.data_path
            name = "${local.module_name}-data"
          }

          liveness_probe {
            exec {
              command = ["bash", "/app/probe.sh", local.client_port]
            }
          }
          readiness_probe {
            exec {
              command = ["bash", "/app/probe.sh", local.client_port]
            }
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "${local.module_name}-logs"
      }
      spec {
        storage_class_name = var.storage_class
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = var.logs_disk_size
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "${local.module_name}-data"
      }
      spec {
        storage_class_name = var.storage_class
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = var.data_disk_size
          }
        }
      }
    }
  }
}
