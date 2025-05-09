#!/bin/bash

# Variables
RESOURCE_GROUP="rg-aoai-kc-aipg-dev"
LOCATION="koreacentral"
VM_NAME="axpg-n8n"
ADMIN_USERNAME="n8nadmin"
DNS_PREFIX="n8n-$(date +%s | cut -c6-10)"

# Create resource group
# az group create --name $RESOURCE_GROUP --location $LOCATION

# Generate SSH key if it doesn't exist
if [ ! -f ~/.ssh/id_rsa_n8n ]; then
    ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa_n8n
fi

if az vm show -g $RESOURCE_GROUP -n $VM_NAME &> /dev/null; then
  echo "VM already exists. Deleting..."
  az vm delete -g $RESOURCE_GROUP -n $VM_NAME --yes
  echo "Deleting associated resources..."
  az network nic delete -g $RESOURCE_GROUP -n ${VM_NAME}-nic
  az network public-ip delete -g $RESOURCE_GROUP -n ${VM_NAME}-ip
  az network nsg delete -g $RESOURCE_GROUP -n ${VM_NAME}-nsg
fi

# Deploy the VM
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file n8n-vm-template.json \
  --parameters \
    vmName=$VM_NAME \
    adminUsername=$ADMIN_USERNAME \
    adminPasswordOrKey="$(cat ~/.ssh/id_rsa_n8n.pub)" \
    dnsLabelPrefix=$DNS_PREFIX 

# Get the VM's public IP
VM_IP=$(az vm show -d -g $RESOURCE_GROUP -n $VM_NAME --query publicIps -o tsv)

# Output connection information
echo "VM deployed successfully!"
echo "SSH connection: ssh -i ~/.ssh/id_rsa_n8n $ADMIN_USERNAME@$VM_IP"
echo "DNS name: $DNS_PREFIX.$LOCATION.cloudapp.azure.com" 