variable "namespace" {
  type = string
  description = "Namespace to install to"
}

// @see: https://hub.docker.com/r/minio/minio/tags
variable "server_image" {
  type = string
  description = "MiniO server image"
  default = "minio/minio:edge"
}

variable "command_image" {
  type = string
  description = "MiniO command image"
  default = "minio/mc:edge"
}

variable "disk_size" {
  type = string
  description = "MiniO disk size"
  default = "250Mi"
}

variable "http_port" {
  type = number
  description = "MiniO port"
  default = 9000
}
