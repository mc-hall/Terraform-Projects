resource "azurerm_resource_group" "rsg" {
    name = "AzureSystems002"
    location = "East US"
}

#Virtual Network space
resource "azurerm_virtual_network" "azurenetwork02" {
  name = "AzureNetwork02"
  address_space = [ "10.0.0.0/16" ]
  location = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name
}

#Subnet
resource "azurerm_subnet" "Subnet10" {
  name = "Subnet10"
  resource_group_name = azurerm_resource_group.rsg.name
  virtual_network_name = azurerm_virtual_network.azurenetwork02.name
  address_prefixes = [ "10.0.199.0/24" ]
}

#Network Interface
resource "azurerm_network_interface" "AzuresyslogNIC" {
  name = "AzureSyslogNIC"
  location = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name

  ip_configuration {
    name = "ipconfig1"
    subnet_id = azurerm_subnet.Subnet10.id
    private_ip_address_allocation = "Dynamic"
  }
}

#Virtual Machine
resource "azurerm_linux_virtual_machine" "AzureSysLog" {
  name = "AzureSysLog"
  location = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name
  network_interface_ids = [ azurerm_network_interface.AzuresyslogNIC.id ]
  size = "Standard_B2s"
  
  admin_ssh_key {
    username = "azuresyslogadmin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  disable_password_authentication = true

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

 
  source_image_reference {
    publisher = "canonical"
    offer = "0001-com-ubuntu-server-focal"
    sku = "20_04-lts-gen2"
    version = "latest"
  }
}