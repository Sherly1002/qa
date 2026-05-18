variable "resource_group_name" {
  type        = string
  description = "The name of the Azure Resource Group"
  default     = "rg-prod-network-001"
}

variable "location" {
  type        = string
  description = "The Azure region for resources"
  default     = "East US"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the VNet"
  default     = ["10.0.0.0/16"]
}

variable "prefix" {
  type        = string
  description = "A prefix used for all resources in this deployment"
  default     = "prod"
}
