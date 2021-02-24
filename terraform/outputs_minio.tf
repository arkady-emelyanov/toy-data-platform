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
