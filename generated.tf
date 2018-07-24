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

data "template_file" "kiam_manifest" {
  template = "${file("./templates/kiam.yaml")}"

  vars {
    ca_pem         = "${base64encode(tls_self_signed_cert.kiam_ca.cert_pem)}"
    server_pem     = "${base64encode(tls_locally_signed_cert.kiam_server.cert_pem)}"
    server_key_pem = "${base64encode(tls_private_key.kiam_server.private_key_pem)}"
    agent_pem      = "${base64encode(tls_locally_signed_cert.kiam_agent.cert_pem)}"
    agent_key_pem  = "${base64encode(tls_private_key.kiam_agent.private_key_pem)}"
  }
}

resource "local_file" "kiam_manifest" {
  content  = "${data.template_file.kiam_manifest.rendered}"
  filename = "./generated/kiam.yaml"
}
