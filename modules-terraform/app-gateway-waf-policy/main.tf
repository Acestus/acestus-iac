# Acestus Application Gateway WAF Policy Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-network-applicationgatewaywebapplicationfirewallpolicy/azurerm

module "waf_policy" {
  source  = "Azure/avm-res-network-applicationgatewaywebapplicationfirewallpolicy/azurerm"
  version = "~> 0.2"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Policy settings (Acestus standards - Prevention mode by default)
  policy_settings = {
    enabled                     = var.policy_state == "Enabled"
    mode                        = var.policy_mode
    request_body_check          = var.request_body_check
    max_request_body_size_in_kb = var.max_request_body_size_in_kb
    file_upload_limit_in_mb     = var.file_upload_limit_in_mb
  }

  # Managed rules
  managed_rules = {
    managed_rule_sets = [
      for rule in var.managed_rules : {
        type    = rule.type
        version = rule.version
        rule_group_overrides = rule.rule_group_overrides != null ? [
          for override in rule.rule_group_overrides : {
            rule_group_name = override.rule_group_name
            rules           = override.rules
          }
        ] : []
      }
    ]
  }

  # Custom rules
  custom_rules = [
    for rule in var.custom_rules : {
      name      = rule.name
      priority  = rule.priority
      rule_type = rule.rule_type
      action    = rule.action
      match_conditions = [
        for condition in rule.match_conditions : {
          match_variables    = condition.match_variables
          operator           = condition.operator
          negation_condition = condition.negation_condition
          match_values       = condition.match_values
          transforms         = condition.transforms
        }
      ]
    }
  ]

  # Tags
  tags = var.tags
}
