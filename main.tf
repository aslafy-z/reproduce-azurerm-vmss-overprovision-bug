
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.78.0"
    }
  }
}

provider "azurerm" {
  features {}
  # skip_provider_registration = true
}

resource "azurerm_resource_group" "repro" {
  name     = "reproduce-azurerm-vmss-overprovision-bug"
  location = "West Europe"
}

resource "azurerm_virtual_network" "repro" {
  name                = "reproduce-azure-vmss-overprovision-bug"
  resource_group_name = azurerm_resource_group.repro.name
  location            = azurerm_resource_group.repro.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "repro" {
  name                 = "reproduce-azure-vmss-overprovision-bug"
  resource_group_name  = azurerm_resource_group.repro.name
  virtual_network_name = azurerm_virtual_network.repro.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "workers" {
  name                = "workers"
  resource_group_name = azurerm_resource_group.repro.name
  location            = azurerm_resource_group.repro.location

  sku                             = "Standard_A1_v2"
  instances                       = 1
  
  # First run was not specifying this value
  # Second run sets it to false
  overprovision                   = "false"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS" 
    version   = "latest"
  }

  disable_password_authentication = true
  admin_username                  = "ubuntu"
  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name                      = "workers-nic"
    primary                   = true
    ip_configuration {
      name                                   = "workers-ip"
      subnet_id = azurerm_subnet.repro.id
      primary                   = true
    }
  }
}
