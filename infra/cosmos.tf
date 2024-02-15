resource "azurerm_resource_group" "database" {
  name     = "database-rg"
  location = var.location
}

resource "azurerm_cosmosdb_account" "example" {
  name                      = "blah-cosmosdb-99"
  location                  = "west europe"
  resource_group_name       = azurerm_resource_group.database.name
  offer_type                = "Standard"
  kind                      = "GlobalDocumentDB"
  enable_automatic_failover = false
  geo_location {
    location          = "north europe"
    failover_priority = 0
  }
  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }
  depends_on = [ azurerm_resource_group.database]
}

resource "azurerm_cosmosdb_sql_database" "main" {
  name                = "todo"
  resource_group_name = azurerm_resource_group.database.name
  account_name        = azurerm_cosmosdb_account.example.name
  depends_on = [azurerm_cosmosdb_account.example]
}

resource "azurerm_cosmosdb_sql_container" "example" {
  name                  = "stuff-container"
  resource_group_name   = azurerm_resource_group.database.name
  account_name          = azurerm_cosmosdb_account.example.name
  database_name         = azurerm_cosmosdb_sql_database.main.name
  partition_key_path    = "/definition/id"
  partition_key_version = 1
  depends_on = [azurerm_cosmosdb_sql_database.main]

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    included_path {
      path = "/included/?"
    }

    excluded_path {
      path = "/excluded/?"
    }
  }

  unique_key {
    paths = ["/definition/idlong", "/definition/idshort"]
  }
}

output "AZURE_COSMOS_CONNECTION_STRING" {
  value     = azurerm_cosmosdb_account.example.connection_strings[0]
  sensitive = true
}