# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry

resource "azurerm_container_registry" "mainacr" {
  name                = "acrebordemo99"
  resource_group_name = azurerm_resource_group.demo-rg.name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
  depends_on = [azurerm_resource_group.demo-rg]
}

