#!/bin/bash

echo
echo
echo 'Create a service principal with az ad sp create-for-rbac and output the credentials that Packer needs'
echo
echo 'az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"'
read -n1 -r -p 'Press any key...' key

az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"