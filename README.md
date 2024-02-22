# Setup instructions
These instruction assume you are running the setup from your local machine and NOT from the Azure Cloud Shell.

1. Login to your Azure Subscription:
```
az login
```

2. Install the **terraform** command using the instructions from https://developer.hashicorp.com/terraform/install

3. Deploy the infrastructure using "terraform apply"
```
cd infra
terraform apply
```

3. Get cluster credentials
```
$AKS_NAME="aks1"
$AKS_RESOURCE_GROUP="demo-rg"
az aks get-credentials --name $AKS_NAME --resource-group $AKS_RESOURCE_GROUP
```

4. Get connection strings etc. from TFState
```
cd infra
$tfstate = terraform state pull | convertfrom-json
$AZURE_COSMOS_CONNECTION_STRING = $tfstate.outputs.AZURE_COSMOS_CONNECTION_STRING.value
$APPLICATIONINSIGHTS_CONNECTION_STRING = $tfstate.outputs.APPLICATIONINSIGHTS_CONNECTION_STRING.value
$AZURE_KEY_VAULT_ENDPOINT = $tfstate.outputs.AZURE_KEY_VAULT_ENDPOINT.value
```

5. Install an Ingress Controller
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

## Fix up permissions

7. Grant AKS Node pool managed identity "Key Vault Administrator" rights on the Key Vault
```
No command yet - make the change manually via the portal.
```

## Apply AKS manifests

8. Apply the k8s manifest file for the API layer. 
```
# Update the api.manifest.yaml file with the following environment variables:
# $AZURE_COSMOS_CONNECTION_STRING
# $APPLICATIONINSIGHTS_CONNECTION_STRING
# $AZURE_KEY_VAULT_ENDPOINT

kubectl apply -f api.manifest.yaml
```

Now retreive the public IP address of the API
```
kubectl get service todo-api -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

Open a browser and go to http://IP-ADDRESS

9. Apply the k8s manifest file for the WEB layer. 

# Reference

## Application Architecture


![Application Architecture](https://raw.githubusercontent.com/Azure-Samples/todo-nodejs-mongo-aks/main/assets/resources.png)

**Terraform Azure Provider reference:**
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

**Awesome AZD:** *A community-contributed template gallery built to work with the Azure Developer CLI:* 
https://azure.github.io/awesome-azd/?tags=aks

**Store Terraform state in Azure Storage**
https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage

**Terraform Started AZD Template**
https://github.com/Azure-Samples/azd-starter-terraform
