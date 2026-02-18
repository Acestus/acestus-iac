$subscriptions = Get-AzSubscription
# Prompt the user to select a subscription by a numbered list
# create the numbered list
$subscriptionList = @()
for ($i = 0; $i -lt $subscriptions.Length; $i++) {
    $number = $i + 1
    $subscriptionList += "${number}. $($subscriptions[$i].Name)"
}
$subscriptionList
$userSubscription = Read-Host "Enter the subscription number to get a list of subnets"
$subscription = $subscriptions[$userSubscription - 1]
# Set the current subscription
Set-AzContext -SubscriptionId $subscription.Id

$vnets = Get-AzVirtualNetwork
foreach ($vnet in $vnets) {
    $subnets = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet
    foreach ($subnet in $subnets) {
        Write-Output "$($subnet.Id)"
    }
}