resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  security_groups  = [var.security_group_id]
  associate_public_ip_address = var.associate_public_ip_address

  user_data = var.user_data

  tags = {
    Name = var.name
  }
}

output "instance_id" {
  value = aws_instance.this.id
}
