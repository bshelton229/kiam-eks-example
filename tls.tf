# CA
resource "tls_private_key" "kiam_ca" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "kiam_ca" {
  key_algorithm   = "${tls_private_key.kiam_ca.algorithm}"
  private_key_pem = "${tls_private_key.kiam_ca.private_key_pem}"

  subject {
    common_name         = "kiam-ca"
    organization        = "${uuid()}"
    organizational_unit = "kiam"
  }

  is_ca_certificate = true

  # 3 Years
  validity_period_hours = "26298"

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]

  lifecycle {
    ignore_changes = ["subject"]
  }
}

# Server
resource "tls_private_key" "kiam_server" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "kiam_server" {
  key_algorithm   = "${tls_private_key.kiam_server.algorithm}"
  private_key_pem = "${tls_private_key.kiam_server.private_key_pem}"

  subject {
    common_name  = "kiam"
    organization = "kiam"
  }
}

resource "tls_locally_signed_cert" "kiam_server" {
  cert_request_pem = "${tls_cert_request.kiam_server.cert_request_pem}"

  ca_key_algorithm      = "${tls_self_signed_cert.kiam_ca.key_algorithm}"
  ca_private_key_pem    = "${tls_private_key.kiam_ca.private_key_pem}"
  ca_cert_pem           = "${tls_self_signed_cert.kiam_ca.cert_pem}"
  validity_period_hours = "26298"

  allowed_uses = [
    "key_encipherment",
    "server_auth",
  ]
}

# Agent
resource "tls_private_key" "kiam_agent" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "kiam_agent" {
  key_algorithm   = "${tls_private_key.kiam_agent.algorithm}"
  private_key_pem = "${tls_private_key.kiam_agent.private_key_pem}"

  subject {
    common_name  = "kiam"
    organization = "kiam"
  }
}

resource "tls_locally_signed_cert" "kiam_agent" {
  cert_request_pem = "${tls_cert_request.kiam_agent.cert_request_pem}"

  ca_key_algorithm      = "${tls_self_signed_cert.kiam_ca.key_algorithm}"
  ca_private_key_pem    = "${tls_private_key.kiam_ca.private_key_pem}"
  ca_cert_pem           = "${tls_self_signed_cert.kiam_ca.cert_pem}"
  validity_period_hours = "26298"

  allowed_uses = [
    "key_encipherment",
    "server_auth",
  ]
}
