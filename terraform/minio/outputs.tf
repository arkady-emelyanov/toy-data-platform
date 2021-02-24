output "access_key" {
  depends_on = [kubernetes_job.create_bucket]
  value = random_string.access_key.result
}

output "secret_key" {
  depends_on = [kubernetes_job.create_bucket]
  value = random_string.secret_key.result
}

output "bucket" {
  depends_on = [kubernetes_job.create_bucket]
  value = local.bucket
}

output "endpoint" {
  depends_on = [kubernetes_job.create_bucket]
  value = "http://${local.endpoint}"
}
