terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.0.0"
    }
  }
}

#
#Configure the Azure provider#
#

provider "azurerm" {
  features {}

# client_id = ""
# client_secret = ""
# subscription_id = ""
# tenant_id = ""
}