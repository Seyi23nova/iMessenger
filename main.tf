terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
  
  backend "azurerm" {
    resource_group_name  = "webapp-rg"
    storage_account_name = "webappstatestorage"
    container_name       = "webappstatecontainer"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "webapp-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "webapp-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet1" {
  name                 = "webapp-subnet-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "webapp-subnet-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create the storage account
resource "azurerm_storage_account" "sa" {
  name                     = "webappstatestorage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create a container to hold the Terraform state file
resource "azurerm_storage_container" "state" {
  name                  = "webappstatecontainer"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}