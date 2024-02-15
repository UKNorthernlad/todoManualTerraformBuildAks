# Setup instructions

1. Deploy the infrastructure using "terraform apply" or "azd up"
```
terraform apply
```

2. Get cluster credentials
```
$AKS_NAME="aks1"
$AKS_RESOURCE_GROUP="demo-rg"
az aks get-credentials --name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP
```

3. Get connection strings etc. from TFState
```
cd infra
$tfstate = terraform state pull | convertfrom-json
$AZURE_COSMOS_CONNECTION_STRING = $tfstate.outputs.AZURE_COSMOS_CONNECTION_STRING.value
$APPLICATIONINSIGHTS_CONNECTION_STRING = $tfstate.outputs.APPLICATIONINSIGHTS_CONNECTION_STRING.value
```

4. Install and Ingress Controller
```
helm repo update

helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace --set controller.nodeSelector."kubernetes\.io/os"=linux --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux --set controller.service.externalTrafficPolicy=Local --set defaultBackend.image.image=defaultbackend-amd64:1.5
```

## Test deployment locally

5. Build the container images
```
docker build -t frontend:latest ./src/web

docker build -t backend:latest ./src/api

docker run -d -p 80:80 -e REACT_APP_APPLICATIONINSIGHTS_CONNECTION_STRING=$APPLICATIONINSIGHTS_CONNECTION_STRING frontend:latest

docker run -d -p 3100:3100 -e AZURE_COSMOS_CONNECTION_STRING=$AZURE_COSMOS_CONNECTION_STRING -e AZURE_COSMOS_DATABASE_NAME=todo -e APPLICATIONINSIGHTS_ROLE_NAME=api -e APPLICATIONINSIGHTS_CONNECTION_STRING=$APPLICATIONINSIGHTS_CONNECTION_STRING  -e API_ALLOW_ORIGINS='http://localhost'  backend:latest
```

## Upload assets ready for AKS

6. Upload the Docker images to the new ACR
```
$acr = "acrebordemo99"
docker tag frontend:latest acrebordemo99.azurecr.io/frontend:latest
docker tag backend:latest acrebordemo99.azurecr.io/backend:latest

az acr login --name acrebordemo99

docker push acrebordemo99.azurecr.io/frontend:latest
docker push acrebordemo99.azurecr.io/backend:latest
```

7. Apply the k8s manifest files
```
# Frontend
kubectl apply -f .\src\web\manifests\deployment.tmpl.yaml
kubectl apply -f .\src\web\manifests\service.yaml
kubectl apply -f .\src\web\manifests\ingress.yaml
kubectl apply -f .\src\web\manifests\config.tmpl.yaml

# Backend
kubectl apply -f .\src\api\manifests\deployment.tmpl.yaml
kubectl apply -f .\src\api\manifests\service.yaml
kubectl apply -f .\src\api\manifests\ingress.yaml
kubectl apply -f .\src\api\manifests\config.tmpl.yaml
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
