module "cluster" {
  source = "./module"

  server_url = var.server_url
  login_user = "apikey"
  login_password = var.ibmcloud_api_key
}
