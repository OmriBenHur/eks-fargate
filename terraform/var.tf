# data obj to return a list of available AZ's in the configured region
data "aws_availability_zones" "available_zones" {
  state = "available"
}

variable "subnet_amount" {
  description = "subnet duplicate amount"
  default     = 2
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


