terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.91.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }

  backend "azurerm" {
      resource_group_name  = "backups"
      storage_account_name = "tfstatestore99"
      container_name       = "tfstate"
      key                  = "XXXXXXXX"
  }
}

provider "azurerm" {
    features {
      key_vault {
        purge_soft_delete_on_destroy    = true
        recover_soft_deleted_key_vaults = false
    }
    
  }
}

# Locals are the equivalent to variables in an ARM template. These are settings which rarely change.
locals {
  replication = "LRS"
  tags = {
    environment = "Training"
    owner = "bob"
  }
}

resource "azurerm_resource_group" "demo-rg" {
  name     = "demo-rg"
  location = "West Europe"
}