#!/bin/bash

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

echo
echo
echo 'Define the deployment variables used by the subsequent Azure CLI commands'
echo
echo "image_resource_group=$image_resource_group"
echo "vnet_name=$vnet_name"
echo "location=$location"
echo "vm_name=$vm_name"
echo "pip_name=$pip_name"
echo "nsg_name=$nsg_name"
echo "managed_image_name=$managed_image_name"
echo "client_id=00000000-0000-0000-0000-000000000000"
echo "client_secret=10000000-0000-0000-0000-000000000000"
echo "Tenant_id=20000000-0000-0000-0000-000000000000"
echo "subscription_id=$(az account show --query "{ subscription_id: id }" --output tsv)"
read -n1 -r -p 'Press any key...' key

echo
echo
echo 'Create a resource group'
echo
echo 'az group create --name $image_resource_group --location $location'
read -n1 -r -p 'Press any key...' key

az group create --name $image_resource_group --location $location

#Create a file named ubuntu.json and paste the following content

echo
echo
echo 'Create a packer JSON configuration file (packer-ubuntu.json)'
read -n1 -r -p 'Press any key...' key

cat <<EOF >packer-ubuntu.json
{
  "builders": [{
    "type": "azure-arm",

    "client_id": "$client_id",
    "client_secret": "$client_secret",
    "tenant_id": "$Tenant_id",
    "subscription_id": "$subscription_id",

    "managed_image_resource_group_name": "$image_resource_group",
    "managed_image_name": "$managed_image_name",

    "os_type": "Linux",
    "image_publisher": "Canonical",
    "image_offer": "UbuntuServer",
    "image_sku": "16.04-LTS",

    "azure_tags": {
        "dept": "Engineering",
        "task": "Image deployment"
    },

    "location": "$location",
    "vm_size": "Standard_DS2_v2"
  }],
  "provisioners": [{
    "execute_command": "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'",
    "inline": [
      "apt-get update",
      "apt-get upgrade -y",
      "apt-get -y install nginx",

      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
    ],
    "inline_shebang": "/bin/sh -x",
    "type": "shell"
  }]
}
EOF

echo
echo
echo 'Create the packer image'
echo
echo './packer build packer-ubuntu.json'
read -n1 -r -p 'Press any key...' key

./packer build packer-ubuntu.json

echo
echo
echo 'Deploy a virtual machine from the packer image'
echo
echo 'az vm create \'
echo '    --resource-group $image_resource_group \'
echo '    --name $vm_name \'
echo '    --image $managed_image_name \'
echo '    --generate-ssh-keys'
read -n1 -r -p 'Press any key...' key

az vm create \
    --resource-group $image_resource_group \
    --name $vm_name \
    --image $managed_image_name \
    --generate-ssh-keys

echo
echo
echo 'Open port 80 to the virtual machine'
echo
echo 'az vm open-port \'
echo '    --resource-group $image_resource_group \'
echo '    --name $vm_name \'
echo '    --port 80'
read -n1 -r -p 'Press any key...' key

az vm open-port \
    --resource-group $image_resource_group \
    --name $vm_name \
    --port 80