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