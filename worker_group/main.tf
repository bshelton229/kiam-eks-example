data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["eks-worker-*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon
}

data "aws_region" "current" {}

data "template_file" "userdata" {
  template = "${file("${path.module}/userdata.sh")}"

  vars {
    cluster_auth_base64          = "${var.cluster_auth_base64}"
    kubelet_node_labels          = "${var.kubelet_node_labels}"
    kubelet_register_with_taints = "${var.kubelet_register_with_taints}"
    cluster_name                 = "${var.cluster_name}"
    region                       = "${data.aws_region.current.name}"
    endpoint                     = "${var.cluster_endpoint}"
    max_pod_count                = "${lookup(local.max_pod_per_node, var.instance_type, 8)}"
  }
}

resource "aws_autoscaling_group" "workers" {
  name_prefix          = "${var.cluster_name}-${var.worker_group_name}-"
  desired_capacity     = "${var.desired_capacity}"
  max_size             = "${var.desired_capacity * 2}"
  min_size             = "${var.desired_capacity}"
  launch_configuration = "${aws_launch_configuration.workers.id}"
  vpc_zone_identifier  = ["${var.subnets}"]

  tags = [
    {
      key                 = "Name"
      value               = "${var.cluster_name}-${var.worker_group_name}"
      propagate_at_launch = true
    },
    {
      key                 = "kubernetes.io/cluster/${var.cluster_name}"
      value               = "owned"
      propagate_at_launch = true
    },
  ]
}

resource "aws_launch_configuration" "workers" {
  name_prefix                 = "${var.cluster_name}-${var.worker_group_name}-"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  security_groups             = ["${var.security_groups}"]
  iam_instance_profile        = "${var.iam_instance_profile_id}"
  image_id                    = "${data.aws_ami.eks_worker.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  user_data_base64            = "${base64encode(data.template_file.userdata.rendered)}"
  ebs_optimized               = "${lookup(local.ebs_optimized, var.instance_type, false)}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    delete_on_termination = true
  }
}
