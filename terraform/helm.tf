resource "helm_release" "metric-server" {
  name  = var.metric-server-name
  repository = var.metric-server-repo-url
  chart = var.metric-server-chart-name
  namespace = "kube-system"
  version = var.metric-server-chart-version

   set {
    name  = "metrics.enabled"
    value = false
  }

  depends_on = [aws_eks_fargate_profile.kube-system-fargate-profile,data.aws_lambda_invocation.bootstrap]

}

resource "helm_release" "aws-load-balancer-controller" {
  name  = var.load-balancer-name
  chart = var.load-balancer-chart-name
  repository = var.load-balancer-repo-url
  namespace = "kube-system"
  version = var.load-balancer-chart-version
   set {
    name  = "clusterName"
    value = var.cluster-name
  }

  set {
    name  = "image.tag"
    value = "v2.4.2"
  }

  set {
    name  = "replicaCount"
    value = 1
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller.arn
  }

  # EKS Fargate specific
  set {
    name  = "region"
    value = var.aws-region
  }

  set {
    name  = "vpcId"
    value = aws_vpc.fargate-application.id
  }

  depends_on = [aws_eks_fargate_profile.kube-system-fargate-profile,data.aws_lambda_invocation.bootstrap]
}