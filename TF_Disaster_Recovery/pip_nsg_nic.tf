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