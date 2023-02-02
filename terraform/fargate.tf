#data obj to return eks cluster assume role policy to be used in the role creation
data "aws_iam_policy_document" "eks-fargate-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks-fargate-profile-role" {
  assume_role_policy = data.aws_iam_policy_document.eks-fargate-assume-role-policy.json
  name = "${var.cluster-name}-fargate-profile-role"
}

resource "aws_iam_policy_attachment" "eks-fargate-role-attachment" {
  for_each   = toset ([for o in var.eks-fargate-role-policy-arn : o])
  policy_arn = each.value
  name       = "${var.cluster-name}-fargate-role-attachment"
  roles      = [aws_iam_role.eks-fargate-profile-role.name]
}

resource "aws_eks_fargate_profile" "kube-system-fargate-profile" {
  cluster_name           = var.cluster-name
  fargate_profile_name   = "${var.cluster-name}-fargate-profile"
  pod_execution_role_arn = aws_iam_role.eks-fargate-profile-role.arn

  subnet_ids = [replace("for o in aws_subnet.replace : o.id","replace",var.fargate-subnet-type)]

  selector {
    namespace = "kube-system"
  }
}
#
#                 this section can't be used with terraform cloud(on remote-exec mode)
# use "kubectl patch deployment coredns -n kube-system --type json -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'"
# on a shell with kubectl context pointing to eks cluster
##########################################################################################################3

#data "aws_eks_cluster_auth" "eks" {
#  name = aws_eks_cluster.eks-cluster.id
#}
#
#resource "null_resource" "k8s_patcher" {
#  depends_on = [aws_eks_fargate_profile.kube-system-fargate-profile]
#
#  triggers = {
#    endpoint = aws_eks_cluster.eks-cluster.endpoint
#    ca_crt   = base64decode(aws_eks_cluster.eks-cluster.certificate_authority[0].data)
#    token    = data.aws_eks_cluster_auth.eks.token
#  }
#
#  provisioner "local-exec" {
#    command = <<EOH
#cat >/tmp/ca.crt <<EOF
#${base64decode(aws_eks_cluster.eks-cluster.certificate_authority[0].data)}
#EOF
#kubectl \
#  --server="${aws_eks_cluster.eks-cluster.endpoint}" \
#  --certificate_authority=/tmp/ca.crt \
#  --token="${data.aws_eks_cluster_auth.eks.token}" \
#  patch deployment coredns \
#  -n kube-system --type json \
#  -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
#EOH
#  }
#
#  lifecycle {
#    ignore_changes = [triggers]
#  }
#}

