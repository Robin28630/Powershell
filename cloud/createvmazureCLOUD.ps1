#chemin cloud perso azure 
$vds = Import-Csv -Path "/home/robin/computes.csv" -Delimiter ";"
foreach ($vd in $vds){
$User = "administrateur"
$File = "C:\Users\MONTIGR1\Desktop\cloud\Password.txt"
$MyCredential = New-Object -TypeName System.Management.Automation.PSCredential `
 -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString)
#paramètres machine
#$vmAdminUsername = "administrateur"
#$$vmAdminPassword = Get-Content "C:\Users\MONTIGR1\Desktop\cloud\Password.txt" | ConvertTo-SecureString
#$vmAdminPassword = ConvertTo-SecureString "Admintyche01" -AsPlainText -Force
$vmComputerName = $vd.name
$azureLocation  = "francecentral"
$azureResourceGroup = "GROUPE_PROD_TYCHE"
$azureVmName = $vd.name
$azureVmSize = "Standard_F16s_v2"
$tags = (Get-AzResource -ResourceGroupName $azureResourceGroup -Name "WPZZI063").Tags
#license Hybrid benefit
$azLicense = "Windows_Server"

#paramètres image OS
$azureVmPublisherName = "MicrosoftWindowsServer"
$azureVmOffer = "WindowsServer"
$azureVmSkus = "2016-datacenter-gensecond"

#paramètres réseaux
$azureVnetName  = "VNET_TYCHE_PROD"
$azureVnetSubnetName = "SUBNET_TYCHE_PROD_SERVEURS"
$azureNicName = $vd.nic
$azureVnetSubnet = (Get-AzVirtualNetwork -Name $azureVnetName -ResourceGroupName $azureResourceGroup).Subnets | Where-Object {$_.Name -eq $azureVnetSubnetName}
$azureNIC = New-AzNetworkInterface -ResourceGroupName $azureResourceGroup -name $azureNicName -Location $azureLocation -SubnetId $azureVnetSubnet.Id

#configuration machine 
#$vmCredential = New-Object System.Management.Automation.PSCredential ($vmAdminUsername, $vmAdminPassword)
$vmCredential = $MyCredential
$VirtualMachine = New-AzVMConfig -VMName $azureVmName -VMSize $azureVmSize -Tags $tags
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $vmComputerName -Credential $vmCredential 
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $azureNIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName $azureVmPublisherName -Offer $azureVmOffer -Skus $azureVmSkus -Version "latest"
$VirtualMachine = Set-AzVMOSDisk -VM $VirtualMachine -StorageAccountType "Standard_LRS" -Caching ReadWrite -CreateOption FromImage
New-AzVM -ResourceGroupName $azureResourceGroup -Location $azureLocation -VM $VirtualMachine -LicenseType $azLicense -Verbose
}
