variable "namespace" {
  type = string
  description = "Namespace to deploy to"
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

variable "storage_class" {
  type = string
  description = "MiniO storage class"
  default = "standard"
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
