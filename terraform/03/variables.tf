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

variable "task_cpu" {
  description = "Task CPU units (256 = 0.25 vCPU)."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Task memory in MiB. Must be a valid combination with task_cpu."
  type        = number
  default     = 512
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention."
  type        = number
  default     = 7
}

variable "cpu_architecture" {
  description = "The CPU architecture for the ECS task (e.g., X86_64, ARM64)."
  type        = string
  default     = "X86_64"
}
variable "container_image" {
  description = "The Docker image for the container"
  type        = string
}
