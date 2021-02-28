#
# Create Role and ServiceAccount for Flink/Spark application
#
locals {
  namespace = "default"
}

resource "kubernetes_role" "compute_role" {
  metadata {
    name = "compute-sa"
    namespace = local.namespace
  }
  rule {
    api_groups = [""]
    resources = ["pods"]
    verbs = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
  rule {
    api_groups = [""]
    resources = ["configmaps"]
    verbs = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
  rule {
    api_groups = ["apps"]
    resources = ["deployments"]
    verbs = ["get", "list"]
  }
}

resource "kubernetes_service_account" "compute_sa" {
  metadata {
    name = "compute-sa"
    namespace = local.namespace
  }
  automount_service_account_token = true
}

resource "kubernetes_role_binding" "compute_role_binding" {
  metadata {
    name = "compute-sa"
    namespace = local.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = kubernetes_role.compute_role.metadata[0].name
  }
  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account.compute_sa.metadata[0].name
    namespace = kubernetes_service_account.compute_sa.metadata[0].namespace
  }
}
