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