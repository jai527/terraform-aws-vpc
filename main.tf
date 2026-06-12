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

# roboshop-dev-private
  tags = merge(
        {
            Name = "${var.project}-${var.environment}-private"

        },

        var.private_route_table_tags
    )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

# roboshop-dev-database
  tags = merge(
        {
            Name = "${var.project}-${var.environment}-database"

        },

        var.database_route_table_tags
    )
}


# Public Route → IGW
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}


# NAT + EIP
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    {
        Name = "${var.project}-${var.environment}-nat"
    },
        var.eip_tags
  )
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id      # we are creating this is us-east-1a AZ

  tags = merge(
    {
        Name ="${var.project}-${var.environment}"
    },
        var.nat_gateway_tags
  )
}

# Private Route → NAT
resource "aws_route" "private" {
    route_table_id         = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         =  aws_nat_gateway.main.id
}

# Database Route → NAT
resource "aws_route" "database" {
  route_table_id         = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         =  aws_nat_gateway.main.id
}


# Associations

resource "aws_route_table_association" "public" {
  count = length(var.public_cidr)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_cidr)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_cidr)

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}
