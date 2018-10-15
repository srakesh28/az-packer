#!/bin/bash

resource_group=vm-us-west2
vnet_name=vnet-us-west2
location=westus2
vm_name=vm-01
pip_name=vm-01-pip
nsg_name=vm-01-nsg

echo
echo
echo 'Define the deployment variables used by the subsequent Azure CLI commands'
echo
echo "resource_group=$resource_group"
echo "vnet_name=$vnet_name"
echo "location=$location"
echo "vm_name=$vm_name"
echo "pip_name=$pip_name"
echo "nsg_name=$nsg_name"
read -n1 -r -p 'Press any key...' key

echo
echo
echo 'Create a resource group'
echo
echo 'az group create --name $resource_group --location $location'
read -n1 -r -p 'Press any key...' key

az group create --name $resource_group --location $location

echo
echo
echo 'Create a virtual network'
echo
echo 'az network vnet create --resource-group $resource_group --name $vnet_name --subnet-name ServerSubnet'
read -n1 -r -p 'Press any key...' key

az network vnet create --resource-group $resource_group --name $vnet_name --subnet-name ServerSubnet

echo
echo
echo 'Create a public IP address'
echo
echo 'az network public-ip create --resource-group $resource_group --name $pip_name'
read -n1 -r -p 'Press any key...' key

az network public-ip create --resource-group $resource_group --name $pip_name

echo
echo
echo 'Create a network security group'
echo
echo 'az network nsg create --resource-group $resource_group --name $nsg_name'
read -n1 -r -p 'Press any key...' key

az network nsg create --resource-group $resource_group --name $nsg_name

echo
echo
echo 'Create a virtual network card and associate with public IP address and NSG'
echo
echo 'az network nic create \'
echo '  --resource-group $resource_group \'
echo '  --name $vm_name-nic1 \'
echo '  --vnet-name $vnet_name \'
echo '  --subnet ServerSubnet \'
echo '  --network-security-group $nsg_name \'
echo '  --public-ip-address $pip_name'
read -n1 -r -p 'Press any key...' key

az network nic create \
  --resource-group $resource_group \
  --name $vm_name-nic1 \
  --vnet-name $vnet_name \
  --subnet ServerSubnet \
  --network-security-group $nsg_name \
  --public-ip-address $pip_name


echo
echo
echo 'Create a new virtual machine, this creates SSH keys if not present'
echo
echo 'az vm create \'
echo '  -resource-group $resource_group \'
echo '  --name $vm_name \'
echo '  --nics $vm_name-nic1 \'
echo '  --os-disk-name $vm_name-boot.vhd \'
echo '  --image CentOS \'
echo '  --generate-ssh-keys'
read -n1 -r -p 'Press any key...' key

az vm create \
  --resource-group $resource_group \
  --name $vm_name \
  --nics $vm_name-nic1 \
  --os-disk-name $vm_name-boot.vhd \
  --image CentOS \
  --generate-ssh-keys

echo
echo
echo 'Open port 22 to allow SSH traffic to host'
echo
echo 'az vm open-port --port 22 --resource-group $resource_group --name $vm_name'
read -n1 -r -p 'Press any key...' key

az vm open-port --port 22 --resource-group $resource_group --name $vm_name

echo
echo
echo 'Use an Azure Virtual Machine Custom Script Extension to install httpd'
echo
echo 'az vm extension set \'
echo '  --publisher Microsoft.Azure.Extensions \'
echo '  --version 2.0 \'
echo '  --name CustomScript \'
echo '  --vm-name $vm_name \'
echo '  --resource-group $resource_group \'
echo '  --settings '{"commandToExecute":"yum -y install httpd && systemctl start httpd && systemctl enable httpd"}''
read -n1 -r -p 'Press any key...' key

az vm extension set \
  --publisher Microsoft.Azure.Extensions \
  --version 2.0 \
  --name CustomScript \
  --vm-name $vm_name \
  --resource-group $resource_group \
  --settings '{"commandToExecute":"yum -y install httpd && systemctl start httpd && systemctl enable httpd"}'

echo
echo
echo 'Use an Azure Virtual Machine Custom Script Extension to update the host firewall'
echo
echo 'az vm extension set \'
echo '  --publisher Microsoft.Azure.Extensions \'
echo '  --version 2.0 \'
echo '  --name CustomScript \'
echo '  --vm-name $vm_name \'
echo '  --resource-group $resource_group \'
echo '  --settings '{"commandToExecute":"firewall-cmd --zone=public --add-port=80/tcp --permanent && firewall-cmd --reload"}''
read -n1 -r -p 'Press any key...' key

az vm extension set \
  --publisher Microsoft.Azure.Extensions \
  --version 2.0 \
  --name CustomScript \
  --vm-name $vm_name \
  --resource-group $resource_group \
  --settings '{"commandToExecute":"firewall-cmd --zone=public --add-port=80/tcp --permanent && firewall-cmd --reload"}'

echo
echo
echo 'Open port 80 to allow http traffic to host'
echo
echo 'az vm open-port --port 80 --resource-group $resource_group --name $vm_name --priority 901'
read -n1 -r -p 'Press any key...' key

az vm open-port --port 80 --resource-group $resource_group --name $vm_name --priority 901

echo
echo
echo 'Show the resources in the Resource Group'
echo
echo 'az resource list --resource-group $resource_group'
read -n1 -r -p 'Press any key...' key

az resource list --resource-group $resource_group

echo
echo
echo 'Get the public IP address'
echo
echo 'az network public-ip show --name $pip_name --resource-group $resource_group --query ipAddress --output tsv'
read -n1 -r -p 'Press any key...' key

az network public-ip show --name $pip_name --resource-group $resource_group --query ipAddress --output tsv

ip="$(az network public-ip show --name $pip_name --resource-group $resource_group --query ipAddress --output tsv)"

echo 
echo
echo "Browse to the public IP"
echo
echo "http://$ip/"
read -n1 -r -p 'Press any key...' key

echo
echo
echo "SSH to the public IP"
echo
echo "ssh $ip"
echo "ssh <user>@$ip"
read -n1 -r -p 'Press any key...' key