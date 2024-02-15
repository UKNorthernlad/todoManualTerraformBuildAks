# Example file.
# These are the definitions of the variables that could be passed in from a main.tfvar.json file.
# It's a bit like the parameters section of an ARM template.
# Any values not passed in either take the default value defined in this file or prompt for user input.
# Add or remote sections as required.

variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
  default     = "west europe"
}

variable "environment_name" {
  description = "Name of the Azure Developer CLI (azd) environment"
  type        = string
  default     = "development"
}

#variable "rg_name" {
#  description = "The name of the resource group to deploy resources into"
#  type        = string
#}

#variable "tags" {
#  description = "A list of tags used for deployed services."
#  type        = map(string)
#}

#variable "resource_token" {
#  description = "A suffix string to centrally mitigate resource name collisions."
#  type        = string
#}

#variable "principal_id" {
#  description = "The Id of the service principal to add to deployed keyvault access policies"
#  sensitive   = true
#  type        = string
#}

#variable "access_policy_object_ids" {
#  description = "A list of object ids to be be added to the keyvault access policies"
#  type        = list(string)
#  sensitive   = true
#  default     = []
#}

#variable "secrets" {
#  description = "A list of secrets to be added to the keyvault"
#  type = list(object({
#    name  = string
#    value = string
#  }))
#  sensitive = true
#}