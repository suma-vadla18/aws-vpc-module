resource "aws_vpc" "main"{
    cidr_block = var.vpc_cidr
    instance_tenancy = "default"
    enable_dns_hostnames = true
    tags = local.vpc_final_tags
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = local.igw_final_tags
}

# Create a public subnet
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = local.az_names[count.index] # Use a valid AZ for your region
  # Automatically assign public IPs to instances launched in this subnet
  map_public_ip_on_launch = true 

  tags = merge ( local.common_tags,
    { 
       Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}" 
    },
    var.pubic_subnet_tags
  )
}

# Create a private subnet
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = local.az_names[count.index] # Use a valid AZ for your region
  tags = merge ( local.common_tags,
    { 
       Name = "${var.project}-${var.environment}-private-${local.az_names[count.index]}" 
    },
    var.private_subnet_tags
  )
}

# Create a database subnet
resource "aws_subnet" "database" {
  count = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidr[count.index]
  availability_zone = local.az_names[count.index] # Use a valid AZ for your region
  tags = merge ( local.common_tags,
    { 
       Name = "${var.project}-${var.environment}-database-${local.az_names[count.index]}" 
    },
    var.database_subnet_tags
  )
}

# Create a route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge (
            local.common_tags,
            {
                Name = "${var.project}-${var.environment}-public"
            },
            var.public_route_table_tags
            )
}

# Create a route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge (
            local.common_tags,
            {
                Name = "${var.project}-${var.environment}-private"
            },
            var.private_route_table_tags
            )
}

# Create a route table for database subnets
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge (
            local.common_tags,
            {
                Name = "${var.project}-${var.environment}-database"
            },
            var.database_route_table_tags
            )
}

