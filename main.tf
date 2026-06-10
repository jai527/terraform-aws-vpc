resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = local.common_tags

}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id                     # vpc accostaions

  tags = local.igw_final_tags
}

resource "aws_subnet" "public" {
    count    = length(var.public_cidr)
    vpc_id     = aws_vpc.main.id
    cidr_block = var.public_cidr[count.index]

  
tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-subnet-${count.index + 1}"
    }
  )

}