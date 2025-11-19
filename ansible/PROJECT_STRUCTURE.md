# Ansible Lab - Organized Structure

This lab demonstrates professional Ansible project organization with proper separation of concerns.

## 📁 Directory Structure

```
ansible/
├── ansible.cfg                      # Main Ansible configuration
├── push_key.sh                      # SSH key deployment script
├── deploy.sh                        # Interactive deployment helper
│
├── inventories/                     # All inventory-related files
│   ├── hosts.ini                    # Main inventory file
│   ├── group_vars/                  # Group-specific variables
│   │   ├── all.yml                  # Variables for all hosts
│   │   ├── dev.yml                  # Development environment
│   │   ├── test.yml                 # Testing environment
│   │   ├── prod.yml                 # Production environment
│   │   ├── web.yml                  # Web servers group
│   │   ├── dns.yml                  # DNS servers group
│   │   └── nagios.yml               # Nagios servers group
│   └── host_vars/                   # Host-specific variables (optional)
│
├── playbooks/                       # All playbooks and roles
│   ├── site.yml                     # Main playbook (deploy everything)
│   ├── web.yml                      # Web servers playbook
│   ├── dns.yml                      # DNS servers playbook
│   ├── nagios.yml                   # Nagios monitoring playbook
│   └── roles/                       # Ansible roles
│       ├── web/                     # Web server role (Nginx + SSL)
│       ├── dns/                     # DNS server role (Bind9)
│       └── nagios/                  # Monitoring role (Nagios4)
│
└── secrets/                         # Sensitive data (git-ignored)
    ├── .gitignore                   # Ignore all secrets except examples
    ├── README.md                    # Documentation for secrets
    ├── keys/                        # SSH and other keys
    │   ├── id_rsa                   # Private SSH key (generated)
    │   ├── id_rsa.pub               # Public SSH key (generated)
    │   └── README.md                # Keys documentation
    └── vault/                       # Ansible Vault encrypted files
        ├── credentials.yml.example  # Example vault file
        └── README.md                # Vault documentation
```

## 🚀 Quick Start

### 1. Start Environment
```bash
docker-compose up -d
```

### 2. Deploy SSH Keys
```bash
# From host (Windows PowerShell)
docker exec master bash /ansible/push_key.sh
```

### 3. Access Master Container
```bash
docker exec -it master bash
cd /ansible
```

### 4. Test Connectivity
```bash
ansible all -m ping
```

### 5. Deploy Services

#### Using the Helper Script (Recommended)
```bash
bash deploy.sh
```

#### Manual Deployment
```bash
# Deploy everything to all environments
ansible-playbook playbooks/site.yml

# Deploy specific service
ansible-playbook playbooks/web.yml
ansible-playbook playbooks/dns.yml
ansible-playbook playbooks/nagios.yml

# Deploy to specific environment
ansible-playbook playbooks/site.yml --limit dev
ansible-playbook playbooks/site.yml --limit prod

# Deploy specific service to specific environment
ansible-playbook playbooks/web.yml --limit test
```

## 📚 Understanding the Structure

### Inventories Directory
Contains all inventory and variable definitions:
- **hosts.ini**: Defines all servers and their groups
- **group_vars/**: Variables that apply to groups of servers
  - Environment-specific: `dev.yml`, `test.yml`, `prod.yml`
  - Service-specific: `web.yml`, `dns.yml`, `nagios.yml`
  - Global: `all.yml`

### Playbooks Directory
Contains all executable playbooks and roles:
- **Playbooks**: YAML files that define what should be done
- **Roles**: Reusable, modular components

### Secrets Directory
Stores sensitive data (automatically git-ignored):
- **keys/**: SSH keys and certificates
- **vault/**: Ansible Vault encrypted variables

## 🔐 Working with Secrets

### SSH Keys
Generated automatically by `push_key.sh`:
```bash
bash push_key.sh
```

### Ansible Vault
Create encrypted credentials:
```bash
# Create new vault file
ansible-vault create secrets/vault/credentials.yml

# Edit existing vault file
ansible-vault edit secrets/vault/credentials.yml

# Run playbook with vault
ansible-playbook playbooks/site.yml --ask-vault-pass
```

## 🎯 Common Commands

### Inventory Management
```bash
# List all hosts
ansible all --list-hosts

# List hosts in specific group
ansible dev --list-hosts
ansible '*_web' --list-hosts

# Show inventory structure
ansible-inventory --graph
```

### Ad-hoc Commands
```bash
# Ping all hosts
ansible all -m ping

# Check service status
ansible '*_web' -m shell -a 'systemctl status nginx'
ansible '*_dns' -m shell -a 'systemctl status bind9'
ansible '*_nagios' -m shell -a 'systemctl status nagios4'

# Gather facts
ansible node1 -m setup

# Check disk space
ansible all -m shell -a 'df -h'
```

### Playbook Execution
```bash
# Syntax check
ansible-playbook playbooks/site.yml --syntax-check

# Dry run (check mode)
ansible-playbook playbooks/site.yml --check

# Verbose output
ansible-playbook playbooks/site.yml -v
ansible-playbook playbooks/site.yml -vvv

# Run specific tags
ansible-playbook playbooks/site.yml --tags "packages"
ansible-playbook playbooks/site.yml --skip-tags "ssl"

# Step-by-step execution
ansible-playbook playbooks/site.yml --step
```

## 🔍 Verification

### Web Servers
```bash
# Test HTTP to HTTPS redirect
curl -L http://node1

# Test HTTPS (ignore self-signed cert)
curl -k https://node1

# Check SSL certificate
openssl s_client -connect node1:443 -showcerts
```

### DNS Servers
```bash
# Test DNS resolution
docker exec node3 dig @localhost dev.local
docker exec node6 dig @localhost test.local

# Check DNS config
docker exec node3 named-checkconf
```

### Nagios Monitoring
```bash
# Access Nagios web interface
# https://<docker-host-ip>/nagios4/
# Username: nagiosadmin
# Password: nagiosadmin

# Check Nagios config
docker exec node4 nagios4 -v /etc/nagios4/nagios.cfg
```

## 📖 Learning Features

This lab demonstrates:

✅ **Professional Structure** - Organized like production environments  
✅ **Variable Precedence** - Group vars, host vars, environment vars  
✅ **Role-Based Design** - Modular, reusable components  
✅ **Multi-Environment** - Dev, Test, Prod separation  
✅ **Security Best Practices** - Secrets management, Ansible Vault  
✅ **Inventory Management** - Groups, children, variables  
✅ **Advanced Ansible Features** - Handlers, listeners, conditionals, facts  
✅ **Service Management** - Installation, configuration, monitoring  
✅ **Template Engine** - Jinja2 templating with variables  
✅ **Idempotency** - Safe to run multiple times  

## 🎓 Learning Exercises

1. **Add a new environment** (staging) in `inventories/`
2. **Create host-specific variables** in `inventories/host_vars/`
3. **Add a new role** (e.g., database, monitoring agent)
4. **Use Ansible Vault** to encrypt sensitive variables
5. **Create custom tags** for selective execution
6. **Implement rolling updates** with serial execution
7. **Add pre and post deployment tasks**
8. **Create dynamic inventory** scripts

## 🛠️ Troubleshooting

### SSH Connection Issues
```bash
# Test SSH manually
ssh -i secrets/keys/id_rsa ansible@node1

# Check authorized keys
docker exec node1 cat /home/ansible/.ssh/authorized_keys
```

### Variable Precedence Issues
```bash
# Debug variable values
ansible node1 -m debug -a "var=nginx_http_port"
ansible dev -m debug -a "var=env"
```

### Playbook Errors
```bash
# Check syntax
ansible-playbook playbooks/site.yml --syntax-check

# List tasks
ansible-playbook playbooks/site.yml --list-tasks

# List hosts
ansible-playbook playbooks/site.yml --list-hosts
```

## 📝 File Migration Notes

If you have existing files in the old structure, they've been reorganized:

**Old Location** → **New Location**
- `inventory.ini` → `inventories/hosts.ini`
- `group_vars/` → `inventories/group_vars/`
- `site.yml` → `playbooks/site.yml`
- `web.yml` → `playbooks/web.yml`
- `dns.yml` → `playbooks/dns.yml`
- `nagios.yml` → `playbooks/nagios.yml`
- `roles/` → `playbooks/roles/`
- `id_rsa*` → `secrets/keys/id_rsa*`

The old files are kept for backward compatibility but should be considered deprecated.

---

**Created for learning professional Ansible automation practices**
