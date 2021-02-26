output "endpoint" {
  depends_on = [kubernetes_stateful_set.deployment]
  value = "${local.module_name}.${var.namespace}.svc.cluster.local:${local.client_port}"
}

output "druid_database" {
  depends_on = [kubernetes_stateful_set.deployment]
  value = local.druid_database
}

output "druid_user" {
  depends_on = [kubernetes_stateful_set.deployment]
  value = local.druid_user
}

output "druid_password" {
  depends_on = [kubernetes_stateful_set.deployment]
  value = local.druid_password
}

output "redash_database" {
  depends_on = [kubernetes_stateful_set.deployment]
  value = local.redash_database
}

output "redash_user" {
  depends_on = [kubernetes_stateful_set.deployment]
  value = local.redash_user
}

output "redash_password" {
  depends_on = [kubernetes_stateful_set.deployment]
  value = local.redash_password
}
