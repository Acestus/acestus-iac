# Update the template spec 
pwsh
cd ~/git/bicep-infra/create-windows-vm
set-azcontext -subscription "Management"
New-AzTemplateSpec -Name DeployWindowsVM -Version 25.02 -ResourceGroupName TemplateSpecs -Location westus2 -TemplateFile ./mainTemplate.bicep -DisplayName "Deploy Windows VM" -Description "Deploy a Windows VM" -Force

# Deploy the template spec
$TemplateSpecId = "/subscriptions/<subscription-id>/resourceGroups/TemplateSpecs/providers/Microsoft.Resources/templateSpecs/DeployWindowsVM/versions/25.01"
$params = @{
    instanceNumber = "004"
    "adminUsername" = "adminuser"
}
set-azcontext -subscription "Sbox-510-Infrastructure"
New-AzResourceGroupDeployment -TemplateSpecId $TemplateSpecId -ResourceGroupName DscTest -TemplateParameterObject $params

# Get the VM
Get-AzVMImageSku -Location westus2 -PublisherName MicrosoftWindowsServer -Offer WindowsServer

Get-AzVMSize -Location "westus2" | Where {$_.NumberOfCores -lt 4}


New-AzResourceGroup -Name DscTest -Location westus3
Remove-AzResourceGroup -Name DscTest

cd ~/git/iac/create-windows-vm
New-AzTemplateSpec -Name $Name -Version 24.12 -ResourceGroupName TemplateSpecs -Location westus2 -TemplateFile ./mainTemplate.bicep -Force

$Name = "DeployWindowsVM"
$id = Get-AzTemplateSpec -ResourceGroupName TemplateSpecs -Name $Name | Select-Object -ExpandProperty Id
$id
$version = Get-AzTemplateSpec -ResourceGroupName TemplateSpecs -Name $Name | Select-Object -ExpandProperty Versions | Select-Object -ExpandProperty Name
$version
$TemplateSpecId = $id + "/versions/" + $version
$TemplateSpecId


New-AzResourceGroupDeployment -TemplateSpecId $TemplateSpecId -ResourceGroupName DscTest


