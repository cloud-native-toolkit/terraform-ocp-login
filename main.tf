locals {
  cluster_config_dir    = "${path.cwd}/.tmp/.kube"
  cluster_config        = "${local.cluster_config_dir}/config"
  tmp_dir               = "${path.cwd}/.tmp/cluster"
  default_cluster_config = pathexpand("~/.kube/config")
}

module setup_clis {
  source = "cloud-native-toolkit/clis/util"
  version = "1.10.0"

  clis = ["jq", "oc", "ibmcloud-ks"]
}

data external ibmcloud_login {
  program = ["bash", "${path.module}/scripts/ibmcloud-login.sh"]

  query = {
    bin_dir = module.setup_clis.bin_dir
    skip = var.skip
    tmp_dir = local.tmp_dir
    token = var.login_token
    username = var.login_user
    password = var.login_password
    serverUrl = var.server_url
    kube_config = !var.skip ? local.cluster_config : local.default_cluster_config
  }
}

data external oc_login {
  program = ["bash", "${path.module}/scripts/oc-login.sh"]

  query = {
    bin_dir = module.setup_clis.bin_dir
    skip = data.external.ibmcloud_login.result.skip
    serverUrl = data.external.ibmcloud_login.result.serverUrl
    username = data.external.ibmcloud_login.result.username
    password = data.external.ibmcloud_login.result.password
    token = data.external.ibmcloud_login.result.token
    kube_config = data.external.ibmcloud_login.result.kube_config
    tmp_dir = local.tmp_dir
  }
}
