
locals {
  settings = merge(
    {
      "app_name"    = var.app_name
      "environment" = var.environment
      "port"        = tostring(var.port)
      "output_dir"  = var.output_dir
    },
    var.extra_settings
  )
}

resource "local_file" "properties" {
  filename = "${local.settings["output_dir"]}${var.environment}/application.properties"
  content  = join("\n", [for k, v in local.settings : "${k}=${v}"])
}
