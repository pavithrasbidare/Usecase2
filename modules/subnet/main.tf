resource "aws_subnet" "this" {
  vpc_id            = var.vpc_id
  cidr_block        = var.cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = var.name
  }
}

output "subnet_id" {
  value = aws_subnet.this.id
}
