output "access_key" {
  depends_on = [kubernetes_job.minio_create_bucket]
  value = random_string.minio_access_key.result
}

output "secret_key" {
  depends_on = [kubernetes_job.minio_create_bucket]
  value = random_string.minio_secret_key.result
}

output "bucket" {
  depends_on = [kubernetes_job.minio_create_bucket]
  value = local.bucket
}

output "endpoint" {
  depends_on = [kubernetes_job.minio_create_bucket]
  value = "http://${local.endpoint}"
}
