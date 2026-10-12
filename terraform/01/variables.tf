variable "app_username" {
  description = "Application username"
  type        = string
  default     = "app_user"
}

variable "app_password" {
  description = "Application password"
  type        = string
  default     = "app_password"
}

variable "app_replicas" {
  description = "Number of application replicas"
  type        = number
  default     = 1
}

variable "app_environment" {
  description = "Application environment"
  type        = string
  default     = "development"
}

variable "features" {
  description = "Feature flags"
  type        = map(bool)
  default = {
    metrics = true
  }
}

variable "owner" {
  description = "Owner information"
  type = object({
    team  = string
    email = string
  })
  default = {
    team  = "devops"
    email = "devops@example.com"
  }
}
variable "database_username" {
  description = "Database username"
  type        = string
  default     = "Hello, World!"
}


variable "services" {
  description = "List of services"
  type = list(object({
    name   = string
    port   = string
    public = bool
  }))
  default = [
    {
      name   = "service1"
      port   = "8080"
      public = true
    },
    {
      name   = "service2"
      port   = "9090"
      public = false
      }, {
      name   = "service3"
      port   = "7070"
      public = true
    }
  ]
}
