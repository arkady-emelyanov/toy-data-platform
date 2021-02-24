terraform {
  required_version = ">= 0.14"
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "= 1.13.3"
    }
  }
  backend "local" {
    path = "platform.tfstate"
  }
}
