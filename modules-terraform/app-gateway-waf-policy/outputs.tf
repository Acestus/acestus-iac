# Acestus Application Gateway WAF Policy Module Outputs

output "resource_id" {
  description = "The resource ID of the WAF policy"
  value       = module.waf_policy.resource_id
}

output "name" {
  description = "The name of the WAF policy"
  value       = module.waf_policy.name
}

output "resource" {
  description = "The full WAF policy resource object"
  value       = module.waf_policy.resource
}
