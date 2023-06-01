variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "repository" {
  type        = string
  default     = ""
  description = "Terraform current module repo"
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] ."
}

variable "managedby" {
  type        = string
  default     = ""
  description = "ManagedBy, eg ''."
}

variable "enable" {
  type        = bool
  default     = true
  description = "Flag to control module creation."
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = ""
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = ""
}

variable "container_registry_config" {
  description = "Manages an Azure Container Registry"
  type = object({
    name                      = string
    sku                       = optional(string)
    quarantine_policy_enabled = optional(bool)
    zone_redundancy_enabled   = optional(bool)
  })
}

variable "georeplications" {
  description = "A list of Azure locations where the container registry should be geo-replicated"
  type = list(object({
    location                = string
    zone_redundancy_enabled = optional(bool)
  }))
  default = []
}

variable "network_rule_set" { # change this to match actual objects
  description = "Manage network rules for Azure Container Registries"
  type = object({
    default_action = optional(string)
    ip_rule = optional(list(object({
      ip_range = string
    })))
    virtual_network = optional(list(object({
      subnet_id = string
    })))
  })
  default = null
}

variable "retention_policy" {
  description = "Set a retention policy for untagged manifests"
  type = object({
    days    = optional(number)
    enabled = optional(bool)
  })
  default = {
    days    = 10
    enabled = true
  }
}

variable "enable_content_trust" {
  description = "Boolean value to enable or disable Content trust in Azure Container Registry"
  default     = true
}

variable "identity_ids" {
  description = "Specifies a list of user managed identity ids to be assigned. This is required when `type` is set to `UserAssigned` or `SystemAssigned, UserAssigned`"
  default     = null
}

variable "encryption" {
  description = "Encrypt registry using a customer-managed key"
  type = object({
    key_vault_key_id   = string
    identity_client_id = string
  })
  default = null
}

variable "scope_map" {
  description = "Manages an Azure Container Registry scope map. Scope Maps are a preview feature only available in Premium SKU Container registries."
  type = map(object({
    actions = list(string)
  }))
  default = null
}

variable "container_registry_webhooks" {
  description = "Manages an Azure Container Registry Webhook"
  type = map(object({
    service_uri    = string
    actions        = list(string)
    status         = optional(string)
    scope          = string
    custom_headers = map(string)
  }))
  default = null
}

variable "enable_private_endpoint" {
  description = "Manages a Private Endpoint to Azure Container Registry"
  default     = true
}

variable "existing_private_dns_zone" {
  description = "Name of the existing private DNS zone"
  default     = null
}

variable "private_subnet_address_prefix" {
  description = "The name of the subnet for private endpoints"
  default     = null
}

variable "log_analytics_workspace_name" {
  description = "The name of log analytics workspace name"
  default     = null
}

variable "storage_account_name" {
  description = "The name of the hub storage account to store logs"
  default     = null
}

variable "acr_diag_logs" {
  description = "Application Gateway Monitoring Category details for Azure Diagnostic setting"
  default     = ["ContainerRegistryRepositoryEvents", "ContainerRegistryLoginEvents"]
}

variable "private_dns_name" {
  type    = string
  default = "privatelink.azurecr.io"
}

variable "subnet_id" {
  type        = list(string)
  default     = null
  description = "Subnet to be used for private endpoint"
}

variable "virtual_network_id" {
  type        = string
  default     = null
  description = "Virtual Network to be used for private endpoint"
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "log_analytics_workspace_id"
}

variable "storage_account_id" {
  type    = string
  default = null
}

variable "private_dns_zone_vnet_link_registration_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Is auto-registration of virtual machine records in the virtual network in the Private DNS zone enabled?"
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "To denied public access "
}

variable "admin_enabled" {
  type        = bool
  default     = true
  description = "To enable of disable admin access"
}

variable "enable_diagnostic" {
  type        = bool
  default     = true
  description = "Flag to control diagnostic setting resource creation."
}

variable "existing_private_dns_zone_resource_group_name" {
  type        = string
  default     = null
  description = "The name of the existing resource group"
}

variable "alias_sub" {
  type        = string
  default     = null
  description = "Subscription id for different sub in which dns zone is present."
}

##----------------------------------------------------------------------------- 
## To be set when existing dns zone is in diffrent subscription.
##-----------------------------------------------------------------------------
variable "diff_sub" {
  type        = bool
  default     = false
  description = "Flag to tell whether dns zone is in different sub or not."
}

variable "multi_sub_vnet_link" {
  type        = bool
  default     = false
  description = "Flag to control creation of vnet link for dns zone in different subscription"
}

variable "addon_vent_link" {
  type        = bool
  default     = false
  description = "The name of the addon vnet "
}

variable "addon_resource_group_name" {
  type        = string
  default     = ""
  description = "The name of the addon vnet resource group"
}

variable "addon_virtual_network_id" {
  type        = string
  default     = ""
  description = "The name of the addon vnet link vnet id"
}