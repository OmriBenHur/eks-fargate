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

  depends_on = [aws_eks_fargate_profile.kube-system-fargate-profile]

}