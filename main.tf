locals {
  cluster_config_dir    = "${path.cwd}/.tmp/.kube"
  cluster_config        = "${local.cluster_config_dir}/config"
  tmp_dir               = "${path.cwd}/.tmp/cluster"
}

module setup_clis {
  source = "cloud-native-toolkit/clis/util"
  version = "1.9.3"

  clis = ["oc"]
}

data external oc_login {
  count = var.skip ? 0 : 1

  program = ["bash", "${path.module}/scripts/oc-login.sh"]

  query = {
    bin_dir = module.setup_clis.bin_dir
    serverUrl = var.server_url
    username = var.login_user
    password = var.login_password
    token = var.login_token
    kube_config = local.cluster_config
    tmp_dir = local.tmp_dir
  }
}
