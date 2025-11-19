#!/bin/bash

# Generate SSH key if it doesn't exist
if [ ! -f /ansible/secrets/keys/id_rsa ]; then
  echo "🔑 Generating SSH key pair..."
  mkdir -p /ansible/secrets/keys
  ssh-keygen -t rsa -b 4096 -f /ansible/secrets/keys/id_rsa -N "" -C "ansible@lab"
  echo "✔ SSH key pair generated"
else
  echo "✔ SSH key pair already exists"
fi

echo ""
echo "📤 Deploying public key to all nodes..."
echo ""

# Define node IPs
declare -A NODES=(
  [1]="172.20.0.11"
  [2]="172.20.0.12"
  [3]="172.20.0.13"
  [4]="172.20.0.14"
  [5]="172.20.0.15"
  [6]="172.20.0.16"
  [7]="172.20.0.17"
  [8]="172.20.0.18"
  [9]="172.20.0.19"
  [10]="172.20.0.20"
  [11]="172.20.0.21"
)

for i in {1..11}; do
  NODE_IP=${NODES[$i]}
  echo "  → node$i ($NODE_IP) ..."
  
  # Use ssh-copy-id or sshpass to copy the key
  sshpass -p "ansible" ssh-copy-id -o StrictHostKeyChecking=no -i /ansible/secrets/keys/id_rsa.pub ansible@$NODE_IP 2>/dev/null
  
  if [ $? -eq 0 ]; then
    echo "    ✔ Key deployed successfully"
  else
    echo "    ✘ Failed to deploy key"
  fi
done

echo ""
echo "✔ Keys deployment completed"
echo ""
echo "📝 SSH key locations:"
echo "  Private: /ansible/secrets/keys/id_rsa"
echo "  Public:  /ansible/secrets/keys/id_rsa.pub"
echo ""
echo "🧪 Testing SSH connection to node1..."
ssh -o StrictHostKeyChecking=no -i /ansible/secrets/keys/id_rsa ansible@172.20.0.11 "echo 'SSH connection successful!'" 2>/dev/null
echo ""
