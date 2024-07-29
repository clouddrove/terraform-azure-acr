## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| addon\_resource\_group\_name | The name of the addon vnet resource group | `string` | `""` | no |
| addon\_vent\_link | The name of the addon vnet | `bool` | `false` | no |
| addon\_virtual\_network\_id | The name of the addon vnet link vnet id | `string` | `""` | no |
| admin\_enabled | To enable of disable admin access | `bool` | `true` | no |
| azure\_services\_bypass | Whether to allow trusted Azure services to access a network restricted Container Registry? Possible values are None and AzureServices. Defaults to AzureServices | `string` | `"AzureServices"` | no |
| container\_registry\_config | Manages an Azure Container Registry | <pre>object({<br>    name                      = string<br>    sku                       = optional(string)<br>    quarantine_policy_enabled = optional(bool)<br>    zone_redundancy_enabled   = optional(bool)<br>  })</pre> | n/a | yes |
| container\_registry\_webhooks | Manages an Azure Container Registry Webhook | <pre>map(object({<br>    service_uri    = string<br>    actions        = list(string)<br>    status         = optional(string)<br>    scope          = string<br>    custom_headers = map(string)<br>  }))</pre> | `null` | no |
| diff\_sub | Flag to tell whether dns zone is in different sub or not. | `bool` | `false` | no |
| enable | Flag to control module creation. | `bool` | `true` | no |
| enable\_content\_trust | Boolean value to enable or disable Content trust in Azure Container Registry | `bool` | `true` | no |
| enable\_diagnostic | Flag to control diagnostic setting resource creation. | `bool` | `true` | no |
| enable\_private\_endpoint | Manages a Private Endpoint to Azure Container Registry | `bool` | `true` | no |
| enable\_rotation\_policy | Whether to enable rotation policy or not | `bool` | `false` | no |
| encryption | n/a | `bool` | `false` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| existing\_private\_dns\_zone | Name of the existing private DNS zone | `string` | `null` | no |
| existing\_private\_dns\_zone\_id | ID of existing private dns zone. To be used in dns configuration group in private endpoint. | `list(any)` | `null` | no |
| existing\_private\_dns\_zone\_resource\_group\_name | The name of the existing resource group | `string` | `null` | no |
| georeplications | A list of Azure locations where the container registry should be geo-replicated | <pre>list(object({<br>    location                = string<br>    zone_redundancy_enabled = optional(bool)<br>  }))</pre> | `[]` | no |
| identity\_ids | Specifies a list of user managed identity ids to be assigned. This is required when `type` is set to `UserAssigned` or `SystemAssigned, UserAssigned` | `list(string)` | `null` | no |
| key\_vault\_id | n/a | `string` | `null` | no |
| key\_vault\_rbac\_auth\_enabled | n/a | `bool` | `true` | no |
| label\_order | Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] . | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| location | The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table' | `string` | `null` | no |
| log\_analytics\_workspace\_id | log\_analytics\_workspace\_id | `string` | `null` | no |
| log\_enabled | Is this Diagnostic Log enabled? Defaults to true. | `string` | `true` | no |
| managedby | ManagedBy, eg ''. | `string` | `""` | no |
| metric\_enabled | Is this Diagnostic Metric enabled? Defaults to True. | `bool` | `true` | no |
| multi\_sub\_vnet\_link | Flag to control creation of vnet link for dns zone in different subscription | `bool` | `false` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| network\_rule\_set | Manage network rules for Azure Container Registries | <pre>object({<br>    default_action = optional(string)<br>    ip_rule = optional(list(object({<br>      ip_range = string<br>    })))<br>    virtual_network = optional(list(object({<br>      subnet_id = string<br>    })))<br>  })</pre> | `null` | no |
| private\_dns\_name | n/a | `string` | `"privatelink.azurecr.io"` | no |
| private\_dns\_zone\_vnet\_link\_registration\_enabled | (Optional) Is auto-registration of virtual machine records in the virtual network in the Private DNS zone enabled? | `bool` | `true` | no |
| public\_network\_access\_enabled | To denied public access | `bool` | `false` | no |
| repository | Terraform current module repo | `string` | `""` | no |
| resource\_group\_name | A container that holds related resources for an Azure solution | `string` | `null` | no |
| retention\_policy | Set a retention policy for untagged manifests | <pre>object({<br>    days    = optional(number)<br>    enabled = optional(bool)<br>  })</pre> | <pre>{<br>  "days": 10,<br>  "enabled": true<br>}</pre> | no |
| same\_vnet | Variable to be set when multiple acr having common DNS in same vnet. | `bool` | `false` | no |
| scope\_map | Manages an Azure Container Registry scope map. Scope Maps are a preview feature only available in Premium SKU Container registries. | <pre>map(object({<br>    actions = list(string)<br>  }))</pre> | `null` | no |
| storage\_account\_id | Storage account id to pass it to destination details of diagnostic\_setting. | `string` | `null` | no |
| subnet\_id | Subnet to be used for private endpoint | `string` | `null` | no |
| virtual\_network\_id | Virtual Network to be used for private endpoint | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| container\_registry\_admin\_password | The Username associated with the Container Registry Admin account - if the admin account is enabled. |
| container\_registry\_admin\_username | The Username associated with the Container Registry Admin account - if the admin account is enabled. |
| container\_registry\_id | The ID of the Container Registry |
| container\_registry\_identity\_principal\_id | The Principal ID for the Service Principal associated with the Managed Service Identity of this Container Registry |
| container\_registry\_identity\_tenant\_id | The Tenant ID for the Service Principal associated with the Managed Service Identity of this Container Registry |
| container\_registry\_login\_server | The URL that can be used to log into the container registry |
| container\_registry\_private\_dns\_zone\_domain | DNS zone name of Azure Container Registry Private endpoints dns name records |
| container\_registry\_private\_endpoint | The ID of the Azure Container Registry Private Endpoint |
| container\_registry\_scope\_map\_id | The ID of the Container Registry scope map |
| container\_registry\_token\_id | The ID of the Container Registry token |
| container\_registry\_webhook\_id | The ID of the Container Registry Webhook |

