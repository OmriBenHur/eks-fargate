resource "aws_eks_fargate_profile" "staging" {
  cluster_name           = var.cluster-name
  fargate_profile_name   = "staging"
  pod_execution_role_arn = aws_iam_role.eks-fargate-profile-role.arn
  subnet_ids = var.fargate-staging-subnet-type == "public" ? [for o in aws_subnet.public : o.id] : [for o in aws_subnet.private : o.id]
  depends_on = [aws_eks_cluster.eks-cluster-public,aws_eks_cluster.eks-cluster-private]

  selector {
    namespace = "staging"
  }
}