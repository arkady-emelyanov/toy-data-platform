# Forcing to use Minikube entry in .kube/config
provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "minikube"
}
