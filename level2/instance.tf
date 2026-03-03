data "aws_ami" "amazonlinux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

/*
resource "aws_instance" "public" {
  count = 2

  ami                         = data.aws_ami.amazonlinux.id
  instance_type               = "t3.micro"
  key_name                    = "main"
  subnet_id                   = data.terraform_remote_state.level1.outputs.public_subnet_id[count.index]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.public.id]
  user_data                   = file("user-data.sh")

  tags = {
    Name = "${var.env_code}-public"
  }
}

resource "aws_security_group" "public" {
  name        = "${var.env_code}-public"
  description = "Allow inbound SSH from your IP"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP form public"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-public"
  }
}

resource "aws_instance" "private" {
  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = "t3.micro"
  key_name               = "main"
  subnet_id              = data.terraform_remote_state.level1.outputs.private_subnet_id[0]
  vpc_security_group_ids = [aws_security_group.private.id]

  tags = {
    Name = "${var.env_code}-private"
  }
}
*/

resource "aws_security_group" "private" {
  name        = "${var.env_code}-private"
  description = "Allow VPC traffic"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description = "HTTP from load balancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.load_balancer.id] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-private"
  }
}

resource "aws_launch_template" "main" {
  name_prefix   = "${var.env_code}-"  # use name_prefix, not name
  image_id      = data.aws_ami.amazonlinux.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.private.id]

  user_data = base64encode(file("user-data.sh"))

  iam_instance_profile {
    name = aws_iam_instance_profile.main.name
  }
}

resource "aws_autoscaling_group" "main" {
  name_prefix = var.env_code
  min_size    = 2
  desired_capacity = 2
  max_size    = 4

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  vpc_zone_identifier = data.terraform_remote_state.level1.outputs.private_subnet_id

  target_group_arns = [aws_lb_target_group.main.arn]

  tag {
    key                 = "Name"
    value               = var.env_code
    propagate_at_launch = true
  }
}
