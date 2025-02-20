variable "name" {
  description = "ALB name"
  type        = string
}

variable "security_groups" {
  description = "Security groups for the ALB"
  type        = list(string)
}

variable "subnets" {
  description = "Subnets for the ALB"
  type        = list(string)
}

variable "default_target_group_arn" {
  description = "Default target group ARN"
  type        = string
}
