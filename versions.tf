# Terraform version
terraform {
  required_version = ">= 1.0.0"
  #experiments      = [module_variable_optional_attrs]
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.90.0"
    }
  }
}