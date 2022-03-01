module "cluster" {
  source = "./module"

  server_url = var.server_url
  login_user = "apikey"
  login_password = var.ibmcloud_api_key
  login_token = ""
}

resource null_resource cluster_config {
  provisioner "local-exec" {
    command = "echo -n '${module.cluster.config_file_path}' > .kubeconfig"
  }
}
