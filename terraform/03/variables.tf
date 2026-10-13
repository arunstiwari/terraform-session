variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy resources in"
  type        = string
}

variable "subnet_ids" {
  description = "The IDs of the subnets to deploy resources in"
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "An ALB needs subnets in at least two AZs."
  }
}

variable "app_source_dir" {

  description = "The directory containing the application source code"
  type        = string
  default     = "../../fastapi-app"
}

variable "dockerfile" {
  description = "The path to the Dockerfile"
  type        = string
  default     = "Dockerfile"
}

variable "container_port" {
  description = "The port on which the container listens"
  type        = number
  default     = 8000
}


