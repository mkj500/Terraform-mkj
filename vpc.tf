locals {
    public_cidr = ["10.0.0.0/24","10.0.1.0/24","10.0.2.0/24"]
    private_cidr = ["10.0.100.0/24","10.0.101.0/24","10.0.102.0/24"]
    availability_zones = ["us-east-1a","us-east-1b","us-east-1c"]
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

    tags = {
    Name = "main"
    }
}

resource "aws_subnet" "public-mkj" {
    count = length(local.public_cidr)

  vpc_id     = aws_vpc.main.id
  cidr_block = local.public_cidr[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "public-mkj${count.index+1}"
  }
}

resource "aws_subnet" "private-mkj" {
    count = length(local.public_cidr)

  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_cidr[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "private-mkj${count.index+1}"
  }
}


resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "public" {
    count = length(local.public_cidr)

  subnet_id      = aws_subnet.public-mkj[count.index].id 
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
    count = length(local.public_cidr)

    domain = "vpc"

  tags = {
    Name = "nat${count.index}"
  }
}

resource "aws_nat_gateway" "main" {
count = length(local.public_cidr)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public-mkj[count.index].id

  tags = {
    Name = "main${count.index}"
  }

    # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "private" {
    count = length(local.private_cidr)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "private${count.index+1}"
  }
}

resource "aws_route_table_association" "private" {
    count = length(local.private_cidr)

  subnet_id      = aws_subnet.private-mkj[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

