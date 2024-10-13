# #############################################################################
# Variables: Tags
# #############################################################################

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to apply to all resources."
}