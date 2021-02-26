resource "kubernetes_namespace" "storage" {
  metadata {
    name = "storage"
  }
}

module "minio" {
  source = "./minio"
  namespace = kubernetes_namespace.storage.metadata[0].name
}

#module "zookeeper" {
#  source = "./zookeeper"
#  namespace = kubernetes_namespace.storage.metadata[0].name
#}
#
#module "kafka" {
#  source = "./kafka"
#  namespace = kubernetes_namespace.storage.metadata[0].name
#  zookeeper_servers = module.zookeeper.servers_string
#  topics = "v1.raw:3:1,v1.hits:3:1,v1.dlq:3:1"
#}

// druid

#resource "kubernetes_namespace" "compute" {
#  metadata {
#    name = "compute"
#  }
#}
#
#// spark cluster
#
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

module "prometheus" {
  source = "./prometheus"
  namespace = kubernetes_namespace.monitoring.metadata[0].name
}
