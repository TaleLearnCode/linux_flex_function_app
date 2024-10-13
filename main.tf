# #############################################################################
# Manaage the Azure Function App
# #############################################################################

module "app_service_plan_name" {
  source  = "TaleLearnCode/naming/azurerm"
  version = "0.0.6-pre"

  resource_type  = "app_service_plan"
  name_prefix    = var.name_prefix
  name_suffix    = var.name_suffix
  srv_comp_abbr  = var.srv_comp_abbr
  custom_name    = var.custom_name
  location       = var.location
  environment    = var.environment
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azapi_resource" "serverFarm" {
  type = "Microsoft.Web/serverfarms@2023-12-01"
  schema_validation_enabled = false
  location = var.location
  name = module.app_service_plan_name.resource_name
  parent_id = data.azurerm_resource_group.rg.id
  body = jsonencode({
      kind = "functionapp",
      sku = {
        tier = "FlexConsumption",
        name = "FC1"
      },
      properties = {
        reserved = true
      }
  })
}

module "storage_account" {
  source  = "TaleLearnCode/storage_account/azurerm"
  version = "0.0.6-pre"
  providers = {
    azurerm = azurerm
  }

  environment         = var.environment
  location            = var.location
  resource_group_name = module.resource_group.resource_name
  srv_comp_abbr       = var.srv_comp_abbr
  name_suffix         = "func"
  
  containers = {
    "deploymentpackage" = {
      container_access_type = "private"
    }
  }
}

locals {
  blobStorageAndContainer = "${module.storage_account.storage_account.primary_blob_endpoint}deploymentpackage"
}

module "function_app_name" {
  source  = "TaleLearnCode/naming/azurerm"
  version = "0.0.6-pre"

  resource_type  = "function_app"
  name_prefix    = var.name_prefix
  name_suffix    = var.name_suffix
  srv_comp_abbr  = var.srv_comp_abbr
  custom_name    = var.custom_name
  location       = var.location
  environment    = var.environment
}

resource "azapi_resource" "functionApp" {
  type = "Microsoft.Web/sites@2023-12-01"
  schema_validation_enabled = false
  location = var.location
  name = module.function_app_name.resource_name
  parent_id = data.azurerm_resource_group.rg.id
  body = jsonencode({
    kind = "functionapp,linux",
    identity = {
      type: "SystemAssigned"
    }
    properties = {
      serverFarmId = azapi_resource.serverFarm.id,
        functionAppConfig = {
          deployment = {
            storage = {
              type = "blobContainer",
              value = local.blobStorageAndContainer,
              authentication = {
                type = "SystemAssignedIdentity"
              }
            }
          },
          scaleAndConcurrency = {
            maximumInstanceCount = var.maximumInstanceCount,
            instanceMemoryMB = var.instanceMemoryMB
          },
          runtime = { 
            name = var.functionAppRuntime, 
            version = var.functionAppRuntimeVersion
          }
        },
        siteConfig = {
          appSettings = [
            {
              name = "AzureWebJobsStorage__accountName",
              value = module.storage_account.storage_account.name
            },
            {
              name = "APPLICATIONINSIGHTS_CONNECTION_STRING",
              value = var.application_insights_connection_string
            }
          ]
        }
      }
  })
  depends_on = [ azapi_resource.serverFarm, module.storage_account ]
}

data "azurerm_linux_function_app" "function_app" {
  name                = module.function_app_name.resource_name
  resource_group_name = var.resource_group_name
  depends_on = [ azapi_resource.functionApp ]
}

resource "azurerm_role_assignemnt" "storage_roleassignment" {
  scope                = module.storage_account.storage_account.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_linux_function_app.function_app.identity.0.principal_id
  depends_on = [ data.azurerm_function_app.function_app ]
}