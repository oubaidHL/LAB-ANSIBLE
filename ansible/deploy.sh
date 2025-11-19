#!/bin/bash

# Ansible Lab - Deployment Script
# This script helps deploy and verify the Ansible lab environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "========================================"
echo "   Ansible Lab - Deployment Helper"
echo "========================================"
echo ""

# Check if we're in the ansible directory
if [ ! -f /ansible/ansible.cfg ]; then
    echo -e "${RED}❌ Error: Please run this from /ansible directory in the master container.${NC}"
    exit 1
fi

# Check if SSH key exists
if [ ! -f /ansible/secrets/keys/id_rsa ]; then
    echo -e "${RED}❌ Error: SSH key not found. Please run push_key.sh first.${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Available deployment options:${NC}"
echo "  1) complete    - Deploy all services (DNS, DNS clients, Web)"
echo "  2) dns         - Deploy DNS servers + DNS client configuration"
echo "  3) web         - Deploy web servers only"
echo "  4) nagios      - Deploy Nagios monitoring only"
echo "  5) dns-client  - Configure DNS clients only (common role)"
echo "  6) site        - Run full site.yml playbook"
echo ""
echo -e "${BLUE}🌍 Available environments:${NC}"
echo "  - dev   (nodes 1-4:  node1, node2=web | node3=dns | node4=nagios)"
echo "  - test  (nodes 5-7:  node5=web | node6=dns | node7=nagios)"
echo "  - prod  (nodes 8-11: node8, node9=web | node10=dns | node11=nagios)"
echo "  - all   (all nodes)"
echo ""

# Menu selection
read -p "Enter deployment option [1-6] or 'q' to quit: " choice

PLAYBOOKS=()
DEPLOY_TYPE=""
case $choice in
    1) 
        PLAYBOOKS=("playbooks/dns.yml" "playbooks/dns-client.yml" "playbooks/web.yml")
        DEPLOY_TYPE="complete"
        ;;
    2) 
        PLAYBOOKS=("playbooks/dns.yml" "playbooks/dns-client.yml")
        DEPLOY_TYPE="dns"
        ;;
    3) 
        PLAYBOOKS=("playbooks/web.yml")
        DEPLOY_TYPE="web"
        ;;
    4) 
        PLAYBOOKS=("playbooks/nagios.yml")
        DEPLOY_TYPE="nagios"
        ;;
    5) 
        PLAYBOOKS=("playbooks/dns-client.yml")
        DEPLOY_TYPE="dns-client"
        ;;
    6) 
        PLAYBOOKS=("playbooks/site.yml")
        DEPLOY_TYPE="site"
        ;;
    q|Q)
        echo -e "${YELLOW}👋 Exiting...${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}❌ Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
read -p "Deploy to specific environment? [dev/test/prod/all]: " env_choice

LIMIT_FLAG=""
case $env_choice in
    dev|test|prod) 
        LIMIT_FLAG="--limit $env_choice"
        ENVIRONMENT="$env_choice"
        ;;
    all|"") 
        LIMIT_FLAG=""
        ENVIRONMENT="all"
        ;;
    *)
        echo -e "${YELLOW}⚠️  Invalid environment. Using 'all' by default.${NC}"
        LIMIT_FLAG=""
        ENVIRONMENT="all"
        ;;
esac

echo ""
echo -e "${GREEN}🚀 Starting deployment: $DEPLOY_TYPE to $ENVIRONMENT environment${NC}"
echo ""

# Run the playbooks
for PLAYBOOK in "${PLAYBOOKS[@]}"; do
    echo -e "${BLUE}▶️  Running $PLAYBOOK...${NC}"
    if ansible-playbook $PLAYBOOK $LIMIT_FLAG; then
        echo -e "${GREEN}✅ $PLAYBOOK completed successfully${NC}"
    else
        echo -e "${RED}❌ $PLAYBOOK failed${NC}"
        exit 1
    fi
    echo ""
done

echo ""
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo ""

# Verification section
echo -e "${BLUE}🔍 Running verification checks...${NC}"
echo ""

# Function to run verification command
verify_command() {
    local desc=$1
    local cmd=$2
    echo -e "${YELLOW}Checking: $desc${NC}"
    if eval $cmd > /dev/null 2>&1; then
        echo -e "${GREEN}  ✓ Pass${NC}"
        return 0
    else
        echo -e "${RED}  ✗ Fail${NC}"
        return 1
    fi
}

# Basic connectivity
echo -e "${BLUE}━━━ Connectivity Tests ━━━${NC}"
verify_command "All nodes reachable" "ansible all $LIMIT_FLAG -m ping -o"

# DNS verification
if [[ "$DEPLOY_TYPE" == "complete" || "$DEPLOY_TYPE" == "dns" || "$DEPLOY_TYPE" == "site" ]]; then
    echo ""
    echo -e "${BLUE}━━━ DNS Service Tests ━━━${NC}"
    
    if [[ "$ENVIRONMENT" == "all" || "$ENVIRONMENT" == "dev" ]]; then
        verify_command "DNS service running on node3 (dev)" "ansible node3 -m shell -a 'systemctl is-active named' -o"
        verify_command "DNS zone file exists (dev)" "ansible node3 -m stat -a 'path=/etc/bind/db.iticparis.dev' -o"
        verify_command "DNS resolution test (dev)" "ansible node3 -m shell -a 'nslookup node1.iticparis.dev 127.0.0.1' -o"
    fi
    
    if [[ "$ENVIRONMENT" == "all" || "$ENVIRONMENT" == "test" ]]; then
        verify_command "DNS service running on node6 (test)" "ansible node6 -m shell -a 'systemctl is-active named' -o"
        verify_command "DNS zone file exists (test)" "ansible node6 -m stat -a 'path=/etc/bind/db.iticparis.test' -o"
        verify_command "DNS resolution test (test)" "ansible node6 -m shell -a 'nslookup node5.iticparis.test 127.0.0.1' -o"
    fi
    
    if [[ "$ENVIRONMENT" == "all" || "$ENVIRONMENT" == "prod" ]]; then
        verify_command "DNS service running on node10 (prod)" "ansible node10 -m shell -a 'systemctl is-active named' -o"
        verify_command "DNS zone file exists (prod)" "ansible node10 -m stat -a 'path=/etc/bind/db.iticparis.prod' -o"
        verify_command "DNS resolution test (prod)" "ansible node10 -m shell -a 'nslookup node8.iticparis.prod 127.0.0.1' -o"
    fi
fi

# DNS Client verification
if [[ "$DEPLOY_TYPE" == "complete" || "$DEPLOY_TYPE" == "dns" || "$DEPLOY_TYPE" == "dns-client" || "$DEPLOY_TYPE" == "site" ]]; then
    echo ""
    echo -e "${BLUE}━━━ DNS Client Configuration Tests ━━━${NC}"
    
    if [[ "$ENVIRONMENT" == "all" || "$ENVIRONMENT" == "dev" ]]; then
        verify_command "DNS client configured on node1 (dev)" "ansible node1 -m shell -a 'grep 172.20.0.13 /etc/resolv.conf' -o"
    fi
    
    if [[ "$ENVIRONMENT" == "all" || "$ENVIRONMENT" == "test" ]]; then
        verify_command "DNS client configured on node5 (test)" "ansible node5 -m shell -a 'grep 172.20.0.16 /etc/resolv.conf' -o"
    fi
    
    if [[ "$ENVIRONMENT" == "all" || "$ENVIRONMENT" == "prod" ]]; then
        verify_command "DNS client configured on node8 (prod)" "ansible node8 -m shell -a 'grep 172.20.0.20 /etc/resolv.conf' -o"
    fi
fi

# Web server verification
if [[ "$DEPLOY_TYPE" == "complete" || "$DEPLOY_TYPE" == "web" || "$DEPLOY_TYPE" == "site" ]]; then
    echo ""
    echo -e "${BLUE}━━━ Web Service Tests ━━━${NC}"
    
    if [[ "$ENVIRONMENT" == "all" || "$ENVIRONMENT" == "dev" ]]; then
        verify_command "Nginx running on node1 (dev)" "ansible node1 -m shell -a 'systemctl is-active nginx' -o"
        verify_command "Nginx running on node2 (dev)" "ansible node2 -m shell -a 'systemctl is-active nginx' -o"
        verify_command "SSL certificate exists on node1" "ansible node1 -m stat -a 'path=/etc/nginx/ssl/nginx-selfsigned.crt' -o"
        verify_command "Web response from node1" "ansible node1 -m shell -a 'curl -k -s -o /dev/null -w \"%{http_code}\" https://localhost' -o"
    fi
    
    if [[ "$ENVIRONMENT" == "all" || "$ENVIRONMENT" == "test" ]]; then
        verify_command "Nginx running on node5 (test)" "ansible node5 -m shell -a 'systemctl is-active nginx' -o"
        verify_command "Web response from node5" "ansible node5 -m shell -a 'curl -k -s -o /dev/null -w \"%{http_code}\" https://localhost' -o"
    fi
    
    if [[ "$ENVIRONMENT" == "all" || "$ENVIRONMENT" == "prod" ]]; then
        verify_command "Nginx running on node8 (prod)" "ansible node8 -m shell -a 'systemctl is-active nginx' -o"
        verify_command "Nginx running on node9 (prod)" "ansible node9 -m shell -a 'systemctl is-active nginx' -o"
        verify_command "Web response from node8" "ansible node8 -m shell -a 'curl -k -s -o /dev/null -w \"%{http_code}\" https://localhost' -o"
    fi
    
    # End-to-end DNS + Web test
    echo ""
    echo -e "${BLUE}━━━ End-to-End DNS + Web Tests ━━━${NC}"
    
    if [[ "$ENVIRONMENT" == "all" || "$ENVIRONMENT" == "dev" ]]; then
        verify_command "DNS resolution + HTTPS on node1.iticparis.dev" "ansible node2 -m shell -a 'wget --no-check-certificate -q -O /dev/null https://node1.iticparis.dev' -o"
    fi
    
    if [[ "$ENVIRONMENT" == "all" || "$ENVIRONMENT" == "test" ]]; then
        verify_command "DNS resolution + HTTPS on node5.iticparis.test" "ansible node6 -m shell -a 'wget --no-check-certificate -q -O /dev/null https://node5.iticparis.test' -o"
    fi
    
    if [[ "$ENVIRONMENT" == "all" || "$ENVIRONMENT" == "prod" ]]; then
        verify_command "DNS resolution + HTTPS on node8.iticparis.prod" "ansible node9 -m shell -a 'wget --no-check-certificate -q -O /dev/null https://node8.iticparis.prod' -o"
    fi
fi

# Nagios verification
if [[ "$DEPLOY_TYPE" == "nagios" || "$DEPLOY_TYPE" == "site" ]]; then
    echo ""
    echo -e "${BLUE}━━━ Nagios Service Tests ━━━${NC}"
    
    if [[ "$ENVIRONMENT" == "all" || "$ENVIRONMENT" == "dev" ]]; then
        verify_command "Nagios running on node4 (dev)" "ansible node4 -m shell -a 'systemctl is-active nagios4' -o" || true
    fi
    
    if [[ "$ENVIRONMENT" == "all" || "$ENVIRONMENT" == "test" ]]; then
        verify_command "Nagios running on node7 (test)" "ansible node7 -m shell -a 'systemctl is-active nagios4' -o" || true
    fi
    
    if [[ "$ENVIRONMENT" == "all" || "$ENVIRONMENT" == "prod" ]]; then
        verify_command "Nagios running on node11 (prod)" "ansible node11 -m shell -a 'systemctl is-active nagios4' -o" || true
    fi
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Verification completed!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📊 Useful verification commands:${NC}"
echo "  # Connectivity"
echo "    ansible all -m ping"
echo ""
echo "  # DNS Services"
echo "    ansible dev_dns -m shell -a 'systemctl status named'"
echo "    ansible node1 -m shell -a 'nslookup node2.iticparis.dev'"
echo ""
echo "  # Web Services"
echo "    ansible dev_web -m shell -a 'systemctl status nginx'"
echo "    ansible node1 -m shell -a 'curl -k https://localhost'"
echo "    wget --no-check-certificate https://node1.iticparis.dev -O -"
echo ""
echo "  # Check resolv.conf"
echo "    ansible all -m shell -a 'cat /etc/resolv.conf'"
echo ""
echo -e "${BLUE}🌐 Access web servers from master:${NC}"
echo "    wget --no-check-certificate https://node1.iticparis.dev -O -"
echo "    wget --no-check-certificate https://node5.iticparis.test -O -"
echo "    wget --no-check-certificate https://node8.iticparis.prod -O -"
echo ""
echo -e "${BLUE}🌐 Access from Windows (port forwarding):${NC}"
echo "    https://localhost:8443 (node1)"
echo ""
