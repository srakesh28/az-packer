# Azure Virtual Machine Deployment with Packer

## Deployment Quickstart

git clone and update

```bash
git clone https://github.com/bot6/az-packer

git fetch --all

git reset --hard origin/master
```

Allowing the deployment scripts to execute

```bash
cd az-vm

chmod +x setuppacker.sh

chmod +x setuprbac.sh

chmod +x setuppackervm.sh

chmod +x cleanup.sh
```

Running the deployment

```bash
./setuppacker.sh

./setuprbac.sh

./setuppackervm.sh
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

## Set script variables

Define the deployment variables used by the subsequent Azure CLI commands

```bash
image_resource_group=vmpacker-us-east
resource_group=vmp-us-east
vnet_name=vnet-us-east
location=eastus
vm_name=vmp-01
managed_image_name=vmp-ubuntu
subscription_id=$(az account show --query "{ subscription_id: id }" --output tsv)
```

## Setup packer


Download the packer Linux binary

```bash
wget https://releases.hashicorp.com/packer/1.3.1/packer_1.3.1_linux_amd64.zip
```

Unzip the packer Linux download

```bash
unzip packer_1.3.1_linux_amd64.zip
```

## Setup RBAC for packer

Create a service principal with az ad sp create-for-rbac and output the credentials that Packer needs

```bash
az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
```

Define the following script parameters based on the command output

```bash
client_id=00000000-0000-0000-0000-000000000000
client_secret=10000000-0000-0000-0000-000000000000
Tenant_id=20000000-0000-0000-0000-000000000000
```

## Setup the base packer virtual machine image

Create a resource group

```bash
az group create --name $image_resource_group --location $location
```

Create a packer JSON configuration file (packer-ubuntu.json)

```bash
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
```

Create the packer image from the JSON file

```bash
./packer build packer-ubuntu.json
```

## Deploy a virtual machine from the packer image

Deploy a virtual machine from the packer image

```bash
az vm create \
    --resource-group $image_resource_group \
    --name $vm_name \
    --image $managed_image_name \
    --generate-ssh-keys
```

Open port 80 to the virtual machine

```bash
az vm open-port \
    --resource-group $image_resource_group \
    --name $vm_name \
    --port 80
```

## Remove the Resource Group

```bash
az group delete -n $resource_group
```