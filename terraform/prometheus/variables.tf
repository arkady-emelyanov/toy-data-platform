variable "namespace" {
  type = string
}

variable "server_image" {
  type = string
  default = "prom/prometheus:v2.25.0"
}

variable "http_port" {
  type = number
  default = 9000
}

variable "storage_class" {
  type = string
  default = "standard"
}

variable "disk_size" {
  type = string
  default = "250Mi"
}
