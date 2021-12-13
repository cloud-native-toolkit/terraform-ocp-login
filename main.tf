locals {
  cluster_config_dir    = pathexpand("~/.kube")
  cluster_config        = "${local.cluster_config_dir}/config"
  tmp_dir               = "${path.cwd}/.tmp"
}

resource "null_resource" "create_dirs" {
  provisioner "local-exec" {
    command = "mkdir -p ${local.tmp_dir}"
  }
}

resource "null_resource" "oc_login" {
  count = var.skip ? 0 : 1

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/oc-login.sh '${var.server_url}'"

    environment = {
      USERNAME = var.login_user
      PASSWORD = var.login_password
      TOKEN = var.login_token
    }
  }
}
