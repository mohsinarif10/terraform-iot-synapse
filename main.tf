resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "main" {
  name                     = "stterraform${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
}



# Filesystem for Synapse (ADLS Gen2)
resource "azurerm_storage_data_lake_gen2_filesystem" "main" {
  name               = var.file_system_name
  storage_account_id = azurerm_storage_account.main.id
}

# Container for IoT Hub routing
resource "azurerm_storage_container" "iothub_container" {
  name                  = "iothubcontainer"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# IoT Hub
resource "azurerm_iothub" "main" {
  name                = var.iot_hub_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  sku {
    name     = "S1"
    capacity = 1
  }

  fallback_route {
    enabled         = true
    source          = "DeviceMessages"
    endpoint_names  = ["events"]
  }
}

# Storage container as endpoint for IoT Hub
resource "azurerm_iothub_endpoint_storage_container" "main" {
  name                     = "storageEndpoint"
  resource_group_name      = azurerm_resource_group.main.name
  iothub_id                = azurerm_iothub.main.id
  connection_string        = azurerm_storage_account.main.primary_connection_string
  container_name           = azurerm_storage_data_lake_gen2_filesystem.main.name
  batch_frequency_in_seconds = 60
  max_chunk_size_in_bytes    = 10485760
  encoding                   = "JSON"
  file_name_format           = "{iothub}/{partition}/{YYYY}/{MM}/{DD}/{HH}/{mm}"

  depends_on = [
    azurerm_storage_account.main,
    azurerm_storage_data_lake_gen2_filesystem.main
  ]
}


# Route messages from IoT Hub to storage container
resource "azurerm_iothub_route" "main" {
  name                = "route-to-storage"
  resource_group_name = azurerm_resource_group.main.name
  iothub_name         = azurerm_iothub.main.name
  source              = "DeviceMessages"
  condition           = "true"
  enabled             = true
  endpoint_names      = ["storageEndpoint"]

  depends_on = [
    azurerm_iothub_endpoint_storage_container.main
  ]
}

# Synapse Workspace
resource "azurerm_synapse_workspace" "main" {
  name                                 = var.synapse_name
  resource_group_name                  = azurerm_resource_group.main.name
  location                             = var.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.main.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "VerySecret1234!" # Replace with secret in production
  managed_virtual_network_enabled      = true
  public_network_access_enabled        = false

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "terraform"
  }

  depends_on = [
    azurerm_storage_data_lake_gen2_filesystem.main
  ]
}

# Optional: Output key resources
output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "iot_hub_name" {
  value = azurerm_iothub.main.name
}

output "synapse_url" {
  value = "https://${azurerm_synapse_workspace.main.name}.dev.azuresynapse.net"
}
