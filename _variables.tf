# #############################################################################
# Define the variables that will be used in the Terraform configuration
# #############################################################################

variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group in which the Function App will be created."
}

variable "maximumInstanceCount" {
  type        = number
  default     = 100
  description = "The maximum number of instances that the Function App can scale out to."
}

variable "instanceMemoryMB" {
  type        = number
  default     = 2048
  description = "The amount of memory in MB that each instance of the Function App will have. Allowed values are 2048 and 4096."
  validation {
    condition = can(index([2048, 4096], var.instanceMemoryMB))
    error_message = "The instance memory must be either 2048 or 4096."
  }
}

variable "functionAppRuntime" {
  type        = string
  default     = "dotnet-isolated"
  description = "The runtime that the Function App will use. Allowed values are `dotnet-isolated`, `python`, `java`, `node`, and `powershell`. The default is `dotnet-isolated`."
  validation {
    condition = can(regex("^(dotnet-isolated|python|java|node|powershell)$", var.functionAppRuntime))
    error_message = "The runtime must be one of 'dotnet-isolated', 'python', 'java', 'node', or 'powershell'."
  }
}

variable "functionAppRuntimeVersion" {
  type        = string
  default     = "8.0"
  description = "The version of the runtime that the Function App will use. Allowed values are '3.10, '3.11', '7.4', '8.0', '10', '11', '17', or '20'. The default is `8.0`."
}

variable "application_insights_connection_string" {
  type        = string
  description = "The connection string for the Application Insights resource."
}