variable "prefix" {
  default = "tfvmex"
}

resource "azurerm_resource_group" "pavan-westeurope-dev-rg" {
  name     = "pavan-westeurope-dev-rg-01"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "pavan-westeurope-dev-vnet-01"
  address_space       = ["10.0.0.0/16"]
  location            = "West Europe"
  resource_group_name = "pavan-westeurope-dev-rg-01"
}

resource "azurerm_subnet" "subnet" {
  name                 = "pavan-westeurope-dev-subnet-01"
  resource_group_name  = "pavan-westeurope-dev-rg-01"
  virtual_network_name = "pavan-westeurope-dev-vnet-01"
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "netwrokinterface" {
  name                = "pavan-westeurope-dev-networkinterface-01"
  location            = "West Europe"
  resource_group_name = "pavan-westeurope-dev-rg-01"

ip_configuration {
  name                          = "testconfiguration1"
  subnet_id                     = azurerm_subnet.subnet.id
  private_ip_address_allocation = "Dynamic"
}
}
resource "azurerm_network_security_group" "nsg" {
  name                = "pavan-westeurope-dev-nsg-01"
  location            = "West Europe"
  resource_group_name = "pavan-westeurope-dev-rg-01"
  

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.2.0/24"
  }

  tags = {
    environment = "Production"
  }
}
resource "azurerm_subnet_network_security_group_association" "Associate" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
resource "azurerm_virtual_machine" "vm" {
  name                  = "pavan-easteurope-dev-vm-01"
  location              = "WestEurope"
  resource_group_name   = "pavan-westeurope-dev-rg-01"
  network_interface_ids = [azurerm_network_interface.netwrokinterface.id]
  vm_size               = "Standard_DS1_v2"

# Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}