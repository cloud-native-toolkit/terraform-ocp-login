output "id" {
  value       = var.server_url
  description = "ID of the cluster."
  depends_on  = [null_resource.oc_login]
}

output "server_url" {
  value       = var.server_url
  description = "The url of the control server."
  depends_on  = [null_resource.oc_login]
}

output "config_file_path" {
  value       = "${local.cluster_config_dir}/config"
  description = "Path to the config file for the cluster."
  depends_on  = [null_resource.oc_login]
}

output "platform" {
  value = {
    kubeconfig = "${local.cluster_config_dir}/config"
    type       = "openshift"
    type_code  = "ocp4"
    version    = ""
    ingress    = ""
    tls_secret = ""
  }
  description = "Configuration values for the cluster platform"
  depends_on  = [null_resource.oc_login]
}
