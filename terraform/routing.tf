resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.fargate-application.id

  tags = {
    Name = "${var.vpc-name}igw"
  }
}


# creating two elastic ip's to use in NAT gateway to bridge connection to private subnet
resource "aws_eip" "EIP" {
  count      = var.eks-subnet-type == "private" || var.fargate-staging-subnet-type == "private" || var.fargate-subnet-type == "private" ? var.subnet_amount : 0
  vpc        = true
  depends_on = [aws_internet_gateway.igw]

}

#creating NAT gateway in public subnets and allocating elastic ips
resource "aws_nat_gateway" "NAT_gateway" {
  count      = var.eks-subnet-type == "private" || var.fargate-staging-subnet-type == "private" || var.fargate-subnet-type == "private" ? var.subnet_amount : 0
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.EIP.*.id, count.index)
  tags = {
    Name = "NAT Gateway"
  }
}

# public route table
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.fargate-application.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rtb"
  }
}

# private route table
resource "aws_route_table" "private_rtb" {
  count  = var.eks-subnet-type == "private" || var.fargate-staging-subnet-type == "private" || var.fargate-subnet-type == "private" ? var.subnet_amount : 0
  vpc_id = aws_vpc.fargate-application.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.NAT_gateway.*.id, count.index)
  }

  tags = {
    Name = "private-rtb-${count.index + 1}"
  }
}

# public route table association
resource "aws_route_table_association" "public_rtb_asso" {
  count          = var.subnet_amount
  route_table_id = aws_route_table.public_rtb.id
  subnet_id      = element(aws_subnet.public.*.id, count.index)
}

# private route table association
resource "aws_route_table_association" "private_rtb_asso" {
  depends_on     = [aws_route_table.private_rtb]
  count          = var.eks-subnet-type == "private" || var.fargate-staging-subnet-type == "private" || var.fargate-subnet-type == "private" ? var.subnet_amount : 0
  route_table_id = element(aws_route_table.private_rtb.*.id, count.index)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
}
