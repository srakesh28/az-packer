# Azure Virtual Machine Deployment

## Deployment Quickstart

git clone and update

```bash
git clone https://github.com/bot6/az-vm

git fetch --all

git reset --hard origin/master
```

Allowing the deployment scripts to execute

```bash
cd az-vm

chmod +x setupvm.sh

chmod +x setupvmimage.sh

chmod +x setupvmsize.sh

chmod +x cleanup.sh
```

Running the deployment

```bash
./setupvm.sh

./setupvmimage.sh

./setupvmsize.sh
```

Delete the Azure deployment and git repo

```bash
./cleanup.sh

cd ..

rm -rf az-vm
```

## Deploying a CentOS Virtual Machine and Install httpd

Define the deployment variables used by the subsequent Azure CLI commands

```bash
resource_group=vm-us-west2
vnet_name=vnet-us-west2
location=westus2
vm_name=vm-01
pip_name=vm-01-pip
nsg_name=vm-01-nsg
```

Create a resource group

```bash
az group create --name $resource_group --location $location
```

Create a virtual network

```bash
az network vnet create --resource-group $resource_group --name $vnet_name --subnet-name ServerSubnet
```

Create a public IP address

```bash
az network public-ip create --resource-group $resource_group --name $pip_name
```

Create a network security group

```bash
az network nsg create --resource-group $resource_group --name $nsg_name
```

Create a virtual network card and associate with public IP address and NSG

```bash
az network nic create \
  --resource-group $resource_group \
  --name $vm_name-nic1 \
  --vnet-name $vnet_name \
  --subnet ServerSubnet \
  --network-security-group $nsg_name \
  --public-ip-address $pip_name
```

Create a new virtual machine, this creates SSH keys if not present

```bash
az vm create \
  -resource-group $resource_group \
  --name $vm_name \
  --nics $vm_name-nic1 \
  --os-disk-name $vm_name-boot.vhd \
  --image CentOS \
  --generate-ssh-keys
```

Open port 22 to allow SSH traffic to host

```bash
az vm open-port --port 22 --resource-group $resource_group --name $vm_name
```

Use an Azure Virtual Machine Custom Script Extension to install httpd

```bash
az vm extension set \
  --publisher Microsoft.Azure.Extensions \
  --version 2.0 \
  --name CustomScript \
  --vm-name $vm_name \
  --resource-group $resource_group \
  --settings '{"commandToExecute":"yum -y install httpd && systemctl start httpd && systemctl enable httpd"}'
```

Use an Azure Virtual Machine Custom Script Extension to update the host firewall

```bash
az vm extension set \
  --publisher Microsoft.Azure.Extensions \
  --version 2.0 \
  --name CustomScript \
  --vm-name $vm_name \
  --resource-group $resource_group \
  --settings '{"commandToExecute":"firewall-cmd --zone=public --add-port=80/tcp --permanent && firewall-cmd --reload"}'
```

Open port 80 to allow http traffic to host

```bash
az vm open-port --port 80 --resource-group $resource_group --name $vm_name --priority 901
```

Show the resources in the Resource Group

```bash
az resource list --resource-group $resource_group
```

## Identifying Azure Virtual Machine Images

Define the deployment variables used by the subsequent Azure CLI commands'

```bash
resource_group=vm-us-west2
location=westus2
vm_name=vm-01
```

Show all virtual machine images

```bash
az vm image list
```

Show all publishers

```bash
az vm image list-publishers -l $location --query "[?starts_with(name, 'Open')]"
```

Show all offers from OpenLogic

```bash
az vm image list-offers --location $location -p OpenLogic
```

Show all skus from OpenLogic based on CentOS'

```bash
az vm image list-skus --location $location -p OpenLogic -f CentOS
```

Show all virtual machine sizes available in a region

```bash
az vm list-sizes --location $location
```

Create a virtual machine with a specific sku

```bash
az group create --name $resource_group --location $location

az network nsg create --resource-group $resource_group --name $nsg_name

az network nic create \
  --resource-group $resource_group \
  --name $vm_name-nic1 \
  --vnet-name $vnet_name \
  --subnet ServerSubnet \
  --network-security-group $nsg_name \
  --public-ip-address ""
  
az vm create \
  --resource-group $resource_group \
  --name $vm_name \
  --nics $vm_name-nic1 \
  --os-disk-name $vm_name-boot.vhd \
  --image CentOS \
  --generate-ssh-keys
```

## Resize the Virtual Machine

Define the deployment variables used by the subsequent Azure CLI commands

```bash
resource_group=vm-us-west2
vnet_name=vnet-us-west2
location=westus2
vm_name=vm-01
```

Show the current virtual machine size

```bash
az vm show --resource-group $resource_group --name $vm_name --query hardwareProfile.vmSize
```

Show the available sizes for the running virtual machine

```bash
az vm list-vm-resize-options --resource-group $resource_group --name $vm_name --query [].name
```

Resize the running virtual machine

```bash
az vm resize --resource-group $resource_group --name $vm_name --size Standard_DS2_v2
```

Deallocate the virtual machine

```bash
az vm deallocate --resource-group $resource_group --name $vm_name
```

Get the power state of the virtual machine

```bash
az vm get-instance-view --name $vm_name --resource-group $resource_group --query instanceView.statuses[1]
```

Show the available sizes for the deallocated virtual machine (All sizes for the region are now available)

```bash
az vm list-vm-resize-options --resource-group $resource_group --name $vm_name --query [].name
```

Resize the deallocated virtual machine

```bash
az vm resize --resource-group $resource_group --name $vm_name --size Standard_GS1
```

Start the virtual machine

```bash
az vm start --resource-group $resource_group --name $vm_name
```

Get the power state of the virtual machine

```bash
az vm get-instance-view --name $vm_name --resource-group $resource_group --query instanceView.statuses[1]
```

Show the NEW available sizes for the running virtual machine

```bash
az vm list-vm-resize-options --resource-group $resource_group --name $vm_name --query [].name
```

## Remove the Resource Group

```bash
az group delete -n $resource_group
```