variable "namespace" {
  type = string
  description = "Namespace to deploy to"
}

variable "zookeeper_servers" {
  type = string
  description = "Coma separated list of ZooKeeper servers"
}

variable "cluster_size" {
  type = number
  description = "Number of brokers"
  default = 1
}

variable "server_image" {
  type = string
  description = "Kafka server image"
  default = "wurstmeister/kafka:2.13-2.7.0"
}

variable "storage_class" {
  type = string
  description = "Storage class"
  default = "standard"
}

variable "disk_size" {
  type = string
  description = "Disk size"
  default = "250Mi"
}

variable "topics" {
  type = string
  description = "Topics to create"
  default = ""
}
