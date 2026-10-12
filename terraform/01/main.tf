locals {
  prefix = "$lower(var.app_environment)-app"

  log_level = var.app_environment == "production" ? "info" : "debug"

  service_names = [for s in var.services : upper(s.name)]

  public_services = [for s in var.services : upper(s.name) if s.public]

  // Create a map of service names to their ports
  service_ports_map = { for s in var.services : upper(s.name) => s.port }

  // Create a list of service ports
  service_ports = [for s in var.services : s.port]

  // splat operator to get all service ports 
  service_ports_splat = var.services[*].port

  summary = {
    count        = length(var.services)
    public_count = length(local.public_services)
    highest_port = max(local.service_ports...)
    joined       = join(",", local.service_names)
    merged_tags  = merge({ env = local.prefix }, { managed_by = "terraform" })
    has_billing  = contains(keys(var.features), "billing")
    timestamp    = formatdate("YYYY-MM-DD", plantimestamp())
  }
}

resource "local_file" "summary_json" {
  content  = jsonencode(local.summary)
  filename = "${path.module}/output/summary.json"
}

// template for generating configuration files
resource "local_file" "nginx_template" {
  filename = "${path.module}/output/nginx.conf"
  content = templatefile("${path.module}/templates/nginx.conf.tpl", {
    services  = var.services,
    log_level = local.log_level
  })
}


resource "local_file" "example" {
  content         = var.database_username
  filename        = "${path.module}/hello.txt"
  file_permission = "0644"
}


resource "local_file" "app_configuration" {
  filename = "${path.module}/output/app_configuration.txt"
  content  = <<-EOT
    app.username: ${var.app_username}
    app.password: ${var.app_password}
    app.replicas: ${var.app_replicas}
    app.environment: ${local.prefix}
    feature.metrics=${var.features["metrics"]}
    owner.team: ${var.owner.team}
    owner.email: ${var.owner.email}

EOT
}


resource "local_file" "file1" {
  count    = var.app_replicas
  filename = "${path.module}/output/file1_${count.index}.txt"
  content  = "This is file1 content"
}

// Using foreach
resource "local_file" "file1_foreach" {
  for_each = local.service_ports_map
  filename = "${path.module}/output/file1_${each.value}.txt"
  content  = "This is file1 content for replica ${each.value}"
}


module "greeting" {
  source      = "./modules/app-config"
  app_name    = "greeting"
  port        = 8080
  environment = var.app_environment
  output_dir  = "${path.module}/output"
}

module "billing" {
  source = "./modules/app-config"

  for_each = { test = 8101, prod = 8102 }

  app_name    = "billing"
  environment = each.key
  port        = each.value
  output_dir  = "${path.module}/output"
  extra_settings = {
    "billing_currency" = "USD"
  }
}



