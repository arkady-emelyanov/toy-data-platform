variable "namespace" {
  type = string
}

variable "server_image" {
  type = string
  default = "apache/druid:0.20.1"
}

variable "zookeeper_servers" {
  type = string
}

variable "postgres_endpoint" {
  type = string
}

variable "postgres_database" {
  type = string
}

variable "postgres_username" {
  type = string
}

variable "postgres_password" {
  type = string
}

variable "minio_endpoint" {
  type = string
}

variable "minio_access_key" {
  type = string
}

variable "minio_secret_key" {
  type = string
}

variable "minio_bucket" {
  type = string
}

variable "storage_class" {
  type = string
  default = "standard"
}

variable "historical_disk_size" {
  type = string
  default = "250Mi"
}

variable "middlemanager_disk_size" {
  type = string
  default = "250Mi"
}
