stage "cluster" {
  source = "./module"

  server_url = var.server_url
  user = "apikey"
  password = var.ibmcloud_api_key
}
