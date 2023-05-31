provider "azurerm" {
  features {}
}

module "resource_group" {
  source  = "clouddrove/resource-group/azure"
  version = "1.0.2"

  name        = "app"
  environment = "test"
  label_order = ["name", "environment"]
  location    = "East US"
}
#Vnet
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

module "container-registry" {
  source              = "clouddrove/acr/azure"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location

  container_registry_config = {
    name = "cdacr1234"
    sku  = "Premium"
  }

  # to enable private endpoint.
  virtual_network_id            = join("", module.vnet.vnet_id)
  subnet_id                     = module.subnet.default_subnet_id
  private_subnet_address_prefix = module.subnet.default_subnet_address_prefixes

  ########Following to be uncommnented only when using DNS Zone from different subscription along with existing DNS zone.

  # diff_sub                                      = true
  # alias_sub                                     = ""

  #########Following to be uncommmented when using DNS zone from different resource group or different subscription.
  # existing_private_dns_zone                     = ""
  # existing_private_dns_zone_resource_group_name = ""
}
