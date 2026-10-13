variable "name" {
  description = "The name prefix for resources"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID for the EC2 instance"
  type        = string
}

variable "region" {
  type    = string
  default = "eu-west-1"
}
