locals {
  cluster_config_dir    = "${path.cwd}/.tmp/.kube"
  cluster_config        = "${local.cluster_config_dir}/config"
  tmp_dir               = "${path.cwd}/.tmp/cluster"
  default_cluster_config = pathexpand("~/.kube/config")
  ca_cert               = var.ca_cert_file != null && var.ca_cert_file != "" ? base64encode(file(var.ca_cert_file)) : var.ca_cert
}

data clis_check clis {
  clis = ["jq", "oc", "ibmcloud-ks"]
}

data external ibmcloud_login {
  program = ["bash", "${path.module}/scripts/ibmcloud-login.sh"]

  query = {
    bin_dir = data.clis_check.clis.bin_dir
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
    bin_dir = data.clis_check.clis.bin_dir
    skip = data.external.ibmcloud_login.result.skip
    serverUrl = data.external.ibmcloud_login.result.serverUrl
    username = data.external.ibmcloud_login.result.username
    password = data.external.ibmcloud_login.result.password
    token = data.external.ibmcloud_login.result.token
    kube_config = data.external.ibmcloud_login.result.kube_config
    tmp_dir = local.tmp_dir
    ca_cert = local.ca_cert
  }
}

data external cluster_info {
  depends_on = [data.external.oc_login]

  program = ["bash", "${path.module}/scripts/get-cluster-info.sh"]

  query = {
    bin_dir = data.clis_check.clis.bin_dir
    kube_config = data.external.oc_login.result.kube_config
    default_ingress = var.ingress_subdomain
  }
}
