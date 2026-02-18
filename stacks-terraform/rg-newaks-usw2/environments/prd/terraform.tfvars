# AKS Stack - Production Environment
# terraform apply -var-file=environments/prd/terraform.tfvars

# ============================================================================
# Naming
# ============================================================================

project_name    = "newaks"
environment     = "prd"
caf_location    = "usw2"
instance_number = "001"
location        = "West US 2"

# ============================================================================
# Kubernetes Configuration
# ============================================================================

kubernetes_version = "1.30"
sku_tier           = "Standard"       # Standard tier for production SLA
system_pool_size   = "Standard"       # Standard VMs for system pool
agent_pool_size    = "HighSpec"       # HighSpec VMs for agent pool

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
  CostCenter  = "production"
  Owner       = "platform-team"
  Application = "aks-newaks"
  Criticality = "high"
}
