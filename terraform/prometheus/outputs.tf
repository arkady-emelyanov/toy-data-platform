output "endpoint" {
  depends_on = [kubernetes_stateful_set.deployment]
  value = "http://${local.endpoint}"
}
