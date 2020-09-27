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
    key                  = "terraformvmwithlb.tfstate"
  }
}


resource "azurerm_resource_group" "ResourceGroup" {
  name     =  var.ResourceGroup
  location =  var.Location
} 

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "Vnet" {
  name                = var.VirtualNetwork
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  location            = azurerm_resource_group.ResourceGroup.location
  address_space       = ["10.0.0.0/16"]
}


resource "azurerm_subnet" "Subnet" {
  name                 = var.Subnet
  resource_group_name  = azurerm_resource_group.ResourceGroup.name
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefix       = "10.0.0.0/24"

}

resource "azurerm_storage_account" "Storageaccount" {
  name                     = var.StorageAccount
  resource_group_name      = azurerm_resource_group.ResourceGroup.name
  location                 = azurerm_resource_group.ResourceGroup.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

}

resource "azurerm_public_ip" "PIP" {
  count               = var.numbercount
  name                = "vm-ip-${count.index}"
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  location            = azurerm_resource_group.ResourceGroup.location
  allocation_method   = "Static"
  sku                 = "Standard"

}

resource "azurerm_network_security_group" "NSG" {
  name                = var.NSG
  location            = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name

  security_rule {
    name                       = "test123"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = 3389
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}


resource "azurerm_network_interface" "NIC" {
  count               = var.numbercount
  name                = "vm-nic-${count.index}"
  location            = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name

  ip_configuration {
    name                          = "NICIP"
    subnet_id                     = azurerm_subnet.Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.PIP.*.id, count.index)
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "niclbbackendpoolassociation" {
  count               = var.numbercount
  network_interface_id    = azurerm_network_interface.NIC[count.index].id
  ip_configuration_name   = "NICIP"
  backend_address_pool_id = azurerm_lb_backend_address_pool.LBBackEnd.id
}

resource "azurerm_availability_set" "avset" {
  name                = var.AvailabilitySet
  location            = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  platform_update_domain_count = 4
  platform_fault_domain_count = 3
  managed                     = true
}

resource "azurerm_public_ip" "lbpublicIP" {
  name                = var.lbpublicIP
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  location            = azurerm_resource_group.ResourceGroup.location
  allocation_method   = "Static"
  sku                 = "Standard"

}
resource "azurerm_lb" "LoadBalancer" {
  name                = var.LoadBalancer
  location            = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = var.LBPIP
    public_ip_address_id = azurerm_public_ip.lbpublicIP.id
  }
}

resource "azurerm_lb_backend_address_pool" "LBBackEnd" {
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  loadbalancer_id     = azurerm_lb.LoadBalancer.id
  name                = var.BackEndAddressPool
}

resource "azurerm_lb_rule" "LBrule" {
  resource_group_name            = azurerm_resource_group.ResourceGroup.name
  loadbalancer_id                = azurerm_lb.LoadBalancer.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 3390
  backend_port                   = 3390
  frontend_ip_configuration_name = var.LBPIP
  disable_outbound_snat          = true
}
/*
resource "azurerm_lb_outbound_rule" "lboutbound" {
  resource_group_name     = azurerm_resource_group.ResourceGroup.name
  loadbalancer_id         = azurerm_lb.LoadBalancer.id
  name                    = var.lboutbound
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.LBBackEnd.id

  frontend_ip_configuration {
    name = var.LBPIP
  }
}*/
  resource "azurerm_lb_nat_rule" "LBNATrule" {
  resource_group_name            = azurerm_resource_group.ResourceGroup.name
  loadbalancer_id                = azurerm_lb.LoadBalancer.id
  name                           = "RDPAccess"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = var.LBPIP
 }

resource "azurerm_lb_nat_pool" "LBNATpool" {
  resource_group_name            = azurerm_resource_group.ResourceGroup.name
  loadbalancer_id                = azurerm_lb.LoadBalancer.id
  name                           = var.LBNATpool
  protocol                       = "Tcp"
  frontend_port_start            = 80
  frontend_port_end              = 81
  backend_port                   = 8080
  frontend_ip_configuration_name = var.LBPIP
 }
resource "azurerm_lb_probe" "LBprobe" {
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  loadbalancer_id     = azurerm_lb.LoadBalancer.id
  name                = var.LBprobe
  protocol            = "Tcp"
  port                = 8080
}


resource "azurerm_windows_virtual_machine" "VM" {
  name                = "vm-${count.index}"
  count 		          = var.numbercount
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  location            = azurerm_resource_group.ResourceGroup.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  availability_set_id = azurerm_availability_set.avset.id
  network_interface_ids = [
   element(azurerm_network_interface.NIC.*.id, count.index)
  ]

  os_disk {
    name                 = "osdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
    boot_diagnostics {
    storage_account_uri = azurerm_storage_account.Storageaccount.primary_blob_endpoint
  }
  }


