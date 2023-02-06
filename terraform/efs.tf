resource "aws_efs_file_system" "fargate-app-efs" {
  creation_token = "eks"

  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = true
  tags = {
    Name = "${var.cluster-name}-efs"
  }
}

resource "aws_efs_mount_target" "fargate-efs-mount" {
  file_system_id = aws_efs_file_system.fargate-app-efs.id
  for_each = toset ([for o in aws_subnet.private : o.id])
  subnet_id = each.value
  security_groups = [aws_eks_cluster.eks-cluster-private[0].vpc_config[0].cluster_security_group_id]
}