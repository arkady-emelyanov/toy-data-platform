resource "kubernetes_namespace" "storage" {
  metadata {
    name = "storage"
  }
}

module "minio" {
  source = "./minio"
  namespace = kubernetes_namespace.storage.metadata[0].name
}

module "zookeeper" {
  source = "./zookeeper"
  namespace = kubernetes_namespace.storage.metadata[0].name
}

// Kafka

// Pinot

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

// prometheus

// grafana

resource "kubernetes_namespace" "exploratory" {
  metadata {
    name = "exploratory"
  }
}

// superset
