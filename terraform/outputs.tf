output "compute_service_account" {
  value = kubernetes_service_account.compute_sa.metadata[0].name
}

output "minio_access_key" {
  value = module.minio.access_key
}

output "minio_secret_key" {
  value = module.minio.secret_key
}

output "minio_bucket_name" {
  value = module.minio.bucket
}

output "minio_endpoint" {
  value = module.minio.endpoint
}

output "prometheus_endpoint" {
  value = module.prometheus.endpoint
}

output "redis_endpoint" {
  value = module.redis.endpoint
}

output "postgres_endpoint" {
  value = module.postgres.endpoint
}

output "kafka_servers" {
  value = module.kafka.servers_string
}
