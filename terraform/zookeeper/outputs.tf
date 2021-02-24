output "zookeeper_servers_string" {
  depends_on = [kubernetes_stateful_set.deployment]
  value = join(",", local.output_servers_list)
}

output "zookeeper_servers_json" {
  depends_on = [kubernetes_stateful_set.deployment]
  value = local.output_servers_list
}
