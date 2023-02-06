#data obj to return eks cluster assume role policy to be used in the role creation
data "aws_iam_policy_document" "eks-cluster-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}


# iam role for eks
resource "aws_iam_role" "eks-role" {
  name               = "eks-${var.cluster-name}"
  assume_role_policy = data.aws_iam_policy_document.eks-cluster-assume-role-policy.json
}


# iam policy attachment for eks cluster role, permitting cluster actions
resource "aws_iam_policy_attachment" "eks-cluster-role-policy-attachment" {
  for_each = toset ([for o in var.eks-cluster-role-policy-arn : o])
  policy_arn = each.value
  name       = "eks-cluster-role-policy-attachment"
  roles      = [aws_iam_role.eks-role.name]
}


# the eks control plane
# aws eks update-kubeconfig --name var.cluster-name --region us-east-1
resource "aws_eks_cluster" "eks-cluster-public" {
  count    = var.eks-subnet-type == "private" || var.fargate-staging-subnet-type == "private" || var.fargate-subnet-type == "private" ? 0 : 1
  name     = var.cluster-name
  version  = var.eks-cluster-version
  role_arn = aws_iam_role.eks-role.arn


  vpc_config {
    subnet_ids = [for j in aws_subnet.public : j.id]
    endpoint_private_access = false
    endpoint_public_access = true
    public_access_cidrs = ["0.0.0.0/0"]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [aws_iam_policy_attachment.eks-cluster-role-policy-attachment]
}

# the eks control plane
resource "aws_eks_cluster" "eks-cluster-private" {
  count    = var.eks-subnet-type == "private" || var.fargate-staging-subnet-type == "private" || var.fargate-subnet-type == "private" ? 1 : 0
  name     = var.cluster-name
  version  = var.eks-cluster-version
  role_arn = aws_iam_role.eks-role.arn


  vpc_config {
    subnet_ids = concat([for o in aws_subnet.private : o.id], [for j in aws_subnet.public : j.id])
    endpoint_private_access = false
    endpoint_public_access = true
    public_access_cidrs = ["0.0.0.0/0"]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [aws_iam_policy_attachment.eks-cluster-role-policy-attachment]
}