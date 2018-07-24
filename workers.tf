module "kiam_workers" {
  source = "./worker_group"

  cluster_name                = "${var.cluster_name}"
  worker_group_name           = "kiam"
  subnets                     = ["${module.vpc.public_subnets}"]
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.workers.id}"]
  cluster_auth_base64         = "${aws_eks_cluster.this.certificate_authority.0.data}"
  cluster_endpoint            = "${aws_eks_cluster.this.endpoint}"
  iam_instance_profile_id     = "${aws_iam_instance_profile.kiam_workers.id}"

  kubelet_node_labels          = "node-role.kubernetes.io/kiam="
  kubelet_register_with_taints = "node-role.kubernetes.io/master=:NoSchedule"
}

module "workers" {
  source = "./worker_group"

  cluster_name                = "${var.cluster_name}"
  worker_group_name           = "workers"
  subnets                     = ["${module.vpc.public_subnets}"]
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.workers.id}"]
  cluster_auth_base64         = "${aws_eks_cluster.this.certificate_authority.0.data}"
  cluster_endpoint            = "${aws_eks_cluster.this.endpoint}"
  iam_instance_profile_id     = "${aws_iam_instance_profile.workers.id}"

  kubelet_node_labels = "node-role.kubernetes.io/worker="
}
