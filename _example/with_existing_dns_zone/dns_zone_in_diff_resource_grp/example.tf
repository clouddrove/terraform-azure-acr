provider "azurerm" {
  features {}
}

##----------------------------------------------------------------------------- 
## Virtual Network module call.
## Virtual Network for which subnet will be created for private endpoint and vnet link will be created in private dns zone.
##-----------------------------------------------------------------------------
module "resource_group" {
  source  = "clouddrove/resource-group/azure"
  version = "1.0.2"

  name        = "app"
  environment = "test"
  label_order = ["name", "environment"]
  location    = "East US"
}

##----------------------------------------------------------------------------- 
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "vnet" {
  depends_on = [module.resource_group]
  source     = "clouddrove/vnet/azure"
  version    = "1.0.2"

  name                = "app"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
}

##----------------------------------------------------------------------------- 
## Subnet module call.
## Subnet in which private endpoint will be created.
##-----------------------------------------------------------------------------
module "subnet" {
  source  = "clouddrove/subnet/azure"
  version = "1.0.2"

  name                 = "app"
  environment          = "test"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = join("", module.vnet.vnet_name)

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
## ACR module call.
##-----------------------------------------------------------------------------
module "container-registry" {
  source              = "../"
  name                = "acr" # Name used for specifying tags and other resources naming.(like private endpoint, vnet-link etc)
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  container_registry_config = {
    name = "cdacr1234" # Name of Container Registry
    sku  = "Premium"
  }
  ##----------------------------------------------------------------------------- 
  ## To be mentioned for private endpoint, because private endpoint is enabled by default.
  ## To disable private endpoint set 'enable_private_endpoint' variable = false and than no need to specify following variable  
  ##-----------------------------------------------------------------------------
  virtual_network_id = join("", module.vnet.vnet_id)
  subnet_id          = module.subnet.default_subnet_id
  ##----------------------------------------------------------------------------- 
  ## Specify following variales when private dns zone is in same subscription but in different resource group
  ##-----------------------------------------------------------------------------
  existing_private_dns_zone                     = "privatelink.azurecr.io" # Name of private dns zone remain same for acr. 
  existing_private_dns_zone_resource_group_name = "example_test_rg"
}
