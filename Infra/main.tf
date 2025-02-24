provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source     = "../modules/vpc"
  cidr_block = var.vpc_cidr
  name       = "ExampleVPC"
}

module "public_subnet_1" {
  source            = "../modules/subnet"
  vpc_id            = module.vpc.vpc_id
  cidr_block        = var.subnet_cidrs[0]
  availability_zone = var.availability_zones[0]
  name              = "PublicSubnet-AZ1"
}

module "public_subnet_2" {
  source            = "../modules/subnet"
  vpc_id            = module.vpc.vpc_id
  cidr_block        = var.subnet_cidrs[1]
  availability_zone = var.availability_zones[1]
  name              = "PublicSubnet-AZ2"
}

module "public_subnet_3" {
  source            = "../modules/subnet"
  vpc_id            = module.vpc.vpc_id
  cidr_block        = var.subnet_cidrs[2]
  availability_zone = var.availability_zones[2]
  name              = "PublicSubnet-AZ3"
}

module "security_group" {
  source = "../modules/security_group"
  vpc_id = module.vpc.vpc_id
  name   = "example-sg"
}

output "security_group_id" {
  value = module.security_group.security_group_id
}

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = module.public_subnet_1.subnet_id
  route_table_id = module.vpc.route_table_id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = module.public_subnet_2.subnet_id
  route_table_id = module.vpc.route_table_id
}

resource "aws_route_table_association" "public_subnet_3" {
  subnet_id      = module.public_subnet_3.subnet_id
  route_table_id = module.vpc.route_table_id
}

module "homepage_instance" {
  source          = "../modules/ec2"
  ami_id          = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = module.public_subnet_1.subnet_id
  security_group_id = module.security_group.security_group_id
  associate_public_ip_address = true
  user_data       = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nginx
    echo "Welcome to the Homepage" > /usr/share/nginx/html/index.html
    systemctl start nginx
    systemctl enable nginx
  EOF
  name            = "Homepage"
}

module "images_instance" {
  source          = "../modules/ec2"
  ami_id          = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = module.public_subnet_2.subnet_id
  security_group_id = module.security_group.security_group_id
  associate_public_ip_address = true
  user_data       = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nginx
    echo "Image Gallery" > /usr/share/nginx/html/images.html
    systemctl start nginx
    systemctl enable nginx
  EOF
  name            = "Images"
}

module "register_instance" {
  source          = "../modules/ec2"
  ami_id          = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = module.public_subnet_3.subnet_id
  security_group_id = module.security_group.security_group_id
  associate_public_ip_address = true
  user_data       = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nginx
    echo "Register Here" > /usr/share/nginx/html/register.html
    systemctl start nginx
    systemctl enable nginx
  EOF
  name            = "Register"
}

module "homepage_tg" {
  source    = "../modules/target_group"
  name      = "homepage-tg"
  vpc_id    = module.vpc.vpc_id
  target_id = module.homepage_instance.instance_id
}

module "images_tg" {
  source    = "../modules/target_group"
  name      = "images-tg"
  vpc_id    = module.vpc.vpc_id
  target_id = module.images_instance.instance_id
}

module "register_tg" {
  source    = "../modules/target_group"
  name      = "register-tg"
  vpc_id    = module.vpc.vpc_id
  target_id = module.register_instance.instance_id
}

module "alb" {
  source                  = "../modules/alb"
  name                    = "example-alb"
  security_groups         = [module.security_group.security_group_id]
  subnets                 = [module.public_subnet_1.subnet_id, module.public_subnet_2.subnet_id, module.public_subnet_3.subnet_id]
  default_target_group_arn = module.homepage_tg.target_group_arn
}

resource "aws_lb_listener_rule" "images_rule" {
  listener_arn = module.alb.listener_arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = module.images_tg.target_group_arn
  }

  condition {
    path_pattern {
      values = ["/images*"]
    }
  }
}

resource "aws_lb_listener_rule" "register_rule" {
  listener_arn = module.alb.listener_arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = module.register_tg.target_group_arn
  }

  condition {
    path_pattern {
      values = ["/register*"]
    }
  }
}
