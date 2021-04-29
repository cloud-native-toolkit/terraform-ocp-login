variable "server_url" {
  type        = string
  description = "The url for the OpenShift api"
  default     = ""
}

variable "user" {
  type        = string
  description = "Username for login"
  default     = ""
}

variable "password" {
  type        = string
  description = "Password for login"
  default     = ""
}

variable "token" {
  type        = string
  description = "Token used for authentication"
  default     = ""
}

variable "skip" {
  type        = bool
  description = "Flag indicating that the cluster login has already been performed"
  default     = false
}
