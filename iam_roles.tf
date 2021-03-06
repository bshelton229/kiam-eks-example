# EKS cluster iam role
data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    sid = "EKSClusterAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  name_prefix        = "${var.cluster_name}"
  assume_role_policy = "${data.aws_iam_policy_document.cluster_assume_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.cluster.name}"
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.cluster.name}"
}

# Workers
resource "aws_iam_role" "workers" {
  name_prefix = "${aws_eks_cluster.this.name}-workers-"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "workers" {
  name_prefix = "${aws_eks_cluster.this.name}-workers-"
  role        = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.workers.name}"
}

# Kiam Workers
resource "aws_iam_role" "kiam_workers" {
  name_prefix = "${aws_eks_cluster.this.name}-kiam-workers-"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "kiam_workers" {
  name_prefix = "${aws_eks_cluster.this.name}-kiam-workers-"
  role        = "${aws_iam_role.kiam_workers.name}"
}

resource "aws_iam_role_policy_attachment" "kiam_workers_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.kiam_workers.name}"
}

resource "aws_iam_role_policy_attachment" "kiam_workers_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.kiam_workers.name}"
}

resource "aws_iam_role_policy_attachment" "kiam_workers_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.kiam_workers.name}"
}

resource "aws_iam_role" "myapp" {
  name_prefix = "${aws_eks_cluster.this.name}-myapp-"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${aws_iam_role.kiam_workers.arn}"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  depends_on = [
    "aws_iam_role.kiam_workers",
  ]
}

resource "aws_iam_role_policy" "perm_test" {
  name = "perm-test"
  role = "${aws_iam_role.myapp.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:*"
            ],
            "Resource": "${aws_ssm_parameter.foo.arn}"
        }
    ]
}
EOF
}

resource "aws_ssm_parameter" "foo" {
  name  = "${var.cluster_name}-perm-test"
  type  = "String"
  value = "Hello!"
}
