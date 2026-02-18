$ProjectName = ""
$CAFLocation = "eus2"
$Instance = ""
$Owner = ""
$Subscription = ""
$Location = "westus2"

$Environment = $Subscription.Substring(0, 4).ToLower()
$Path = "~/git/bicep-infra/$ProjectName-$Environment-$CAFLocation"
$TemplateFile = "$Path/$ProjectName-$Environment-$CAFLocation.bicep"
$ParameterFile = "$Path/$ProjectName-$Environment-$CAFLocation.bicepparam"
$RGName = "rg-$ProjectName-$Environment-$CAFLocation"
$StackName = "stack-$ProjectName-$Environment-$CAFLocation-$Instance"
$Tags = @{'CostCenter'=$Subscription; 'Environment'=$Environment; 'Project'=$ProjectName; 'ManagedBy'=$Path; 'Owner'=$Owner;'Workload'=$instance}

# Get deployment stack status
Get-AzResourceGroupDeploymentStack -Name $StackName -ResourceGroupName $RGName

# Check for drift 
Get-AzResourceGroupDeploymentWhatIfResult -Name $StackName -Location $Location -TemplateFile $TemplateFile -TemplateParameterFile $ParameterFile -ResourceGroupName $RGName

# Connect to Azure (if not already connected)
Set-AzContext -Subscription $Subscription

# Create Resource Group
New-AzResourceGroup -Name $RGName -Location $Location -tags $Tags

# Validate template files
Test-AzResourceGroupDeployment -Location $Location -TemplateFile $templateFile -TemplateParameterFile $ParameterFile -ResourceGroupName $RGName

# Create new deployment stack
New-AzResourceGroupDeploymentStack -Name $StackName -Location $Location -TemplateFile $templateFile -TemplateParameterFile $ParameterFile -ActionOnUnmanage 'deleteResources' -DenySettingsMode None -ResourceGroupName $RGName 

# Update deployment stack
Set-AzResourceGroupDeploymentStack -Name $StackName -Location $Location -DenySettingsMode None -TemplateParameterFile $ParameterFile -ActionOnUnmanage 'deleteResources' -ResourceGroupName $RGName 

# Delete deployment stack
Remove-AzResourceGroupDeploymentStack -Name $StackName -ResourceGroupName $RGName