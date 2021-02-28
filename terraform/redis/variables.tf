variable "namespace" {
  type = string
  description = "Namespace to deploy to"
}

variable "server_image" {
  type = string
  default = "redis:6.2.0-alpine3.13"
}
