##----------------------------------------------------------------------------- 
## Labels module callled that will be used for naming and tags.   
##-----------------------------------------------------------------------------
module "labels" {

  source  = "clouddrove/labels/azure"
  version = "1.0.0"

  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}

##----------------------------------------------------------------------------- 
## Below resources will create ACR and its components.   
##-----------------------------------------------------------------------------
resource "azurerm_container_registry" "main" {
  count                         = var.enable ? 1 : 0
  name                          = format("%s", var.container_registry_config.name)
  resource_group_name           = var.resource_group_name
  location                      = var.location
  admin_enabled                 = var.admin_enabled
  sku                           = var.container_registry_config.sku
  public_network_access_enabled = var.public_network_access_enabled
  quarantine_policy_enabled     = var.container_registry_config.quarantine_policy_enabled
  zone_redundancy_enabled       = var.container_registry_config.zone_redundancy_enabled
  tags                          = module.labels.tags

  dynamic "georeplications" {
    for_each = var.georeplications
    content {
      location                = georeplications.value.location
      zone_redundancy_enabled = georeplications.value.zone_redundancy_enabled
      tags                    = merge({ "Name" = format("%s", "georep-${georeplications.value.location}") }, module.labels.tags, )
    }
  }

  dynamic "network_rule_set" {
    for_each = var.network_rule_set != null ? [var.network_rule_set] : []
    content {
      default_action = lookup(network_rule_set.value, "default_action", "Allow")

      dynamic "ip_rule" {
        for_each = network_rule_set.value.ip_rule
        content {
          action   = "Allow"
          ip_range = ip_rule.value.ip_range
        }
      }

      dynamic "virtual_network" {
        for_each = network_rule_set.value.virtual_network
        content {
          action    = "Allow"
          subnet_id = virtual_network.value.subnet_id
        }
      }
    }
  }

  dynamic "retention_policy" {
    for_each = var.retention_policy != null ? [var.retention_policy] : []
    content {
      days    = lookup(retention_policy.value, "days", 7)
      enabled = lookup(retention_policy.value, "enabled", true)
    }
  }

  dynamic "trust_policy" {
    for_each = var.enable_content_trust ? [1] : []
    content {
      enabled = var.enable_content_trust
    }
  }

  identity {
    type         = var.identity_ids != null ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = var.identity_ids
  }

  dynamic "encryption" {
    for_each = var.encryption != null ? [var.encryption] : []
    content {
      enabled            = true
      key_vault_key_id   = encryption.value.key_vault_key_id
      identity_client_id = encryption.value.identity_client_id
    }
  }
}


resource "azurerm_container_registry_scope_map" "main" {
  for_each                = var.scope_map != null ? { for k, v in var.scope_map : k => v if v != null } : {}
  name                    = format("%s", each.key)
  resource_group_name     = var.resource_group_name
  container_registry_name = azurerm_container_registry.main.*.name
  actions                 = each.value["actions"]
}


resource "azurerm_container_registry_token" "main" {
  for_each                = var.scope_map != null ? { for k, v in var.scope_map : k => v if v != null } : {}
  name                    = format("%s", "${each.key}-token")
  resource_group_name     = var.resource_group_name
  container_registry_name = azurerm_container_registry.main.*.name
  scope_map_id            = element([for k in azurerm_container_registry_scope_map.main : k.id], 0)
  enabled                 = true
}

resource "azurerm_container_registry_webhook" "main" {
  for_each            = var.container_registry_webhooks != null ? { for k, v in var.container_registry_webhooks : k => v if v != null } : {}
  name                = format("%s", each.key)
  resource_group_name = var.resource_group_name
  location            = var.location
  registry_name       = azurerm_container_registry.main.*.name
  service_uri         = each.value["service_uri"]
  actions             = each.value["actions"]
  status              = each.value["status"]
  scope               = each.value["scope"]
  custom_headers      = each.value["custom_headers"]
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

##----------------------------------------------------------------------------- 
## Below resource will create private endpoint resource for ACR.    
##-----------------------------------------------------------------------------
resource "azurerm_private_endpoint" "pep1" {
  count               = var.enable && var.enable_private_endpoint ? 1 : 0
  name                = format("%s-%s-pe-acr", var.container_registry_config.name, module.labels.id)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = join("", var.subnet_id)
  private_service_connection {
    name                           = "containerregistryprivatelink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_container_registry.main[0].id
    subresource_names              = ["registry"]
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

##----------------------------------------------------------------------------- 
## Provider block added, to be used when private dns zone is in different subscription and vnet link is to be created in that private dns zone name. 
## Add different subscription id in 'alias_sub' variable. 
##-----------------------------------------------------------------------------
provider "azurerm" {
  alias = "peer"
  features {}
  subscription_id = var.alias_sub
}

##----------------------------------------------------------------------------- 
## Locals defined to determine the resource group in which private dns zone must be created or existing private dns zone is present. 
##-----------------------------------------------------------------------------
locals {
  valid_rg_name         = var.existing_private_dns_zone == null ? var.resource_group_name : var.existing_private_dns_zone_resource_group_name
  private_dns_zone_name = var.existing_private_dns_zone == null ? join("", azurerm_private_dns_zone.dnszone1.*.name) : var.existing_private_dns_zone
}

##----------------------------------------------------------------------------- 
## Data block called to get private ip of private endpoint that will be used in creating dns a-record. 
##-----------------------------------------------------------------------------
data "azurerm_private_endpoint_connection" "private-ip" {
  count               = var.enable && var.enable_private_endpoint ? 1 : 0
  name                = join("", azurerm_private_endpoint.pep1.*.name)
  resource_group_name = var.resource_group_name
}

##----------------------------------------------------------------------------- 
## Private dns zone will be created if private endpoint is enabled and no existing dns zone is provided.  
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "dnszone1" {
  count               = var.enable && var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                = var.private_dns_name
  resource_group_name = var.resource_group_name
  tags                = module.labels.tags
}

##----------------------------------------------------------------------------- 
## Below vnet link resource will be created when private dns zone is present in same subscription and same resource group or same subscription and different resource group. 
## Different resource will be used when existing private dns zone is provided. 
## Resource group and private dns zone in which vnet link is to be created will be decided from condition present in locals and will be passed as locals. 
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "vent-link-same-sub" {
  count                 = var.enable && var.enable_private_endpoint && var.diff_sub == false && var.same_vnet == false ? 1 : 0
  name                  = var.existing_private_dns_zone == null ? format("%s-pdz-vnet-link-acr", module.labels.id) : format("%s-pdz-vnet-link-acr-1", module.labels.id)
  resource_group_name   = local.valid_rg_name
  private_dns_zone_name = local.private_dns_zone_name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = var.private_dns_zone_vnet_link_registration_enabled
  tags                  = module.labels.tags
}

##----------------------------------------------------------------------------- 
## Below vnet link resource will be created when existing dns zone is present in different subscription. 
## Add different subscription id in alias sub variable to use provider for that particular subscription. 
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "vent-link-diff_sub" {
  provider              = azurerm.peer
  count                 = var.enable && var.enable_private_endpoint && var.diff_sub == true ? 1 : 0
  name                  = var.existing_private_dns_zone == null ? format("%s-pdz-vnet-link-acr", module.labels.id) : format("%s-pdz-vnet-link-acr-1", module.labels.id)
  resource_group_name   = local.valid_rg_name
  private_dns_zone_name = local.private_dns_zone_name
  virtual_network_id    = var.virtual_network_id
  tags                  = module.labels.tags
}

##----------------------------------------------------------------------------- 
## Below vnet link resource is used when you have to create multiple vnet link in existing dns zone.
## Call the module again and set enable variable = false and add variables specific only to this resource.   
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "vent-link-multi-subs" {
  provider              = azurerm.peer
  count                 = var.multi_sub_vnet_link && var.existing_private_dns_zone != null ? 1 : 0
  name                  = format("%s-pdz-vnet-link-acr-1", module.labels.id)
  resource_group_name   = var.existing_private_dns_zone_resource_group_name
  private_dns_zone_name = var.existing_private_dns_zone
  virtual_network_id    = var.virtual_network_id
  tags                  = module.labels.tags
}

##----------------------------------------------------------------------------- 
## Below vnet link resource will be created when you have to add extra vnet link in same subscription. 
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "addon_vent_link" {
  count                 = var.enable && var.addon_vent_link ? 1 : 0
  name                  = format("%s-pdz-vnet-link-acr-addon", module.labels.id)
  resource_group_name   = var.addon_resource_group_name
  private_dns_zone_name = var.existing_private_dns_zone == null ? join("", azurerm_private_dns_zone.dnszone1.*.name) : var.existing_private_dns_zone
  virtual_network_id    = var.addon_virtual_network_id
  tags                  = module.labels.tags
}

##----------------------------------------------------------------------------- 
## Below resource will create a-record in private dns zone when private dns zone is in same subscription.   
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_a_record" "arecord-same_sub" {
  count               = var.enable && var.enable_private_endpoint && var.diff_sub == false ? 1 : 0
  name                = join("", azurerm_container_registry.main.*.name)
  zone_name           = local.private_dns_zone_name
  resource_group_name = local.valid_rg_name
  ttl                 = 3600
  records             = [data.azurerm_private_endpoint_connection.private-ip.0.private_service_connection.0.private_ip_address]
  tags                = module.labels.tags
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

##----------------------------------------------------------------------------- 
## Below resource will create a-record in private dns zone when private dns zone is in different subscription.   
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_a_record" "arecord_diff-sub" {
  count               = var.enable && var.enable_private_endpoint && var.diff_sub == true ? 1 : 0
  provider            = azurerm.peer
  name                = join("", azurerm_container_registry.main.*.name)
  zone_name           = local.private_dns_zone_name
  resource_group_name = local.valid_rg_name
  ttl                 = 3600
  records             = [data.azurerm_private_endpoint_connection.private-ip.0.private_service_connection.0.private_ip_address]
  tags                = module.labels.tags
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

##----------------------------------------------------------------------------- 
## Below resource will create diagnostic setting for ACR.   
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "acr-diag" {
  count                      = var.enable && var.enable_diagnostic ? 1 : 0
  name                       = lower("acr-${var.container_registry_config.name}-diag")
  target_resource_id         = azurerm_container_registry.main[0].id
  storage_account_id         = var.storage_account_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "log" {
    for_each = var.acr_diag_logs
    content {
      category = log.value
      enabled  = true

      retention_policy {
        enabled = false
        days    = 0
      }
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
      days    = 0
    }
  }

  lifecycle {
    ignore_changes = [log, metric]
  }
}
