$Subscription = "Sbox-LearningLab"
$StackName = "stack-mgmt520-onln-eus2-dev"
$RGName = "rg-mgmt520-onln-eus2-dev"
$storageAccountName = "stmgmt520onlneus2dev"

Set-AzContext -Subscription $Subscription
Get-AzSubscription -SubscriptionName $Subscription
Get-AzResourceGroup -Name $RGName | Format-Table
Get-AzResourceGroupDeploymentStack -Name $StackName -ResourceGroupName $RGName
Get-AzStorageAccount -ResourceGroupName $RGName -Name $storageAccountName | Format-Table
