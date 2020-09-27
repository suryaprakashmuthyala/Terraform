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
  frontend_port                  = 3390
  backend_port                   = 3390
  frontend_ip_configuration_name = var.LBFrontEndIP
  disable_outbound_snat          = true
}

  resource "azurerm_lb_nat_rule" "USLBNATrule" {
  resource_group_name            = azurerm_resource_group.RG1.name
  loadbalancer_id                = azurerm_lb.USALB.id
  name                           = "RDPAccess"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = var.LBFrontEndIP
 }

 resource "azurerm_lb_nat_pool" "USLBNATpool" {
  resource_group_name            = azurerm_resource_group.RG1.name
  loadbalancer_id                = azurerm_lb.USALB.id
  name                           = var.USLBNATpool
  protocol                       = "Tcp"
  frontend_port_start            = 80
  frontend_port_end              = 81
  backend_port                   = 8080
  frontend_ip_configuration_name = var.LBFrontEndIP
 }
resource "azurerm_lb_probe" "USLBprobe" {
  resource_group_name = azurerm_resource_group.RG1.name
  loadbalancer_id     = azurerm_lb.USALB.id
  name                = var.USLBprobe
  protocol            = "Tcp"
  port                = 8080
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
  frontend_port                  = 3390
  backend_port                   = 3390
  frontend_ip_configuration_name = var.UKLBFrontEndIP
  disable_outbound_snat          = true
}

  resource "azurerm_lb_nat_rule" "UKLBNATrule" {
  resource_group_name            = azurerm_resource_group.RG2.name
  loadbalancer_id                = azurerm_lb.UKLB.id
  name                           = "RDPAccess"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = var.UKLBFrontEndIP
 }

 resource "azurerm_lb_nat_pool" "UkLBNATpool" {
  resource_group_name            = azurerm_resource_group.RG2.name
  loadbalancer_id                = azurerm_lb.UKLB.id
  name                           = var.UKLBNATpool
  protocol                       = "Tcp"
  frontend_port_start            = 80
  frontend_port_end              = 81
  backend_port                   = 8080
  frontend_ip_configuration_name = var.UKLBFrontEndIP
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