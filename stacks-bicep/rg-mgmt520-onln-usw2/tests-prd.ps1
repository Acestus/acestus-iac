$Subscription = "Onln-520-ApplicationDevelopment"
$StackName = "stack-mgmt520-onln-usw2-prd"
$RGName = "rg-mgmt520-onln-usw2-prd"
$storageAccountName = "stmgmt520onlnusw2prd"

Set-AzContext -Subscription $Subscription
Get-AzSubscription -SubscriptionName $Subscription
Get-AzResourceGroup -Name $RGName | Format-Table
Get-AzResourceGroupDeploymentStack -Name $StackName -ResourceGroupName $RGName 
Get-AzStorageAccount -ResourceGroupName $RGName -Name $storageAccountName | Format-Table