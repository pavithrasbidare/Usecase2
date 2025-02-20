variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "name" {
  description = "Name tag for the security group"
  type        = string
  default     = "example-sg" 
}
