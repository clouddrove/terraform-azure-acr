provider "azurerm" {
  features {}
  subscription_id = "000001-11111-1223-XXX-XXXXXXXXXXXX"
}

provider "azurerm" {
  features {}
  alias           = "peer"
  subscription_id = "000001-11111-1223-XXX-XXXXXXXXXXXX"
}
locals {
  name        = "app"
  environment = "test"
}

##----------------------------------------------------------------------------- 
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source  = "clouddrove/resource-group/azure"
  version = "1.0.2"

  name        = local.name
  environment = local.environment
  label_order = ["name", "environment"]
  location    = "East US"
}

##----------------------------------------------------------------------------- 
## Virtual Network module call.
## Virtual Network in which subnet will be created for private endpoint and for which vnet link will be created in private dns zone.
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
  version              = "1.2.1"
  name                 = local.name
  environment          = local.environment
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
  #subnet
  subnet_names    = ["subnet1"]
  subnet_prefixes = ["10.0.0.0/20"]
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
  version                          = "2.0.0"
  name                             = local.name
  environment                      = local.environment
  create_log_analytics_workspace   = true
  log_analytics_workspace_sku      = "PerGB2018"
  log_analytics_workspace_id       = module.log-analytics.workspace_id
  resource_group_name              = module.resource_group.resource_group_name
  log_analytics_workspace_location = module.resource_group.resource_group_location
}

##----------------------------------------------------------------------------
## Existing DNS zone
#-----------------------------------------------------------------------------
data "azurerm_private_dns_zone" "existing_dns_zone" {
  name                = "privatelink.azurecr.io" # The name of your DNS Zone
  resource_group_name = "dns-rg"                 # The resource group where existing the DNS Zone is located
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
    name = "cdacr1234" # Name of Container Registry
    sku  = "Premium"
  }
  log_analytics_workspace_id = module.log-analytics.workspace_id
  ##----------------------------------------------------------------------------- 
  ## To be mentioned for private endpoint, because private endpoint is enabled by default.
  ## To disable private endpoint set 'enable_private_endpoint' variable = false and than no need to specify following variable  
  ##-----------------------------------------------------------------------------
  virtual_network_id = module.vnet.vnet_id
  subnet_id          = module.subnet.default_subnet_id[0]
  ##----------------------------------------------------------------------------- 
  ## Specify following variales when private dns zone is in different subscription.
  ##-----------------------------------------------------------------------------
  diff_sub                                      = true
  existing_private_dns_zone                     = "privatelink.azurecr.io" # Name of private dns zone remain same for acr. 
  existing_private_dns_zone_resource_group_name = "example_test_rg"
  existing_private_dns_zone_id                  = [data.azurerm_private_dns_zone.existing_dns_zone.id]
}
