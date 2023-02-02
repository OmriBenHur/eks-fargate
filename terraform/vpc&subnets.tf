
resource "aws_vpc" "fargate-application" {
  cidr_block = var.vpc-cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = var.vpc-name
  }
}

# creating 2 public subnets
resource "aws_subnet" "public" {
  count                   = var.subnet_amount
  vpc_id                  = aws_vpc.fargate-application.id
  cidr_block              = cidrsubnet(aws_vpc.fargate-application.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name                                            = "${var.vpc-name}-public-subnet-${count.index + 1}"
    "Kubernetes.io / role / elb"                    = count.index
    "kubernetes.io / cluster / ${var.cluster-name}" = "owned"

  }
}
# creating 2 private subnets
resource "aws_subnet" "private" {
  count             = var.eks-subnet-type == "private" || var.fargate-staging-subnet-type == "private" || var.fargate-subnet-type == "private" ? var.subnet_amount : 0
  vpc_id            = aws_vpc.fargate-application.id
  cidr_block        = cidrsubnet(aws_vpc.fargate-application.cidr_block, 8, var.subnet_amount + count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  tags = {
    Name                                            = "${var.vpc-name}-private-subnet-${count.index + 1}"
    "Kubernetes.io / role / internal-elb"           = count.index
    "kubernetes.io / cluster / ${var.cluster-name}" = "owned"
  }
}