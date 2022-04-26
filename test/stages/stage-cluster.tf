module "cluster" {
  source = "./module"

  server_url = var.server_url
  login_user = var.cluster_username
  login_password = var.cluster_password
  login_token = var.cluster_token
  ingress_subdomain = var.ingress_subdomain
}

resource null_resource cluster_config {
  provisioner "local-exec" {
    command = "echo -n '${module.cluster.config_file_path}' > .kubeconfig"
  }
}
