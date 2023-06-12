terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.60.0"
    }
  }
}

provider "azurerm" {
 
  features {}
}

resource "azurerm_virtual_network" "prd-vnet" {
  name                = "prd-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.azurerm_resource_group
}

resource "azurerm_subnet" "prd-subnet" {
  name                 = "prd-subnet"
  resource_group_name  = var.azurerm_resource_group
  virtual_network_name = azurerm_virtual_network.prd-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

 resource "azurerm_public_ip" "public-ip" {
  name                = "prd-public-ip"
  resource_group_name = var.azurerm_resource_group
  location            = var.location
  allocation_method   = "Static"
  }

resource "azurerm_network_interface" "prd-nic" {
  name                = "prd-nic"
  location            = var.location
  resource_group_name = var.azurerm_resource_group


  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prd-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public-ip.id
  }
}

resource "azurerm_windows_virtual_machine" "prd-vm" {
  name                = "sgvm-001"
  resource_group_name = var.azurerm_resource_group
  location            = var.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.prd-nic.id,
  ]

  os_disk {
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