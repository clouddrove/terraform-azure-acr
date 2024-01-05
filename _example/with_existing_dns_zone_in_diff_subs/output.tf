# output "resource_group_id" {
#   value       = module.resource_group.resource_group_id
#   description = "The ID of the Resource Group"
# }

# output "vnet_id" {
#   value       = module.vnet.vnet_id
#   description = "The ID of the Virtual Network"
# }

# output "subnet_id" {
#   value       = module.subnet.default_subnet_id
#   description = "The ID of the Subnet"
# }

# output "log_analytics_workspace_id" {
#   value       = module.log-analytics.workspace_id
#   description = "The ID of the Log Analytics Workspace"
# }

# output "container_registry_id" {
#   value       = module.container-registry.container_registry_id
#   description = "The ID of the Container Registry"
# }

# output "container_registry_private_endpoint" {
#     value       = module.container-registry.container_registry_private_endpoint
#     description = "The ID of the Azure Container Registry Private Endpoint"
# }

# output "container_registry_private_dns_zone_domain" {
#     value       = var.existing_private_dns_zone == null && var.enable_private_endpoint ? azurerm_private_dns_zone.dnszone1[0].name : var.existing_private_dns_zone
#     description = "DNS zone name of Azure Container Registry Private endpoints dns name records"
# }

# output "container_registry_login_server" {
#   value       = module.container-registry.container_registry_login_server
#   description = "The URL that can be used to log into the Container Registry"
# }

# output "container_registry_admin_username" {
#   value       = module.container-registry.container_registry_admin_username
#   description = "The Username associated with the Container Registry Admin account"
# }

# output "container_registry_identity_principal_id" {
#   value       = module.container-registry.container_registry_identity_principal_id
#   description = "The Principal ID for the Service Principal associated with the Managed Service Identity of the Container Registry"
# }

# output "container_registry_identity_tenant_id" {
#   value       = module.container-registry.container_registry_identity_tenant_id
#   description = "The Tenant ID for the Service Principal associated with the Managed Service Identity of the Container Registry"
# }
