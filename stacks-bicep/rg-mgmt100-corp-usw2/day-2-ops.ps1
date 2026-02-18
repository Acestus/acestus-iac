$CAFName = "mgmt100-corp-eus2"
$CAFLocation = "eus2"
$Instance = "dev"
$Subscription = ""
$Location = "westus2"

$Path = "~/git/bicep-infra/$CAFName"
$TemplateFile = "$Path/$CAFName.bicep"
$ParameterFile = "$Path/$CAFName-$Instance.bicepparam"
$RGName = "rg-$CAFName-$Instance"
$StackName = "stack-$CAFName-$Instance"


# Get deployment stack status
Get-AzResourceGroupDeploymentStack -Name $StackName -ResourceGroupName $RGName

# Check for drift 
Get-AzResourceGroupDeploymentWhatIfResult -Name $StackName -Location $Location -TemplateFile $TemplateFile -TemplateParameterFile $ParameterFile -ResourceGroupName $RGName

# Connect to Azure (if not already connected)
Set-AzContext -Subscription $Subscription

# Create Resource Group
New-AzResourceGroup -Name $RGName -Location $Location 

# Validate template files
Test-AzResourceGroupDeployment -Location $Location -TemplateFile $templateFile -TemplateParameterFile $ParameterFile -ResourceGroupName $RGName

# Create new deployment stack
New-AzResourceGroupDeploymentStack -Name $StackName -Location $Location -TemplateFile $templateFile -TemplateParameterFile $ParameterFile -ActionOnUnmanage 'deleteResources' -DenySettingsMode None -ResourceGroupName $RGName 

# Update deployment stack
Set-AzResourceGroupDeploymentStack -Name $StackName -Location $Location -DenySettingsMode None -TemplateParameterFile $ParameterFile -ActionOnUnmanage 'deleteResources' -ResourceGroupName $RGName 

# Delete deployment stack
Remove-AzResourceGroupDeploymentStack -Name $StackName -ResourceGroupName $RGName -ActionOnUnmanage DeleteResources