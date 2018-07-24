data "template_file" "kubeconfig" {
  template = "${file("./templates/kubeconfig")}"

  vars {
    cluster_name        = "${var.cluster_name}"
    endpoint            = "${aws_eks_cluster.this.endpoint}"
    region              = "${data.aws_region.current.name}"
    cluster_auth_base64 = "${aws_eks_cluster.this.certificate_authority.0.data}"
  }
}

resource "local_file" "kubeconfig" {
  content  = "${data.template_file.kubeconfig.rendered}"
  filename = "./generated/kubeconfig"
}

data "template_file" "aws_auth" {
  template = "${file("./templates/aws-auth.yaml")}"

  vars {
    worker_role_arn = "${aws_iam_role.workers.arn}"
  }
}

resource "local_file" "aws_auth" {
  content  = "${data.template_file.aws_auth.rendered}"
  filename = "./generated/aws-auth.yaml"
}
