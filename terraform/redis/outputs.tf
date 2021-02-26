output "endpoint" {
  depends_on = [kubernetes_deployment.redis]
  value = local.endpoint
}
