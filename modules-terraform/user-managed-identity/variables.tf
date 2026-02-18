# Acestus User Managed Identity Module Variables

variable "name" {
  type        = string
  description = "The name of the User Assigned Managed Identity"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the User Assigned Managed Identity"
}

variable "federated_identity_credentials" {
  type = map(object({
    name      = string
    audiences = optional(list(string), ["api://AzureADTokenExchange"])
    issuer    = string
    subject   = string
  }))
  description = "Federated identity credentials for workload identity (e.g., GitHub Actions, Kubernetes)"
  default     = {}
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the User Assigned Managed Identity"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the User Assigned Managed Identity"
  default     = {}
}
