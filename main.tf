# Copyright (c) Tim Krebs
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.2"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = "East US"

  tags = {
    Environment = "dev"
    Team        = "DevOps"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "dev-vnet01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "East US"
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "dev"
    Team        = "DevOps"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "dev-subnet-01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "dev-nsg-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "dev-nsg-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "dev"
    Team        = "DevOps"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-a" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_public_ip" "publicip" {
  name                = "dev-publicip-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"

  tags = {
    Environment = "dev"
    Team        = "DevOps"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "dev-nic-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }

  tags = {
    Environment = "dev"
    Team        = "DevOps"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "dev-vm-01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/azurekey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-script.tpl", {
      hostname     = self.public_ip_address,
      username     = "adminuser",
      identityfile = "~/.ssh/azurekey"
    })
    interpreter = var.host_os == "windows" ? ["PowerShell", "-Command"] : ["bash", "-c"]
  }

  tags = {
    Environment = "dev"
    Team        = "DevOps"
  }
}

data "azurerm_public_ip" "publicip_data" {
  name                = azurerm_public_ip.publicip.name
  resource_group_name = azurerm_resource_group.rg.name
}

output "vm_public_ip" {
  value = "${azurerm_linux_virtual_machine.vm.name}: ${data.azurerm_public_ip.publicip_data.ip_address}"
}