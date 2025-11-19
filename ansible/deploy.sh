#!/bin/bash

# Ansible Lab - Deployment Script
# This script helps deploy the full Ansible lab environment

set -e

echo "========================================"
echo "   Ansible Lab - Deployment Helper"
echo "========================================"
echo ""

# Check if we're in the ansible directory
if [ ! -f /ansible/ansible.cfg ]; then
    echo "❌ Error: Please run this from /ansible directory in the master container."
    exit 1
fi

# Check if SSH key exists
if [ ! -f /ansible/secrets/keys/id_rsa ]; then
    echo "❌ Error: SSH key not found. Please run push_key.sh first."
    exit 1
fi

echo "📋 Available playbooks:"
echo "  1) site.yml     - Deploy all roles to all environments"
echo "  2) web.yml      - Deploy web servers only"
echo "  3) dns.yml      - Deploy DNS servers only"
echo "  4) nagios.yml   - Deploy Nagios monitoring only"
echo ""
echo "🌍 Available environments:"
echo "  - dev   (nodes 1-4)"
echo "  - test  (nodes 5-7)"
echo "  - prod  (nodes 8-11)"
echo "  - all   (all nodes)"
echo ""

# Menu selection
read -p "Enter playbook number [1-4] or 'q' to quit: " choice

PLAYBOOK=""
case $choice in
    1) PLAYBOOK="playbooks/site.yml" ;;
    2) PLAYBOOK="playbooks/web.yml" ;;
    3) PLAYBOOK="playbooks/dns.yml" ;;
    4) PLAYBOOK="playbooks/nagios.yml" ;;
    q|Q)
        echo "👋 Exiting..."
        exit 0
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
read -p "Deploy to specific environment? [dev/test/prod/all]: " env_choice

LIMIT_FLAG=""
case $env_choice in
    dev|test|prod) LIMIT_FLAG="--limit $env_choice" ;;
    all|"") LIMIT_FLAG="" ;;
    *)
        echo "❌ Invalid environment. Using 'all' by default."
        LIMIT_FLAG=""
        ;;
esac

echo ""
echo "🚀 Deploying $PLAYBOOK $LIMIT_FLAG"
echo ""

# Run the playbook
ansible-playbook $PLAYBOOK $LIMIT_FLAG

echo ""
echo "✅ Deployment completed!"
echo ""
echo "📊 Quick verification commands:"
echo "  ansible all -m ping"
echo "  ansible '*_web' -m shell -a 'systemctl status nginx'"
echo "  ansible '*_dns' -m shell -a 'systemctl status bind9'"
echo "  ansible '*_nagios' -m shell -a 'systemctl status nagios4'"
echo ""
echo "🌐 Test web servers:"
echo "  curl -k https://node1"
echo "  curl -k https://node5"
echo "  curl -k https://node8"
echo ""
