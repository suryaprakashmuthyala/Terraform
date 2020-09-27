provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=2.4.0"

  subscription_id = ""
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""

  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "NetworkWatcherRG"
    storage_account_name = "terraform23092020"
    container_name       = "terraform"
    key                  = "tfdr.tfstate"
  }
}

resource "azurerm_resource_group" "RG1" {
  name     =  var.RG1
  location =  var.location1
} 

resource "azurerm_resource_group" "RG2" {
  name     =  var.RG2
  location =  var.location2
}

# Create a virtual network within the USA resource group
resource "azurerm_virtual_network" "Vnetus" {
  name                = var.vnetus
  resource_group_name = azurerm_resource_group.RG1.name
  location            = azurerm_resource_group.RG1.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "Subnetus" {
  name                 = var.subnetus
  resource_group_name  = azurerm_resource_group.RG1.name
  virtual_network_name = azurerm_virtual_network.Vnetus.name
  address_prefix       = "10.0.0.0/24"
}

# Create a virtual network within the Uk resource group
resource "azurerm_virtual_network" "vnetuk" {
  name                = var.vnetuk
  resource_group_name = azurerm_resource_group.RG2.name
  location            = azurerm_resource_group.RG2.location
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "Subnetuk" {
  name                 = var.subnetuk
  resource_group_name  = azurerm_resource_group.RG2.name
  virtual_network_name = azurerm_virtual_network.vnetuk.name
  address_prefix       = "192.168.0.0/24"
}
