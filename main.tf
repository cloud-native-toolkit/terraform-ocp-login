locals {
  cluster_config_dir    = pathexpand("~/.kube")
  cluster_config        = "${local.cluster_config_dir}/config"
  tmp_dir               = "${path.cwd}/.tmp/cluster"
}

data external oc_login {
  count = var.skip ? 0 : 1

  program = ["bash", "${path.module}/scripts/oc-login.sh"]

  query = {
    serverUrl = var.server_url
    username = var.login_user
    password = var.login_password
    token = var.login_token
    kube_config = local.cluster_config
    tmp_dir = local.tmp_dir
  }
}
