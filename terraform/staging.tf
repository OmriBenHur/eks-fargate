resource "aws_eks_fargate_profile" "staging" {
  cluster_name           = var.cluster-name
  fargate_profile_name   = "staging"
  pod_execution_role_arn = aws_iam_role.eks-fargate-profile-role.arn
  subnet_ids = [for o in aws_subnet.public : o.id]

  selector {
    namespace = "staging"
  }
}