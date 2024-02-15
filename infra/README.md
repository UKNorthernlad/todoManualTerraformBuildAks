terraform init

terraform plan

# Passing variable values on the command line will override the values in *.auto.tfvars, which overrides terraform.tfvars, which overrides the default values defined in the variable code blocks.
terraform plan -var="accountname=commandline99xxwibble"

terraform apply --auto-approve -var="accountname=commandline99xxwibble"

# This will remove the resources. If this is run too soon after apply/creation you might receive an error. Wait a little longer before deletion.
# terraform destroy --auto-approve 
# terraform destroy -target azurerm_key_vault.kv1 --auto-approve 

# If you have existing resources in Azure (but not defined in the .tf files), an error will occur when you attempt to run "plan".
# You should first "import" the resources into the TF state:

# terraform import <tfresourcename> <azure ID of resource to import>
# e.g.
terraform import "azurerm_resource_group.frog" "/subscriptions/3a334aad-b40f-4440-aaa1-4644475b52e2/resourceGroups/example"
terraform import "azurerm_storage_account.toad" "/subscriptions/3a334aad-b40f-4440-aaa1-4644475b52e2/resourceGroups/example/providers/Microsoft.Storage/storageAccounts/myteststore99x"
