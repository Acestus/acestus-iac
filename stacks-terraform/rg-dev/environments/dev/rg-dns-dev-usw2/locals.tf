locals {
  Location       = "westus2"
  SubscriptionId = "8a0d1fba-54d6-4f26-86a9-04aa58ba7fb0"
  DNSZone01RGName = "rg-dns-dev-sea"
  DNSZone01Name   = "test1.privatelink.westus2.azmk8s.io"
  DNSRulesetName = "rs-dev-sea-001"

  HubLinkName     = "dns-link-hub"
  HubVNetId       = "/subscriptions/<subscription-id>/resourceGroups/rg-tftest-dev-sea-hub/providers/Microsoft.Network/virtualNetworks/vnet-tftest-dev-sea-hub"
  HubSubnets = {
    subnet1 = {
      name             = "Subnet1"
      id               = "/subscriptions/<subscription-id>/resourceGroups/rg-tftest-dev-sea-hub/providers/Microsoft.Network/virtualNetworks/vnet-tftest-dev-sea-hub/subnets/Subnet1"
    } 
  }

  Spoke01LinkName = "dns-link-spoke1"
  Spoke01VNetId     = "/subscriptions/<subscription-id>/resourceGroups/rg-tftest-dev-sea-001/providers/Microsoft.Network/virtualNetworks/vnet-tftest-dev-sea-001"

}
