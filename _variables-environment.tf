# #############################################################################
# Variables: Environment
# #############################################################################

variable "location" {
  type        = string
  description = "The Azure Region in which all resources will be created."
}

variable "environment" {
  type        = string
  description = "The environment within the resources are being deployed to."
}