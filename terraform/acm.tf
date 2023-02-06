module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = var.domain-name

  subject_alternative_names = [
    "*.omrisaaprac.com",
  ]

  create_route53_records  = false
  validation_record_fqdns = var.fqdns

  tags = {
    Name = "fargate application certificate"
  }
}


