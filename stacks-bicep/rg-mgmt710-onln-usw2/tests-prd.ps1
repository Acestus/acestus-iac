$Subscription = "Onln-710-Analytics"
$StackName = "stack-mgmt710-onln-eus2-prd"
$RGName = "rg-mgmt710-onln-eus2-prd"
$storageAccountName = "stmgmt710onlneus2prd"


Set-AzContext -Subscription $Subscription
Get-AzSubscription -SubscriptionName $Subscription
Get-AzResourceGroup -Name $RGName | Format-Table
Get-AzResourceGroupDeploymentStack -Name $StackName -ResourceGroupName $RGName 
Get-AzStorageAccount -ResourceGroupName $RGName -Name $storageAccountName | Format-Table