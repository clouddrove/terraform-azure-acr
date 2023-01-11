<!-- This file was automatically generated by the `geine`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->

<p align="center"> <img src="https://user-images.githubusercontent.com/50652676/62349836-882fef80-b51e-11e9-99e3-7b974309c7e3.png" width="100" height="100"></p>


<h1 align="center">
    Terraform AZURE CONTAINER REGISTRY (ACR)


</h1>

<p align="center" style="font-size: 1.2rem;"> 
    Terraform module to create acr resource on AZURE.
     </p>

<p align="center">

<a href="https://www.terraform.io">
  <img src="https://img.shields.io/badge/Terraform-v1.0.0-green" alt="Terraform">
</a>
<a href="LICENSE.md">
  <img src="https://img.shields.io/badge/License-APACHE-blue.svg" alt="Licence">
</a>


</p>
<p align="center">

<a href='https://facebook.com/sharer/sharer.php?u=https://github.com/clouddrove/terraform-azure-acr'>
  <img title="Share on Facebook" src="https://user-images.githubusercontent.com/50652676/62817743-4f64cb80-bb59-11e9-90c7-b057252ded50.png" />
</a>
<a href='https://www.linkedin.com/shareArticle?mini=true&title=Terraform+AZURE+CONTAINER+REGISTRY+(ACR)&url=https://github.com/clouddrove/terraform-azure-acr'>
  <img title="Share on LinkedIn" src="https://user-images.githubusercontent.com/50652676/62817742-4e339e80-bb59-11e9-87b9-a1f68cae1049.png" />
</a>
<a href='https://twitter.com/intent/tweet/?text=Terraform+AZURE+CONTAINER+REGISTRY+(ACR)&url=https://github.com/clouddrove/terraform-azure-acr'>
  <img title="Share on Twitter" src="https://user-images.githubusercontent.com/50652676/62817740-4c69db00-bb59-11e9-8a79-3580fbbf6d5c.png" />
</a>

</p>
<hr>


We eat, drink, sleep and most importantly love **DevOps**. We are working towards strategies for standardizing architecture while ensuring security for the infrastructure. We are strong believer of the philosophy <b>Bigger problems are always solved by breaking them into smaller manageable problems</b>. Resonating with microservices architecture, it is considered best-practice to run database, cluster, storage in smaller <b>connected yet manageable pieces</b> within the infrastructure. 

This module is basically combination of [Terraform open source](https://www.terraform.io/) and includes automatation tests and examples. It also helps to create and improve your infrastructure with minimalistic code instead of maintaining the whole infrastructure code yourself.

We have [*fifty plus terraform modules*][terraform_modules]. A few of them are comepleted and are available for open source usage while a few others are in progress.




## Prerequisites

This module has a few dependencies: 

- [Terraform 1.x.x](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [Go](https://golang.org/doc/install)
- [github.com/stretchr/testify/assert](https://github.com/stretchr/testify)
- [github.com/gruntwork-io/terratest/modules/terraform](https://github.com/gruntwork-io/terratest)







## Examples


**IMPORTANT:** Since the `master` branch used in `source` varies based on new modifications, we suggest that you use the release versions [here](https://github.com/clouddrove/terraform-azure-acr/releases).


### Simple Example
Here is an example of how you can use this module in your inventory structure:
```hcl
  module "container-registry" {
      source               = "clouddrove/acr/azure"
      resource_group_name  = module.resource_group.resource_group_name
      location             = module.resource_group.resource_group_location
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

  ```






## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| acr\_diag\_logs | Application Gateway Monitoring Category details for Azure Diagnostic setting | `list` | <pre>[<br>  "ContainerRegistryRepositoryEvents",<br>  "ContainerRegistryLoginEvents"<br>]</pre> | no |
| container\_registry\_config | Manages an Azure Container Registry | <pre>object({<br>    name                          = string<br>    admin_enabled                 = optional(bool)<br>    sku                           = optional(string)<br>    public_network_access_enabled = optional(bool)<br>    quarantine_policy_enabled     = optional(bool)<br>    zone_redundancy_enabled       = optional(bool)<br>  })</pre> | n/a | yes |
| container\_registry\_webhooks | Manages an Azure Container Registry Webhook | <pre>map(object({<br>    service_uri    = string<br>    actions        = list(string)<br>    status         = optional(string)<br>    scope          = string<br>    custom_headers = map(string)<br>  }))</pre> | `null` | no |
| enable\_content\_trust | Boolean value to enable or disable Content trust in Azure Container Registry | `bool` | `false` | no |
| enable\_private\_endpoint | Manages a Private Endpoint to Azure Container Registry | `bool` | `false` | no |
| encryption | Encrypt registry using a customer-managed key | <pre>object({<br>    key_vault_key_id   = string<br>    identity_client_id = string<br>  })</pre> | `null` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| existing\_private\_dns\_zone | Name of the existing private DNS zone | `any` | `null` | no |
| georeplications | A list of Azure locations where the container registry should be geo-replicated | <pre>list(object({<br>    location                = string<br>    zone_redundancy_enabled = optional(bool)<br>  }))</pre> | `[]` | no |
| identity\_ids | Specifies a list of user managed identity ids to be assigned. This is required when `type` is set to `UserAssigned` or `SystemAssigned, UserAssigned` | `any` | `null` | no |
| label\_order | Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] . | `list(any)` | `[]` | no |
| location | The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table' | `string` | `""` | no |
| log\_analytics\_workspace\_id | log\_analytics\_workspace\_id | `string` | `null` | no |
| log\_analytics\_workspace\_name | The name of log analytics workspace name | `any` | `null` | no |
| managedby | ManagedBy, eg ''. | `string` | `""` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| network\_rule\_set | Manage network rules for Azure Container Registries | <pre>object({<br>    default_action = optional(string)<br>    ip_rule = optional(list(object({<br>      ip_range = string<br>    })))<br>    virtual_network = optional(list(object({<br>      subnet_id = string<br>    })))<br>  })</pre> | `null` | no |
| private\_dns\_name | n/a | `string` | `""` | no |
| private\_dns\_zone\_vnet\_link\_registration\_enabled | (Optional) Is auto-registration of virtual machine records in the virtual network in the Private DNS zone enabled? | `bool` | `true` | no |
| private\_subnet\_address\_prefix | The name of the subnet for private endpoints | `any` | `null` | no |
| repository | Terraform current module repo | `string` | `""` | no |
| resource\_group\_name | A container that holds related resources for an Azure solution | `string` | `""` | no |
| retention\_policy | Set a retention policy for untagged manifests | <pre>object({<br>    days    = optional(number)<br>    enabled = optional(bool)<br>  })</pre> | `null` | no |
| scope\_map | Manages an Azure Container Registry scope map. Scope Maps are a preview feature only available in Premium SKU Container registries. | <pre>map(object({<br>    actions = list(string)<br>  }))</pre> | `null` | no |
| storage\_account\_id | n/a | `string` | `null` | no |
| storage\_account\_name | The name of the hub storage account to store logs | `any` | `null` | no |
| subnet\_id | Subnet to be used for private endpoint | `list(string)` | `null` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |
| virtual\_network\_id | Virtual Network to be used for private endpoint | `string` | `null` | no |
| virtual\_network\_name | The name of the virtual network | `string` | `""` | no |

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
| container\_registry\_private\_endpoint\_fqdn | Azure Container Registry private endpoint FQDN Addresses |
| container\_registry\_private\_endpoint\_ip\_addresses | Azure Container Registry private endpoint IPv4 Addresses |
| container\_registry\_scope\_map\_id | The ID of the Container Registry scope map |
| container\_registry\_token\_id | The ID of the Container Registry token |
| container\_registry\_webhook\_id | The ID of the Container Registry Webhook |




## Testing
In this module testing is performed with [terratest](https://github.com/gruntwork-io/terratest) and it creates a small piece of infrastructure, matches the output like ARN, ID and Tags name etc and destroy infrastructure in your AWS account. This testing is written in GO, so you need a [GO environment](https://golang.org/doc/install) in your system. 

You need to run the following command in the testing folder:
```hcl
  go test -run Test
```



## Feedback 
If you come accross a bug or have any feedback, please log it in our [issue tracker](https://github.com/clouddrove/terraform-azure-acr/issues), or feel free to drop us an email at [hello@clouddrove.com](mailto:hello@clouddrove.com).

If you have found it worth your time, go ahead and give us a ★ on [our GitHub](https://github.com/clouddrove/terraform-azure-acr)!

## About us

At [CloudDrove][website], we offer expert guidance, implementation support and services to help organisations accelerate their journey to the cloud. Our services include docker and container orchestration, cloud migration and adoption, infrastructure automation, application modernisation and remediation, and performance engineering.

<p align="center">We are <b> The Cloud Experts!</b></p>
<hr />
<p align="center">We ❤️  <a href="https://github.com/clouddrove">Open Source</a> and you can check out <a href="https://github.com/clouddrove">our other modules</a> to get help with your new Cloud ideas.</p>

  [website]: https://clouddrove.com
  [github]: https://github.com/clouddrove
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://twitter.com/clouddrove/
  [email]: https://clouddrove.com/contact-us.html
  [terraform_modules]: https://github.com/clouddrove?utf8=%E2%9C%93&q=terraform-&type=&language=
