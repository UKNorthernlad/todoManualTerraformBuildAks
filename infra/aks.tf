# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster

resource "azurerm_kubernetes_cluster" "aks1" {
  name                = "aks1"
  location            = azurerm_resource_group.demo-rg.location
  resource_group_name = azurerm_resource_group.demo-rg.name
  dns_prefix          = "aks1"
  depends_on = [azurerm_resource_group.demo-rg]
  
  network_profile {
    network_plugin      = "azure"
    network_policy      = "calico"
  }
  
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_role_assignment" "example" {
  principal_id                     = azurerm_kubernetes_cluster.aks1.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.mainacr.id
  skip_service_principal_aad_check = true
  depends_on = [azurerm_container_registry.mainacr]
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks1.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks1.kube_config_raw
  sensitive = true
}