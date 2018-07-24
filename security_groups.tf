# EKS Security Groups
resource "aws_security_group" "cluster" {
  name_prefix = "${var.cluster_name}-eks-"
  description = "EKS cluster security group."
  vpc_id      = "${module.vpc.vpc_id}"

  tags = {
    Name = "${var.cluster_name}-eks-"
  }
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = "${aws_security_group.cluster.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "cluster_https_worker_ingress" {
  description              = "Allow pods to communicate with the EKS cluster API."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cluster.id}"
  source_security_group_id = "${aws_security_group.workers.id}"
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

# Worker Security Groups

resource "aws_security_group" "workers" {
  name_prefix = "${var.cluster_name}-workers-"
  description = "Security group for all nodes in the cluster."
  vpc_id      = "${module.vpc.vpc_id}"

  tags = {
    Name = "${var.cluster_name}-eks-"
  }
}

resource "aws_security_group_rule" "workers_egress_internet" {
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = "${aws_security_group.workers.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.workers.id}"
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  description              = "Allow workers Kubelets and pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.cluster.id}"
  from_port                = 1025
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "ssh" {
  description       = "Allow SSH"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.workers.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  type              = "ingress"
}
