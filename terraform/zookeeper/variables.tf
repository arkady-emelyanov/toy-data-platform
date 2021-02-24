variable "namespace" {
  type = string
  description = "Namespace to deploy to"
}

variable "server_image" {
  type = string
  description = "ZooKeeper server image"
  default = "zookeeper:3.6.2"
}

variable "cluster_size" {
  type = number
  description = "ZooKeeper cluster size"
  default = 1
}

variable "storage_class" {
  type = string
  description = "ZooKeeper storage class"
  default = "standard"
}

variable "logs_disk_size" {
  type = string
  description = "ZooKeeper disk size for logs"
  default = "100Mi"
}

variable "data_disk_size" {
  type = string
  description = "ZooKeeper disk size for data"
  default = "100Mi"
}
