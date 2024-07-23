provider "azurerm" {
  features {}
  subscription_id            = "01111111111110-11-11-11-11"
  skip_provider_registration = "true"
}

provider "azurerm" {
  features {}
  alias                      = "peer"
  subscription_id            = "01111111111110-11-11-11-11"
  skip_provider_registration = "true"
}


data "azurerm_client_config" "current_client_config" {}

locals {
  name        = "app"
  environment = "test"
}

##----------------------------------------------------------------------------- 
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "clouddrove/resource-group/azure"
  version     = "1.0.2"
  name        = local.name
  environment = local.environment
  label_order = ["name", "environment"]
  location    = "Canada Central"
}

##----------------------------------------------------------------------------- 
## Virtual Network module call.
## Virtual Network for which subnet will be created for private endpoint and vnet link will be created in private dns zone.
##-----------------------------------------------------------------------------
module "vnet" {
  depends_on          = [module.resource_group]
  source              = "clouddrove/vnet/azure"
  version             = "1.0.4"
  name                = local.name
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

##----------------------------------------------------------------------------- 
## Subnet module call.
## Subnet in which private endpoint will be created.
##-----------------------------------------------------------------------------
module "subnet" {
  source               = "clouddrove/subnet/azure"
  version              = "1.2.0"
  name                 = local.name
  environment          = local.environment
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
  #subnet
  subnet_names    = ["subnet1"]
  subnet_prefixes = ["10.0.0.0/24"]
  # route_table
  routes = [
    {
      name           = "rt-test"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]
}

##----------------------------------------------------------------------------- 
## Log Analytic Module Call.
## Log Analytic workspace for diagnostic setting. 
##-----------------------------------------------------------------------------
module "log-analytics" {
  source                           = "clouddrove/log-analytics/azure"
  version                          = "1.0.1"
  name                             = local.name
  environment                      = local.environment
  create_log_analytics_workspace   = true
  log_analytics_workspace_sku      = "PerGB2018"
  resource_group_name              = module.resource_group.resource_group_name
  log_analytics_workspace_location = module.resource_group.resource_group_location
}


#########Following to be uncommnented only when using DNS Zone from different subscription along with existing DNS zone.
# data "azurerm_private_dns_zone" "existing_dns_zone" {
#   name                = "privatelink.azurecr.io" # The name of your DNS Zone
#   resource_group_name = "dns-rg"                 # The resource group where existing the DNS Zone is located
# }


module "vault" {
  source              = "clouddrove/key-vault/azure"
  version             = "1.1.0"
  name                = "apptest4rds3477"
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  virtual_network_id  = module.vnet.vnet_id
  subnet_id           = module.subnet.default_subnet_id[0]

  public_network_access_enabled = true

  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["0.0.0.0/0"]
  }

  ##RBAC
  enable_rbac_authorization = true
  reader_objects_ids        = [data.azurerm_client_config.current_client_config.object_id]
  admin_objects_ids         = [data.azurerm_client_config.current_client_config.object_id]
  #### enable diagnostic setting
  diagnostic_setting_enable  = true
  log_analytics_workspace_id = module.log-analytics.workspace_id ## when diagnostic_setting_enable = true, need to add log analytics workspace id
}


##----------------------------------------------------------------------------- 
## ACR module call.
##-----------------------------------------------------------------------------
module "container-registry" {
  providers = {
    azurerm.dns_sub  = azurerm.peer,
    azurerm.main_sub = azurerm
  }
  source              = "../../"
  name                = local.name # Name used for specifying tags and other resources naming.(like private endpoint, vnet-link etc)
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  container_registry_config = {
    name = "cdacr1232" # Name of Container Registry
    sku  = "Premium"
  }
  log_analytics_workspace_id = module.log-analytics.workspace_id

  ##----------------------------------------------------------------------------- 
  ## To be mentioned for private endpoint, because private endpoint is enabled by default.
  ## To disable private endpoint set 'enable_private_endpoint' variable = false and than no need to specify following variable  
  ##-----------------------------------------------------------------------------
  virtual_network_id = module.vnet.vnet_id
  subnet_id          = module.subnet.default_subnet_id[0]
  ########Following to be uncommnented only when using DNS Zone from different subscription along with existing DNS zone.

  # diff_sub = true
  # alias                                         = ""
  # alias_sub                                     = ""

  #########Following to be uncommmented when using DNS zone from different resource group or different subscription.
  #existing_private_dns_zone                     = "privatelink.azurecr.io"
  #existing_private_dns_zone_resource_group_name = "dns-rg"
  #existing_private_dns_zone_id                  = [data.azurerm_private_dns_zone.existing_dns_zone.id]

  ##if encryption is enabled.
  encryption                  = true
  enable_content_trust        = false
  key_vault_rbac_auth_enabled = true
  key_vault_id                = module.vault.id
}

