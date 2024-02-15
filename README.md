# Setup instructions

1. Deploy the infrastructure using "terraform apply" or "azd up"

2. Import the Cat & Dog Voting application
```
$acr = "acrebordemo99"
az acr import  -n $acr --source mcr.microsoft.com/oss/bitnami/redis:6.0.8 --image azure-vote-back:v1
az acr import  -n $acr --source mcr.microsoft.com/azuredocs/azure-vote-front:v1 --image azure-vote-front:v1
```

3. Get cluster credentials
```
$AKS_NAME="aks1"
$AKS_RESOURCE_GROUP="demo-rg"
az aks get-credentials --name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP
```

4. Get connection strings etc. from TFState
```
$tfstate = terraform state pull | convertfrom-json
$AZURE_COSMOS_CONNECTION_STRING = $tfstate.outputs.AZURE_COSMOS_CONNECTION_STRING.value
```

## Test deployment locally

4. Build the container images
```
docker build -t frontend:latest ./src/web
docker build -t backend:latest ./src/api

docker run -p 80:80 frontend:latest
docker run -p 3100:3100 -e AZURE_COSMOS_CONNECTION_STRING='$AZURE_COSMOS_CONNECTION_STRING' -e AZURE_COSMOS_DATABASE_NAME='todo' -e APPLICATIONINSIGHTS_CONNECTION_STRING='xxxxxx' -e APPLICATIONINSIGHTS_ROLE_NAME='api'  backend:latest
```

# Reference

**Terraform Azure Provider reference:**
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

**Awesome AZD:** *A community-contributed template gallery built to work with the Azure Developer CLI:* 
https://azure.github.io/awesome-azd/?tags=aks

**Store Terraform state in Azure Storage**
https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage

**Terraform Started AZD Template**
https://github.com/Azure-Samples/azd-starter-terraform
