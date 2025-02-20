variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "Usecase2-VPC"
}
