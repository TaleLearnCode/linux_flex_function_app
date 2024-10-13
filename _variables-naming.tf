# #############################################################################
# Variables: Naming
# #############################################################################

variable "name_prefix" {
  type        = string
  default     = ""
  description = "Optional prefix to apply to the generated name."
}

variable "name_suffix" {
  type        = string
  default     = ""
  description = "Optional suffix to apply to the generated name."
}

variable "srv_comp_abbr" {
  type        = string
  default     = ""
  description = "The abbreviation of the service component for which the resources are being created."
}

variable "custom_name" {
  type        = string
  default     = null
  description = "If set, custom name to use instead of the generated name"
}