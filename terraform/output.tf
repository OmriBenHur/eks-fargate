
output "kubectl-update-config" {
  value = "aws eks update-kubeconfig --name ${var.cluster-name} --region ${var.aws-region}"
}

output "efs-id" {
  value = aws_efs_file_system.fargate-app-efs.id
}
