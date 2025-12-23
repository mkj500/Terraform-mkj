resource "aws_vpc" "vpc-tf" {
  cidr_block = "10.0.0.0/16"

    tags = {
    Name = "vpc-tf"
    }
}

resource "aws_subnet" "public-tf-mkj1" {
  vpc_id     = aws_vpc.vpc-tf.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-tf-mkj1"
  }
}

resource "aws_subnet" "public-tf-mkj2" {
  vpc_id     = aws_vpc.vpc-tf.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "public-tf-mkj2"
  }
}

resource "aws_subnet" "private-tf-mkj1" {
  vpc_id     = aws_vpc.vpc-tf.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-tf-mkj1"
  }
}

resource "aws_subnet" "private-tf-mkj2" {
  vpc_id     = aws_vpc.vpc-tf.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-tf-mkj2"
  }
}

resource "aws_internet_gateway" "igw-mkj-tf" {
  vpc_id = aws_vpc.vpc-tf.id

  tags = {
    Name = "igw-mkj-tf"
  }
}

resource "aws_route_table" "mkjtf-rt" {
  vpc_id = aws_vpc.vpc-tf.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-mkj-tf.id
  }

  tags = {
    Name = "igw-mkj-tf"
  }
}

resource "aws_route_table_association" "mkj-tf-rta-public1" {
  subnet_id      = aws_subnet.public-tf-mkj1.id
  route_table_id = aws_route_table.mkjtf-rt.id
}

resource "aws_route_table_association" "mkj-tf-rta-public2" {
  subnet_id      = aws_subnet.public-tf-mkj2.id
  route_table_id = aws_route_table.mkjtf-rt.id
}

resource "aws_eip" "nat1" {
  domain   = "vpc"
}

resource "aws_eip" "nat2" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat-pub1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public-tf-mkj1.id

  tags = {
    Name = "nat-pub1"
  }
}

resource "aws_nat_gateway" "nat-pub2" {
  allocation_id = aws_eip.nat2.id
  subnet_id     = aws_subnet.public-tf-mkj2.id

  tags = {
    Name = "nat-pub2"
  }
    # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw-mkj-tf]
}

resource "aws_route_table" "mkj-privrt1" {
  vpc_id = aws_vpc.vpc-tf.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-pub1.id
  }

  tags = {
    Name = "mkj-privrt1"
  }
}

resource "aws_route_table" "mkj-privrt2" {
  vpc_id = aws_vpc.vpc-tf.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-pub2.id
  }

  tags = {
    Name = "mkj-privrt2"
  }
}
resource "aws_route_table_association" "mkj-tf-rta-priv1" {
  subnet_id      = aws_subnet.private-tf-mkj1.id
  route_table_id = aws_route_table.mkj-privrt1.id
}

resource "aws_route_table_association" "mkj-tf-rta-private2" {
  subnet_id      = aws_subnet.private-tf-mkj2.id
  route_table_id = aws_route_table.mkj-privrt2.id
}
