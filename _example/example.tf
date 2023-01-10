provider "azurerm" {
  features {}
}

module "resource_group" {
  source  = "clouddrove/resource-group/azure"
  version = "1.0.0"

  name        = "app"
  environment = "test"
  label_order = ["environment", "name", ]
  location    = "East US"
}
#Vnet
module "vnet" {
  depends_on = [module.resource_group]
  source     = "clouddrove/vnet/azure"
  version    = "1.0.0"

  name                = "app"
  environment         = "test"
  label_order         = ["name", "environment"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
  enable_ddos_pp      = false
}

module "name_specific_subnet" {
  depends_on           = [module.vnet]
  source               = "clouddrove/subnet/azure"
  name                 = "app"
  environment          = "test"
  label_order          = ["name", "environment"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = join("", module.vnet.vnet_name)

  #subnet
  specific_name_subnet  = true
  specific_subnet_names = "ecr-subnet"
  subnet_prefixes       = ["10.0.1.0/24"]

  # route_table
  enable_route_table = false
  routes = [
    {
      name           = "rt-test"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]
}

module "container-registry" {
  source              = "../"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location

  container_registry_config = {
    name                          = "containerregistrydemoproject01"
    admin_enabled                 = true
    sku                           = "Premium"
    public_network_access_enabled = false
  }

  retention_policy = {
    days    = 10
    enabled = true
  }
  enable_content_trust          = true
  enable_private_endpoint       = true
  virtual_network_name          = module.vnet.vnet_name
  virtual_network_id            = join("", module.vnet.vnet_id)
  subnet_id                     = module.name_specific_subnet.specific_subnet_id
  private_subnet_address_prefix = module.name_specific_subnet.specific_subnet_address_prefixes
  private_dns_name              = "privatelink.azurecr.io" # To be same for all ACR.

}
