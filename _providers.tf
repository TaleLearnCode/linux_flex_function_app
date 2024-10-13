# #############################################################################
# Providers Configuration
# #############################################################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.1"
    }
    azapi = {
      source = "Azure/azapi"
      version = "~> 1.15"
    }
  }
}