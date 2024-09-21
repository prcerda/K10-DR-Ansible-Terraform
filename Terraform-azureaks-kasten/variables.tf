variable "location" {
    type = string
}

variable "aks_instance_type" {
    type = string
}

variable "vnet_cidr_block_ipv4" {
    type = string
}

variable "subnet_cidr_block_ipv4" {
    type = string
}

variable "cluster_name" {
  type = string
}

variable "owner" {
  type = string
}

variable "activity" {
  type = string
}

variable "aks_num_nodes" {
  description = "number of aks nodes"
}

variable "tokenexpirehours" {
  type = number
  default = 36
}