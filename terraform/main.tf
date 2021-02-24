resource "kubernetes_namespace" "system_tools" {
  metadata {
    name = "system-tools"
  }
}

module "minio" {
  source = "./minio"
  namespace = kubernetes_namespace.system_tools.metadata[0].name
}
