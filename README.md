# Ansible Lab Environment

A professional Ansible lab environment with 1 master node and 11 target nodes across 3 environments (dev, test, prod). Demonstrates enterprise-grade Ansible practices and organization.

## 🎯 What You'll Learn

✅ **Professional Project Structure** - Organized like production environments  
✅ **Multi-Environment Management** - Dev, Test, Prod separation  
✅ **Role-Based Design** - Modular, reusable components  
✅ **Variable Precedence** - Group vars, environment vars, host vars  
✅ **Security Best Practices** - SSH keys, Ansible Vault, SSL/TLS  
✅ **Advanced Ansible Features** - Handlers, listeners, conditionals, facts, registers  
✅ **Service Management** - Install, configure, monitor services  
✅ **Template Engine** - Dynamic Jinja2 templates  
✅ **Idempotency** - Safe to run multiple times  
✅ **Inventory Management** - Groups, children, dynamic targeting

## 🏗️ Architecture

### Infrastructure
- **1 Master Node** - Ansible control node with all tools
- **11 Target Nodes** - Managed nodes across 3 environments
  - **Dev**: nodes 1-4 (2 web, 1 dns, 1 nagios)
  - **Test**: nodes 5-7 (1 web, 1 dns, 1 nagios)
  - **Prod**: nodes 8-11 (2 web, 1 dns, 1 nagios)

### Services Deployed
- **Web Servers** - Nginx with SSL, environment-specific pages
- **DNS Servers** - Bind9 with domain configuration
- **Nagios Monitoring** - Monitoring with secure web interface

## 📁 Project Structure

```
lab-ansible/
├── docker-compose.yml                 # Container orchestration
├── master/Dockerfile                  # Ansible control node
├── node/Dockerfile                    # Target node template
└── ansible/                           # ⭐ Main Ansible directory
    ├── ansible.cfg                    # Ansible configuration
    ├── push_key.sh                    # SSH key deployment
    ├── deploy.sh                      # Interactive deployment helper
    ├── PROJECT_STRUCTURE.md           # Detailed structure guide
    │
    ├── inventories/                   # 📋 All inventory files
    │   ├── README.md
    │   ├── hosts.ini                  # Main inventory
    │   ├── group_vars/                # Group variables
    │   │   ├── all.yml               # Global variables
    │   │   ├── dev.yml               # Dev environment
    │   │   ├── test.yml              # Test environment
    │   │   ├── prod.yml              # Prod environment
    │   │   ├── web.yml               # Web servers
    │   │   ├── dns.yml               # DNS servers
    │   │   └── nagios.yml            # Nagios servers
    │   └── host_vars/                # Host-specific variables
    │
    ├── playbooks/                     # 🎭 All playbooks & roles
    │   ├── README.md
    │   ├── site.yml                   # Main playbook
    │   ├── web.yml                    # Web servers
    │   ├── dns.yml                    # DNS servers
    │   ├── nagios.yml                 # Nagios monitoring
    │   └── roles/                     # Ansible roles
    │       ├── web/                   # Nginx + SSL role
    │       ├── dns/                   # Bind9 role
    │       └── nagios/                # Nagios role
    │
    └── secrets/                       # 🔐 Sensitive data (git-ignored)
        ├── README.md
        ├── .gitignore
        ├── keys/                      # SSH keys
        │   ├── id_rsa                # Private key (generated)
        │   └── id_rsa.pub            # Public key (generated)
        └── vault/                     # Encrypted secrets
            └── credentials.yml.example
```

## 🚀 Quick Start

### 1. Start the Environment
```bash
docker-compose up -d
```

### 2. Deploy SSH Keys
Run this from your **host machine** (not inside any container):
```bash
# On Windows PowerShell
bash ansible/push_key.sh

# Or if bash is not available on Windows
docker exec master bash /ansible/push_key.sh
```

This script will:
- Generate SSH keys on the master node
- Copy the public key to all target nodes
- Enable passwordless SSH authentication

### 3. Enter Master Container
```bash
docker exec -it master bash
cd /ansible
```

### 4. Test Connectivity
```bash
ansible all -m ping
```

### 5. Deploy Services

#### Using Helper Script (Recommended)
```bash
bash deploy.sh
```
Provides interactive menu to select playbook and environment.

#### Manual Deployment
```bash
# Deploy everything to all environments
ansible-playbook playbooks/site.yml

# Deploy specific services
ansible-playbook playbooks/web.yml       # Web servers only
ansible-playbook playbooks/dns.yml       # DNS servers only
ansible-playbook playbooks/nagios.yml    # Monitoring only

# Deploy to specific environment
ansible-playbook playbooks/site.yml --limit dev
ansible-playbook playbooks/site.yml --limit prod
ansible-playbook playbooks/web.yml --limit test

# Deploy with tags
ansible-playbook playbooks/site.yml --tags packages
ansible-playbook playbooks/site.yml --skip-tags ssl
```

## 🔍 Verification & Testing

### Check All Nodes
```bash
ansible all -m ping
ansible all -m shell -a 'uptime'
```

### Check Service Status
```bash
# Web servers
ansible '*_web' -m shell -a 'systemctl status nginx'

# DNS servers
ansible '*_dns' -m shell -a 'systemctl status bind9'

# Nagios servers
ansible '*_nagios' -m shell -a 'systemctl status nagios4'
ansible '*_nagios' -m shell -a 'systemctl status nginx'
```

### Test Web Servers
```bash
# HTTP redirect to HTTPS
curl -L http://node1

# HTTPS (ignore self-signed cert)
curl -k https://node1
curl -k https://node5
curl -k https://node8

# Check SSL certificate
openssl s_client -connect node1:443 -showcerts

# Test all web servers
for i in 1 2 5 8 9; do echo "=== node$i ==="; curl -k https://node$i; done
```

### Test DNS Servers
```bash
# DNS resolution
docker exec node3 dig @localhost dev.local
docker exec node6 dig @localhost test.local

# DNS configuration check
docker exec node3 named-checkconf
docker exec node3 rndc status
```

### Access Nagios Web Interface
```
URL: https://<docker-host-ip>/nagios4/
Username: nagiosadmin
Password: nagiosadmin
```

## 📚 Advanced Usage

### Inventory Commands
```bash
# List all hosts
ansible all --list-hosts

# List specific group
ansible dev --list-hosts
ansible '*_web' --list-hosts

# Show inventory graph
ansible-inventory --graph

# Check variable for host
ansible node1 -m debug -a "var=env"
```

### Playbook Options
```bash
# Syntax check
ansible-playbook playbooks/site.yml --syntax-check

# Dry run (check mode)
ansible-playbook playbooks/site.yml --check

# Verbose output
ansible-playbook playbooks/site.yml -v
ansible-playbook playbooks/site.yml -vvv

# List tasks
ansible-playbook playbooks/site.yml --list-tasks

# List tags
ansible-playbook playbooks/site.yml --list-tags

# Step-by-step execution
ansible-playbook playbooks/site.yml --step
```

### Using Ansible Vault
```bash
# Create encrypted credentials
ansible-vault create secrets/vault/credentials.yml

# Edit vault file
ansible-vault edit secrets/vault/credentials.yml

# Run playbook with vault
ansible-playbook playbooks/site.yml --ask-vault-pass
```

### Ad-hoc Commands
```bash
# Gather facts
ansible node1 -m setup

# Check disk space
ansible all -m shell -a 'df -h'

# Check memory
ansible all -m shell -a 'free -m'

# Install package
ansible dev -m apt -a 'name=htop state=present'

# Copy file
ansible all -m copy -a 'src=/tmp/test.txt dest=/tmp/test.txt'
```

## 🌍 Environments

### Development (dev)
- **Nodes**: 1-4
- **Domain**: dev.local
- **Purpose**: Development and feature testing
- **Resources**: Minimal (2 workers, 512 connections)
- **Debug**: Enabled

### Test (test)
- **Nodes**: 5-7
- **Domain**: test.local
- **Purpose**: Pre-production testing
- **Resources**: Moderate (2 workers, 768 connections)
- **Debug**: Enabled

### Production (prod)
- **Nodes**: 8-11
- **Domain**: prod.local
- **Purpose**: Production environment simulation
- **Resources**: Full (4 workers, 1024 connections)
- **Debug**: Disabled

## 🔐 Security Features

- ✅ SSH key-based authentication
- ✅ Self-signed SSL certificates
- ✅ HTTPS with security headers
- ✅ Ansible Vault support
- ✅ Secrets directory (git-ignored)
- ✅ Proper file permissions
- ✅ Passwordless sudo
- ✅ HSTS and XSS protection headers

## 🎓 Learning Features

### Advanced Ansible Concepts Demonstrated

1. **Variable Precedence**
   - Global variables in `group_vars/all.yml`
   - Environment variables in `group_vars/{env}.yml`
   - Service variables in `group_vars/{service}.yml`
   - Host variables in `host_vars/{host}.yml`

2. **Handlers & Listeners**
   - Handler grouping with `listen` directive
   - Chained handler execution
   - Conditional handler triggering

3. **Built-in Variables & Facts**
   - System facts (OS, memory, CPU)
   - Network facts (IP, hostname, FQDN)
   - Date/time facts
   - Custom fact usage

4. **Conditionals & Loops**
   - `when` conditions
   - OS-specific tasks
   - Service state checking
   - File existence checks

5. **Register & Debug**
   - Capturing command output
   - Conditional execution based on results
   - Debug message formatting
   - Comprehensive logging

6. **Tags**
   - Selective task execution
   - Skip specific tasks
   - Group related tasks
   - Debug/summary tags

7. **Validation & Testing**
   - Configuration syntax checks
   - Service health checks
   - SSL certificate verification
   - Pre and post deployment checks

## 📖 Documentation

```
lab-ansible/
├── docker-compose.yml           # Container orchestration
├── README.md                    # This file
├── SSL-GUIDE.md                # SSL certificate guide
├── master/
│   └── Dockerfile              # Ansible control node image
├── node/
│   └── Dockerfile              # Target node image
└── ansible/
    ├── ansible.cfg             # Main Ansible configuration
    ├── push_key.sh             # SSH key deployment script
    ├── deploy.sh               # Interactive deployment helper
    ├── PROJECT_STRUCTURE.md    # ⭐ Detailed structure guide
    │
    ├── inventories/            # 📋 Inventory and variables
    │   ├── README.md           # Inventory documentation
    │   ├── hosts.ini           # Main inventory file
    │   ├── group_vars/         # Group variables
    │   │   ├── all.yml         # Global vars
    │   │   ├── dev.yml         # Dev environment
    │   │   ├── test.yml        # Test environment
    │   │   ├── prod.yml        # Prod environment
    │   │   ├── web.yml         # Web servers
    │   │   ├── dns.yml         # DNS servers
    │   │   └── nagios.yml      # Nagios servers
    │   └── host_vars/          # Host-specific vars
    │
    ├── playbooks/              # 🎭 Playbooks and roles
    │   ├── README.md           # Playbooks documentation
    │   ├── site.yml            # Main playbook
    │   ├── web.yml             # Web servers
    │   ├── dns.yml             # DNS servers
    │   ├── nagios.yml          # Monitoring
    │   └── roles/              # Ansible roles
    │       ├── web/            # Nginx + SSL
    │       ├── dns/            # Bind9
    │       └── nagios/         # Nagios4
    │
    └── secrets/                # 🔐 Sensitive data
        ├── README.md           # Security documentation
        ├── .gitignore          # Git ignore for secrets
        ├── keys/               # SSH keys
        │   ├── id_rsa          # Private key (auto-generated)
        │   └── id_rsa.pub      # Public key (auto-generated)
        └── vault/              # Ansible Vault
            └── credentials.yml.example
```

## 📖 Documentation

- **[README.md](README.md)** - This file, quick start guide
- **[PROJECT_STRUCTURE.md](ansible/PROJECT_STRUCTURE.md)** - Detailed project organization
- **[inventories/README.md](ansible/inventories/README.md)** - Inventory and variables guide
- **[playbooks/README.md](ansible/playbooks/README.md)** - Playbooks and roles documentation
- **[secrets/README.md](ansible/secrets/README.md)** - Security and secrets management
- **[SSL-GUIDE.md](SSL-GUIDE.md)** - SSL certificate guide

## 🎯 Learning Exercises

### SSH Connection Issues
```bash
# Re-deploy SSH keys
docker exec master bash /ansible/push_key.sh

# Check authorized keys on node
docker exec node1 cat /home/ansible/.ssh/authorized_keys

# Test SSH manually
docker exec -it master bash
ssh -i /ansible/secrets/keys/id_rsa ansible@node1
```

### Service Not Starting
```bash
# Check service status
ansible node1 -m shell -a 'systemctl status nginx'

# Check logs
ansible node1 -m shell -a 'journalctl -u nginx -n 50'

# Check service on all web servers
ansible '*_web' -m shell -a 'systemctl status nginx'
```

### Playbook Errors
```bash
# Syntax check
ansible-playbook playbooks/site.yml --syntax-check

# Dry run
ansible-playbook playbooks/site.yml --check

# Verbose output
ansible-playbook playbooks/site.yml -vvv

# List tasks that will run
ansible-playbook playbooks/site.yml --list-tasks
```

### Variable Issues
```bash
# Check variable value for host
ansible node1 -m debug -a "var=nginx_http_port"

# Check all variables for host
ansible-inventory --host node1 --yaml

# Show inventory graph
ansible-inventory --graph
```

### Docker Issues
```bash
# View container logs
docker logs master
docker logs node1

# Restart containers
docker-compose restart

# Rebuild specific service
docker-compose build master
docker-compose up -d master
```

## 🧹 Cleanup & Reset

### Stop Containers
```bash
docker-compose down
```

### Remove All Data & Secrets
```bash
docker-compose down -v
rm -rf ansible/secrets/keys/*
```

### Complete Rebuild
```bash
# Clean everything
docker-compose down -v
docker system prune -f

# Rebuild and start
docker-compose build --no-cache
docker-compose up -d

# Deploy SSH keys
docker exec master bash /ansible/push_key.sh

# Test connectivity
docker exec master ansible all -m ping

# Deploy services
docker exec master ansible-playbook /ansible/playbooks/site.yml
```

## 🤝 Contributing

This is a learning project. Feel free to:
- Add new roles
- Improve documentation
- Add more examples
- Share your configurations
- Report issues

## 📝 License

Educational project for learning Ansible automation.

## 🙏 Acknowledgments

Created for ITIC Paris - Ansible automation training course.

---

**Happy Learning! 🚀**

For detailed documentation, see:
- [PROJECT_STRUCTURE.md](ansible/PROJECT_STRUCTURE.md) - Complete structure guide
- [inventories/README.md](ansible/inventories/README.md) - Inventory management
- [playbooks/README.md](ansible/playbooks/README.md) - Playbooks and roles
- [secrets/README.md](ansible/secrets/README.md) - Security practices

1. **Add a staging environment** - Create group_vars/staging.yml and update inventory
2. **Create host-specific variables** - Add files in inventories/host_vars/
3. **Build a new role** - MySQL, Redis, or custom application
4. **Implement Ansible Vault** - Encrypt sensitive credentials
5. **Add custom tags** - For selective task execution
6. **Create dynamic inventory** - Python script for AWS/Azure
7. **Implement rolling updates** - Use serial keyword
8. **Add pre/post deployment hooks** - Custom validation tasks
9. **Configure monitoring checks** - Extend Nagios configuration
10. **Implement backup automation** - Database and config backups

## ⚠️ Troubleshooting
