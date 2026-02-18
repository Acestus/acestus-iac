$subscription = "Sbox-510-Infrastructure"
$resourceGroup = "log-data"
$templateSpecId = "/subscriptions/<subscription-id>/resourceGroups/TemplateSpecs/providers/Microsoft.Resources/templateSpecs/DeployStorageAccount"
$params = @{
    ProjectName = "logdata"
    Environment = "dev"
    InstanceNumber = "002"
}
Set-AzContext -Subscription $subscription
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup `
    -TemplateId $templateSpecId `
    -TemplateParameterObject $params