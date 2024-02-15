resource "azurerm_resource_group" "database" {
  name     = "database-rg"
  location = var.location
}

resource "azurerm_cosmosdb_account" "db" {
  name                            = "blah-cosmosdb-99"
  location                        = "west europe"
  resource_group_name             = azurerm_resource_group.database.name
  offer_type                      = "Standard"
  kind                            = "MongoDB"
  enable_automatic_failover       = false
  enable_multiple_write_locations = false
  mongo_server_version            = "4.0"

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = "north europe"
    failover_priority = 0
    zone_redundant    = false
  }
}

# ------------------------------------------------------------------------------------------------------
# Deploy cosmos mongo db and collections
# ------------------------------------------------------------------------------------------------------
resource "azurerm_cosmosdb_mongo_database" "mongodb" {
  name                = "Todo"
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
  account_name        = azurerm_cosmosdb_account.db.name
}

resource "azurerm_cosmosdb_mongo_collection" "list" {
  name                = "TodoList"
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
  account_name        = azurerm_cosmosdb_account.db.name
  database_name       = azurerm_cosmosdb_mongo_database.mongodb.name
  shard_key           = "_id"


  index {
    keys   = ["_id"]
  }
}

resource "azurerm_cosmosdb_mongo_collection" "item" {
  name                = "TodoItem"
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
  account_name        = azurerm_cosmosdb_account.db.name
  database_name       = azurerm_cosmosdb_mongo_database.mongodb.name
  shard_key           = "_id"

  index {
    keys   = ["_id"]
  }
}

output "AZURE_COSMOS_CONNECTION_STRING" {
  value     = azurerm_cosmosdb_account.db.connection_strings[0]
  sensitive = true
}

output "AZURE_COSMOS_DATABASE_NAME" {
  value = azurerm_cosmosdb_mongo_database.mongodb.name
}