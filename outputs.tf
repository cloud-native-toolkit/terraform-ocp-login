output "id" {
  value       = data.external.oc_login.result.serverUrl
  description = "ID of the cluster."
}

output "name" {
  value       = "cluster"
  description = "Name of the cluster"
  depends_on  = [data.external.oc_login]
}

output "region" {
  value       = ""
  description = "Region of the cluster"
  depends_on  = [data.external.oc_login]
}

output "resource_group_name" {
  value       = ""
  description = "Resource group of the cluster"
  depends_on  = [data.external.oc_login]
}

output "server_url" {
  value       = data.external.oc_login.result.serverUrl
  description = "The url of the control server."
}

output "config_file_path" {
  value       = data.external.oc_login.result.kube_config
  description = "Path to the config file for the cluster."
}

output "platform" {
  value = {
    kubeconfig = data.external.oc_login.result.kube_config
    type       = "openshift"
    type_code  = "ocp4"
    version    = var.cluster_version
    ingress    = var.ingress_subdomain
    tls_secret = var.tls_secret_name
  }
  description = "Configuration values for the cluster platform"
  depends_on  = [data.external.oc_login]
}
