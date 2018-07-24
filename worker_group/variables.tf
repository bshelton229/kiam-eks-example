variable "cluster_name" {}
variable "worker_group_name" {}

variable "desired_capacity" {
  default = 1
}

variable "kubelet_node_labels" {
  default = ""
}

variable "kubelet_register_with_taints" {
  default = ""
}

variable "key_name" {
  default = "default"
}

variable "instance_type" {
  default = "t2.small"
}

variable "iam_instance_profile_id" {}

variable "associate_public_ip_address" {
  default = false
}

variable "security_groups" {
  type = "list"
}

variable "subnets" {
  type = "list"
}

variable "cluster_auth_base64" {}
variable "cluster_endpoint" {}
