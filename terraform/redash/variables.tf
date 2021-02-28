variable "namespace" {
  type = string
  description = "Namespace to deploy to"
}

variable "server_image" {
  type = string
  default = "redash/redash:8.0.2.b37747"
}

variable "redis_endpoint" {
  type = string
}

variable "redis_database" {
  type = number
  default = 0
}

variable "postgres_endpoint" {
  type = string
}

variable "postgres_username" {
  type = string
}

variable "postgres_password" {
  type = string
}

variable "postgres_database" {
  type = string
}

