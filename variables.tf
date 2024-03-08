variable "provider_token" {
  type      = string
  sensitive = true
  default   = "azurerm"
}

variable "resource_group_name" {
  default = "rg-terraform"
}

variable "host_os" {
  type = string
}
