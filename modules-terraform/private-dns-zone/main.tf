# Acestus Private DNS Zone Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-network-privatednszone/azurerm

module "private_dns_zone" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "~> 0.5"

  resource_group_name = var.resource_group_name
  domain_name         = var.name

  # Virtual network links
  virtual_network_links = var.virtual_network_links

  # DNS records
  a_records     = var.a_records
  aaaa_records  = var.aaaa_records
  cname_records = var.cname_records
  mx_records    = var.mx_records
  ptr_records   = var.ptr_records
  srv_records   = var.srv_records
  txt_records   = var.txt_records

  # SOA record
  soa_record = var.soa_record

  # Role assignments
  role_assignments = var.role_assignments

  # Tags
  tags = var.tags
}
