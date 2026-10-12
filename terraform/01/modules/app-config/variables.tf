
variable "app_name" {
  description = "The name of the application"
  type        = string
}

variable "environment" {
  description = "The environment in which the application is deployed"
  type        = string
}

variable "port" {
  description = "The port on which the application will run"
  type        = number
}

variable "output_dir" {
  description = "The directory where output files will be stored"
  type        = string
}

variable "extra_settings" {
  description = "Additional settings for the application"
  type        = map(string)
  default     = {}
}
