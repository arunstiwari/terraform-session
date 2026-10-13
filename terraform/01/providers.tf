terraform {
  required_version = ">= 1.0.0"

  required_providers {
    local = {
      source = "hashicorp/local"
    }

    random = {
      source = "hashicorp/random"
    }
  }

}
