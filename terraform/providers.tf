
# using terraform cloud to run these configuration files.
# aws access key and secret key are saved as env variables in the tf cloud workspace. so no declaration in code is needed
terraform {
  cloud {
    organization = "omribenhur"

    workspaces {
      name = "eks-fargate-application"
    }
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# provider conf. enter the region you're operating in
provider "aws" {
  region = "us-west-2"
}

data "aws_eks_cluster_auth" "cluster-auth" {
  depends_on = [aws_eks_cluster.eks-cluster-private[0]]
  name       = aws_eks_cluster.eks-cluster-private[0].name
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.eks-cluster-private[0].endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks-cluster-private[0].certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.cluster-auth.token
    load_config_file = false
  }
}

