# data obj to return a list of available AZ's in the configured region
variable "aws-region" {
  description = "region for aws"
  default = "us-west-2"
}

data "aws_availability_zones" "available_zones" {
  state = "available"
}

variable "subnet_amount" {
  description = "subnet duplicate amount"
  default     = 1
}

variable "eks-cluster-version" {
  description = "kubernetes version for the cluster"
  default = "1.24"
}

variable "vpc-cidr" {
  description = "cidr range for vpc"
  default = "10.0.0.0/16"
}

variable "vpc-name" {
  default = "fargate-application"
}

variable "cluster-name" {
  description = "name for eks cluster"
  default = "fargate-app"
}

variable "eks-cluster-role-policy-arn" {
  description = "arn for the policy to be attached to the eks cluster role"
  type        = list(any)
  default     = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
}

variable "eks-fargate-role-policy-arn" {
  description = "arn for the policy to be attached to the eks fargate role"
  type        = list(any)
  default     = ["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]
}

variable "fargate-subnet-type" {
  description = "public subnet or private subnet?"
  default     = "private"
}

variable "fargate-staging-subnet-type" {
  description = "public subnet or private subnet?"
  default     = "private"
}

variable "eks-subnet-type" {
  description = "public subnet or private subnet?"
  default     = "public"
}

variable "metric-server-name" {
  description = "name for internal helm release of metric server"
  default = "metric-server"
}

variable "metric-server-repo-url" {
  description = "repo for helm chart of the metric server"
  default = "https://kubernetes-sigs.github.io/metrics-server/"
}

variable "metric-server-chart-name" {
  description = "chart name for metric server in the matching repo"
  default = "metrics-server"
}

variable "metric-server-chart-version" {
  description = "version of chart to be installed"
  default = "3.8.2"
}


variable "load-balancer-name" {
  description = "name for internal helm release of metric server"
  default = "aws-load-balancer-controller"
}

variable "load-balancer-repo-url" {
  description = "repo for helm chart of the metric server"
  default = "https://aws.github.io/eks-charts/"
}

variable "load-balancer-chart-name" {
  description = "chart name for metric server in the matching repo"
  default = "aws-load-balancer-controller"
}

variable "load-balancer-chart-version" {
  description = "version of chart to be installed"
  default = "1.4.1"
}


