# AKS Stack - Staging Environment
# terraform apply -var-file=environments/stg/terraform.tfvars

# ============================================================================
# Naming
# ============================================================================

project_name    = "newaks"
environment     = "stg"
caf_location    = "usw2"
instance_number = "001"
location        = "West US 2"

# ============================================================================
# Kubernetes Configuration
# ============================================================================

kubernetes_version = "1.30"
sku_tier           = "Free"
system_pool_size   = "Standard"
agent_pool_size    = ""  # No agent pool for staging

# ============================================================================
# Monitoring
# ============================================================================

# Replace with your Log Analytics workspace resource ID
monitoring_workspace_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-monitoring"

# Optional: Principal ID for Key Vault access (defaults to deploying identity)
principal_id = ""

# ============================================================================
# Tags
# ============================================================================

tags = {
  CostCenter  = "staging"
  Owner       = "platform-team"
  Application = "aks-newaks"
}
