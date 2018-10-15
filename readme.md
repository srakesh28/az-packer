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

Configure the Azure CLI (set output to table)

```bash
az account list

az account set --subscription 00000000-0000-0000-0000-000000000000

az account show

az configure
```

Delete the Azure deployment and git repo

```bash
./cleanup.sh

cd ..

rm -rf az-vm
```

## Setup variables

Define the deployment variables used by the subsequent Azure CLI commands

```bash
image_resource_group=vmpacker-us-east
resource_group=vmp-us-east
vnet_name=vnet-us-east
location=eastus
vm_name=vmp-01
managed_image_name=vmp-ubuntu

client_id=00000000-0000-0000-0000-000000000000
client_secret=10000000-0000-0000-0000-000000000000
Tenant_id=20000000-0000-0000-0000-000000000000
subscription_id=$(az account show --query "{ subscription_id: id }" --output tsv)
```

## Setup RBAC for packer

## Setup the base packer virtual machine image

## Deploy a virtual machine from the packer image

## Remove the Resource Group

```bash
az group delete -n $resource_group
```