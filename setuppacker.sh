#!/bin/bash

echo
echo
echo 'Download the packer Linux binary'
echo
echo 'wget https://releases.hashicorp.com/packer/1.3.1/packer_1.3.1_linux_amd64.zip'
read -n1 -r -p 'Press any key...' key

wget https://releases.hashicorp.com/packer/1.3.1/packer_1.3.1_linux_amd64.zip

echo
echo
echo 'Unzip the packer Linux download'
echo
echo 'unzip packer_1.3.1_linux_amd64.zip'
read -n1 -r -p 'Press any key...' key

unzip packer_1.3.1_linux_amd64.zip