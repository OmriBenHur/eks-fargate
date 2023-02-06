resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain-name
  validation_method = "DNS"

  tags = {
    Name = "fargate application certificate"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "hello_cert_validate" {
  certificate_arn = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for o in var.fqdns : o]
}