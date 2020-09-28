provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=2.4.0"

  subscription_id = "427be391-4ec5-496f-8463-3e4a8029d2d9"
  client_id       = "06609a8b-1190-4ae9-8ba7-f7847da31536"
  client_secret   = "_6eql2I7Y__vwJ~lW6Lz4JX0.B78IN0HZN"
  tenant_id       = "e359cc3c-2e76-4c7c-8776-51cb054c4864"

  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "NetworkWatcherRG"
    storage_account_name = "terraform23092020"
    container_name       = "terraform"
    key                  = "tfdirrecoveryupdated.tfstate"
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

# Create a Public IP within the USA resource group
resource "azurerm_public_ip" "USAPIP" {
  count               = var.numbercount
  name                = "vm-ip-usa-${count.index}"
  resource_group_name = azurerm_resource_group.RG1.name
  location            = azurerm_resource_group.RG1.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create a Public IP within the UK resource group
resource "azurerm_public_ip" "UKPIP" {
  count               = var.numbercount
  name                = "vm-ip-uk-${count.index}"
  resource_group_name = azurerm_resource_group.RG2.name
  location            = azurerm_resource_group.RG2.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create a network Security group within the USA resource group
resource "azurerm_network_security_group" "USNSG" {
  name                = var.USNSG
  location            = azurerm_resource_group.RG1.location
  resource_group_name = azurerm_resource_group.RG1.name

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
resource "azurerm_subnet_network_security_group_association" "USSubnetandnsgassociation" {
  subnet_id                 = azurerm_subnet.Subnetus.id
  network_security_group_id = azurerm_network_security_group.USNSG.id
}

# Create a network Security group within the UK resource group
resource "azurerm_network_security_group" "UKNSG" {
  name                = var.UKNSG
  location            = azurerm_resource_group.RG2.location
  resource_group_name = azurerm_resource_group.RG2.name

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
resource "azurerm_subnet_network_security_group_association" "UKSubnetandnsgassociation" {
  subnet_id                 = azurerm_subnet.Subnetuk.id
  network_security_group_id = azurerm_network_security_group.UKNSG.id
}

# Create a network Interface within the USA resource group
resource "azurerm_network_interface" "USANIC" {
  count               = var.numbercount
  name                = "vm-nic-usa-${count.index}"
  location            = azurerm_resource_group.RG1.location
  resource_group_name = azurerm_resource_group.RG1.name

  ip_configuration {
    name                          = "USANICIP"
    subnet_id                     = azurerm_subnet.Subnetus.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.USAPIP.*.id, count.index)
  }
}

# Create a network Interface within the UK resource group
resource "azurerm_network_interface" "UKNIC" {
  count               = var.numbercount
  name                = "vm-nic-uk-${count.index}"
  location            = azurerm_resource_group.RG2.location
  resource_group_name = azurerm_resource_group.RG2.name

  ip_configuration {
    name                          = "UKNICIP"
    subnet_id                     = azurerm_subnet.Subnetuk.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.UKPIP.*.id, count.index)
  }
}

# Create a availability set within the USA resource group
resource "azurerm_availability_set" "usavset" {
  name                = var.usavset
  location            = azurerm_resource_group.RG1.location
  resource_group_name = azurerm_resource_group.RG1.name
  platform_update_domain_count = 3
  platform_fault_domain_count = 2
  managed                     = true
}

# Create a availability set within the UK resource group
resource "azurerm_availability_set" "ukavset" {
  name                = var.ukavset
  location            = azurerm_resource_group.RG2.location
  resource_group_name = azurerm_resource_group.RG2.name
  platform_update_domain_count = 3
  platform_fault_domain_count = 2
  managed                     = true
}

# Create a load balancer within the USA resource group
resource "azurerm_lb" "USALB" {
  name                = var.USALB
  location            = azurerm_resource_group.RG1.location
  resource_group_name = azurerm_resource_group.RG1.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = var.LBFrontEndIP
    subnet_id            = azurerm_subnet.Subnetus.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version = "IPv4"
  }
}

resource "azurerm_lb_backend_address_pool" "uslbbep" {
  resource_group_name = azurerm_resource_group.RG1.name
  loadbalancer_id     = azurerm_lb.USALB.id
  name                = var.USABackendPool
}

resource "azurerm_lb_rule" "uslbrule" {
  resource_group_name            = azurerm_resource_group.RG1.name
  loadbalancer_id                = azurerm_lb.USALB.id
  name                           = "uslbrule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = var.LBFrontEndIP
  backend_address_pool_id        = azurerm_lb_backend_address_pool.uslbbep.id
  probe_id                       = azurerm_lb_probe.USLBprobe.id
  disable_outbound_snat          = true
}

resource "azurerm_lb_probe" "USLBprobe" {
  resource_group_name = azurerm_resource_group.RG1.name
  loadbalancer_id     = azurerm_lb.USALB.id
  name                = var.USLBprobe
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
}

resource "azurerm_network_interface_backend_address_pool_association" "USAniclbbackendpoolassociation" {
  count               = var.numbercount
  network_interface_id    = azurerm_network_interface.USANIC[count.index].id
  ip_configuration_name   = "USANICIP"
  backend_address_pool_id = azurerm_lb_backend_address_pool.uslbbep.id
}

# Create a load balancer within the UK resource group
resource "azurerm_lb" "UKLB" {
  name                = var.UkLB
  location            = azurerm_resource_group.RG2.location
  resource_group_name = azurerm_resource_group.RG2.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = var.UKLBFrontEndIP
    subnet_id            = azurerm_subnet.Subnetuk.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version = "IPv4"
  }
}

resource "azurerm_lb_backend_address_pool" "uklbbep" {
  resource_group_name = azurerm_resource_group.RG2.name
  loadbalancer_id     = azurerm_lb.UKLB.id
  name                = var.UKBackendPool
}

resource "azurerm_lb_rule" "uklbrule" {
  resource_group_name            = azurerm_resource_group.RG2.name
  loadbalancer_id                = azurerm_lb.UKLB.id
  name                           = "uklbrule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = var.UKLBFrontEndIP
  backend_address_pool_id        = azurerm_lb_backend_address_pool.uklbbep.id
  probe_id                       = azurerm_lb_probe.UKLBprobe.id
  disable_outbound_snat          = true
}

resource "azurerm_lb_probe" "UKLBprobe" {
  resource_group_name = azurerm_resource_group.RG2.name
  loadbalancer_id     = azurerm_lb.UKLB.id
  name                = var.UKLBprobe
  protocol            = "Tcp"
  port                = 8080
}

resource "azurerm_network_interface_backend_address_pool_association" "UKniclbbackendpoolassociation" {
  count               = var.numbercount
  network_interface_id    = azurerm_network_interface.UKNIC[count.index].id
  ip_configuration_name   = "UKNICIP"
  backend_address_pool_id = azurerm_lb_backend_address_pool.uklbbep.id
}

# Create a Virtual MAchine within the USA resource group
resource "azurerm_windows_virtual_machine" "USAVM" {
  name                = "vm-${count.index}"
  count 		      = var.numbercount
  resource_group_name = azurerm_resource_group.RG1.name
  location            = azurerm_resource_group.RG1.location
  size                = "Standard_B1s"
  admin_username      = var.adminusername
  admin_password      = var.adminpassword
  availability_set_id = azurerm_availability_set.usavset.id
  network_interface_ids = [
   element(azurerm_network_interface.USANIC.*.id, count.index)
  ]

  os_disk {
    name                 = "usosdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  }

  # Create a Virtual MAchine within the UK resource group
resource "azurerm_windows_virtual_machine" "UKVM" {
  name                = "vm-${count.index}"
  count 		      = var.numbercount
  resource_group_name = azurerm_resource_group.RG2.name
  location            = azurerm_resource_group.RG2.location
  size                = "Standard_B1s"
  admin_username      = var.adminusername
  admin_password      = var.adminpassword
  availability_set_id = azurerm_availability_set.ukavset.id
  network_interface_ids = [
   element(azurerm_network_interface.UKNIC.*.id, count.index)
  ]

  os_disk {
    name                 = "ukosdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  }