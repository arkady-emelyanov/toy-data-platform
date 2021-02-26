variable "namespace" {
  type = string
}

variable "server_image" {
  type = string
  default = "postgres:13.2-alpine"
}

variable "disk_size" {
  type = string
  default = "100Mi"
}

variable "storage_class" {
  type = string
  default = "standard"
}
