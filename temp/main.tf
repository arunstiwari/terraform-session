terraform{
  required_version = ">=1.10"
  
  required_providers {
    local = {
       source = "hashicorp/local"
       version = "~> 2.9"
    } 
    
    random = {
      source = "hashicorp/random"
      version = "~> 3.9"
    }
  }

}

resource "random_pet" "server" {
   length = 2
   keepers = {
     version = var.app_version
   }

}

variable "app_version" {
  type = string
  default = "1.0.0"	
}

resource "local_file" "server_config" {
  filename = "${path.module}/output/server.conf"
  content  = "name=${random_pet.server.id}\nversion=${var.app_version}\n" # implicit dependency
}

data "local_file" "app_requirements"{
  filename = "${path.module}/requirements.txt"
}
