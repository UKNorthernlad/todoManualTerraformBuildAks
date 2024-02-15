# How to setup Terraform cloud state.

Taken from: https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage

```
$RESOURCE_GROUP_NAME="backups"
$STORAGE_ACCOUNT_NAME="tfstatestore99"
$CONTAINER_NAME="tfstate"
```

### Create resource group
az group create --name $RESOURCE_GROUP_NAME --location "sweden central"

### Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

### Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

### Run the following commands to get the storage access key and store it as an environment variabl
$ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
$ARM_ACCESS_KEY=$ACCOUNT_KEY
```

### Update the main.tf file with the Storage account key

```
  backend "azurerm" {
      resource_group_name  = "backups"
      storage_account_name = "tfstatestore99"
      container_name       = "tfstate"
      key                  = "SomeBigLongStringOfNumbersAndLettersHere"
  }
```

### Initialize the new backend storage
```
terraform init
```

### Applying configuration
From now all state information will be stored in the backend. This will prevent multiple users from trying to deploy at the same time which could cause a corrupted deployment. Commands such as `terraform apply` now work the same.