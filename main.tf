resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = local.vpc_final_tags

}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id                     # vpc accostaions

  tags = local.igw_final_tags
}
#### public subnet

 resource "aws_subnet" "public" {
    count    = length(var.public_cidr)
    vpc_id     = aws_vpc.main.id
    cidr_block = var.public_cidr[count.index]
    availability_zone = local.az_names[count.index]
    map_public_ip_on_launch = true

tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
    },
    var.public_subent_tags 
   ) 
 }

#### private subnet 
 resource "aws_subnet" "private" {
    count = length(var.private_cidr)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_cidr[count.index]
    availability_zone = local.az_names[count.index]
    map_public_ip_on_launch = false
    
    tags = merge(
        {
            Name = "${var.project}-${var.environment}-private-${local.az_names[count.index]}"

        },

        var.private_subnet_tags
    )
   
 }

 ####  Database subnet 
 resource "aws_subnet" "database" {
    count = length(var.database_cidr)
    vpc_id = aws_vpc.main.id
    cidr_block = var.database_cidr[count.index]
    availability_zone = local.az_names[count.index]
    map_public_ip_on_launch = false
    
    tags = merge(
        {
            Name = "${var.project}-${var.environment}-database-${local.az_names[count.index]}"

        },

        var.database_subnet_tags
    )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

# roboshop-dev-public
  tags = merge(
        {
            Name = "${var.project}-${var.environment}-public"

        },

        var.public_route_table_tags
    )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

# roboshop-dev-public
  tags = merge(
        {
            Name = "${var.project}-${var.environment}-private"

        },

        var.public_route_table_tags
    )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

# roboshop-dev-public
  tags = merge(
        {
            Name = "${var.project}-${var.environment}-database"

        },

        var.public_route_table_tags
    )
}