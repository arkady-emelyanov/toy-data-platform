#
# The Platform root module
#

# Storage deployment namespace
resource "kubernetes_namespace" "storage" {
  metadata {
    name = "storage"
  }
}

module "minio" {
  source = "./minio"
  namespace = kubernetes_namespace.storage.metadata[0].name

  disk_size = "200Mi"
}

module "redis" {
  source = "./redis"
  namespace = kubernetes_namespace.storage.metadata[0].name
}

module "zookeeper" {
  source = "./zookeeper"
  namespace = kubernetes_namespace.storage.metadata[0].name

  data_disk_size = "100Mi"
  logs_disk_size = "60Mi"
}

module "postgres" {
  source = "./postgres"
  namespace = kubernetes_namespace.storage.metadata[0].name

  disk_size = "100Mi"
}

## Message bus deployment namespace
resource "kubernetes_namespace" "streaming" {
  metadata {
    name = "streaming"
  }
}

module "kafka" {
  source = "./kafka"
  namespace = kubernetes_namespace.streaming.metadata[0].name

  disk_size = "250Mi"
  zookeeper_servers = module.zookeeper.servers_string
  topics = "v1.raw:3:1,v1.hits:3:1,v1.dlq:3:1"
}

## OLAP backend
resource "kubernetes_namespace" "olap" {
  metadata {
    name = "olap"
  }
}

module "druid" {
  source = "./druid"
  namespace = kubernetes_namespace.olap.metadata[0].name

  middlemanager_disk_size = "250Mi"
  historical_disk_size = "250Mi"
  zookeeper_servers = module.zookeeper.servers_string

  minio_endpoint = module.minio.endpoint
  minio_bucket = module.minio.bucket
  minio_access_key = module.minio.access_key
  minio_secret_key = module.minio.secret_key

  postgres_endpoint = module.postgres.endpoint
  postgres_database = module.postgres.druid_database
  postgres_username = module.postgres.druid_user
  postgres_password = module.postgres.druid_password
}

## Monitoring
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

module "prometheus" {
  source = "./prometheus"
  namespace = kubernetes_namespace.monitoring.metadata[0].name
  disk_size = "250Mi"
}

## Dashboards/Exploratory
resource "kubernetes_namespace" "dashboard" {
  metadata {
    name = "dashboard"
  }
}

module "redash" {
  source = "./redash"
  namespace = kubernetes_namespace.dashboard.metadata[0].name

  postgres_endpoint = module.postgres.endpoint
  postgres_database = module.postgres.redash_database
  postgres_username = module.postgres.redash_user
  postgres_password = module.postgres.redash_password

  redis_endpoint = module.redis.endpoint
}
