terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}
terraform {
  required_version = ">= 1.0"
  
  # ⬇️ ADD THIS EMPTY BLOCK TO RESOLVE THE WARNING ⬇️
  backend "azurerm" {
    # Keep this completely blank! 
    # Your Azure DevOps pipeline injects the storage account details here dynamically.
  }

  
}

provider "azurerm" {
  features {}
}
terraform {
  backend "azurerm" {
    resource_group_name  = "MyResourceGroup"
    storage_account_name = "test123storage"
    container_name       = "test123container" 
    key                  = "terraform.tfstate"
  }
}
