data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = "eborkeyvault99"
  location                    = azurerm_resource_group.demo-rg.location
  resource_group_name         = azurerm_resource_group.demo-rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled    = false

  depends_on = [azurerm_resource_group.demo-rg]

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get","Create","List",
    ]

    secret_permissions = [
      "Get","List",
    ]

    certificate_permissions = [
      "Get","Create","List",
    ]

    storage_permissions = [
      "Get","List",
    ]
  }
}

output "AZURE_KEY_VAULT_ENDPOINT" {
  value     = azurerm_key_vault.kv.vault_uri
  sensitive = true
}