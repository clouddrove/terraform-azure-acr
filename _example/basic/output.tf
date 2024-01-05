output "vnet_id" {
  value       = module.vnet.vnet_id
  description = "The ID of the Virtual Network"
}

output "subnet_id" {
  value       = module.subnet.default_subnet_id
  description = "The ID of the Subnet"
}

output "container_registry_id" {
  value       = module.container-registry.container_registry_id
  description = "The ID of the Container Registry"
}
