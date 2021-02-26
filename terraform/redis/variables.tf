variable "namespace" {
  type = string
}

variable "server_image" {
  type = string
  default = "redis:6.2.0-alpine3.13"
}
