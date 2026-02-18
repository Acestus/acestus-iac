module "DNSZone01RG" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "~> 0.2"
  name     = local.DNSZone01RGName
  location = local.Location
}

module "DNSZone01" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "~> 0.2"
  resource_group_name = local.DNSZone01RGName
  domain_name = local.DNSZone01Name

  depends_on = [ module.DNSZone01RG ]
}


resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "Ruleset01" {
  name                                       = local.DNSRulesetName
  resource_group_name                        = local.DNSZone01RGName
  location                                   = local.Location
  private_dns_resolver_outbound_endpoint_ids = [azurerm_private_dns_resolver_outbound_endpoint.Endpoint01.id]

  depends_on = [ module.DNSZone01RG, azurerm_private_dns_resolver_outbound_endpoint.Endpoint01 ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub_dns_link" {
  name                  = local.HubLinkName
  resource_group_name   = local.DNSZone01RGName
  private_dns_zone_name = local.DNSZone01Name
  virtual_network_id    = local.HubVNetId
  registration_enabled  = false
  
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke1_dns_link" {
  name                  = local.Spoke01LinkName
  resource_group_name   = local.DNSZone01RGName
  private_dns_zone_name = local.DNSZone01Name
  virtual_network_id    = local.Spoke01VNetId
  registration_enabled  = false
  
}




