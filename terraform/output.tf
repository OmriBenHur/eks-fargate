output "aws_load_balancer_controller_role_arn" {
  value = aws_iam_role.aws_load_balancer_controller.arn
}

output "kubectl-update-config" {
  value = "aws eks update-kubeconfig --name ${var.cluster-name} --region ${var.aws-region}"
}

