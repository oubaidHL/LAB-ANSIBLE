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

PUBKEY=$(cat /ansible/secrets/keys/id_rsa.pub)

echo ""
echo "📤 Deploying public key to all nodes..."
echo ""

for i in {1..11}; do
  echo "  → node$i ..."
  docker exec node$i bash -c "echo '$PUBKEY' >> /home/ansible/.ssh/authorized_keys"
  docker exec node$i bash -c "chmod 600 /home/ansible/.ssh/authorized_keys"
  docker exec node$i bash -c "chown ansible:ansible /home/ansible/.ssh/authorized_keys"
done

echo ""
echo "✔ Keys deployed to all 11 nodes"
echo ""
echo "📝 SSH key locations:"
echo "  Private: /ansible/secrets/keys/id_rsa"
echo "  Public:  /ansible/secrets/keys/id_rsa.pub"
echo ""
