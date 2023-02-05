# The following Lambda resource fixes a CoreDNS issue on Fargate EKS clusters

data "archive_file" "bootstrap_archive" {
  type        = "zip"
  source_dir  = "lambda"
  output_path = "lambda.zip"
}

resource "aws_security_group" "bootstrap" {
  name_prefix = var.cluster-name # Reference to EKS Cluster Name variable
  vpc_id      = aws_vpc.fargate-application.id # Reference to VPC ID variable (VPC in which EKS Cluster is hosted)

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#data obj to return lambda assume role policy to be used in the role creation
data "aws_iam_policy_document" "lambda-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}



resource "aws_iam_role" "bootstrap" {
  name_prefix        = var.cluster-name # Reference to EKS Cluster Name variable
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "bootstrap" {
  role        = aws_iam_role.bootstrap.name
  policy_arn  = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "bootstrap" {
  function_name    = "${var.cluster-name}-bootstrap"
  runtime          = "python3.7"
  handler          = "main.handler"
  role             = aws_iam_role.bootstrap.arn
  filename         = data.archive_file.bootstrap_archive.output_path
  source_code_hash = data.archive_file.bootstrap_archive.output_base64sha256
  timeout          = 120
  depends_on = [aws_eks_cluster.eks-cluster-private[0]]

  vpc_config {
    subnet_ids = concat([for o in aws_subnet.private : o.id], [for j in aws_subnet.public : j.id])
    security_group_ids = [aws_security_group.bootstrap.id]
  }
}

data "aws_lambda_invocation" "bootstrap" {
  function_name = aws_lambda_function.bootstrap.function_name
  input = <<JSON
{
  "endpoint": "${aws_eks_cluster.eks-cluster-private[0].endpoint}",
  "token": "${data.aws_eks_cluster_auth.cluster-auth.token}"
}
JSON

  depends_on = [aws_lambda_function.bootstrap]
}