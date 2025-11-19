# Ansible Lab Environment - ITIC Paris

A professional Ansible lab environment with 1 master control node and 11 managed nodes across 3 environments (dev, test, prod). Features complete DNS infrastructure, web services, and monitoring with static IP addressing.

## 🎯 What You'll Learn

✅ **Professional Project Structure** - Organized like production environments  
✅ **Multi-Environment Management** - Dev, Test, Prod separation with custom domains  
✅ **DNS Infrastructure** - Bind9 DNS servers with environment-specific zones  
✅ **Role-Based Design** - Modular, reusable components (common, web, dns, nagios)  
✅ **Variable Precedence** - Group vars, environment vars, host vars  
✅ **Network Configuration** - Static IP addressing, DNS resolution  
✅ **Security Best Practices** - SSH keys, passwordless authentication  
✅ **Service Management** - Install, configure, monitor services  
✅ **Template Engine** - Dynamic Jinja2 templates  
✅ **Idempotency** - Safe to run multiple times  
✅ **Inventory Management** - Groups, children, dynamic targeting

## 🏗️ Architecture

### Infrastructure Overview
- **1 Master Node** (172.20.0.10) - Ansible control node with SSH access from Windows
- **11 Target Nodes** (172.20.0.11-21) - Managed nodes across 3 environments

### Network Configuration
All containers are on the `ansible_net` Docker network (172.20.0.0/16) with static IPs:

| Node    | IP Address    | Environment | Role       | Domain           |
|---------|---------------|-------------|------------|------------------|
| master  | 172.20.0.10   | Control     | Ansible    | -                |
| node1   | 172.20.0.11   | dev         | Web        | iticparis.dev    |
| node2   | 172.20.0.12   | dev         | Web        | iticparis.dev    |
| node3   | 172.20.0.13   | dev         | DNS        | iticparis.dev    |
| node4   | 172.20.0.14   | dev         | Nagios     | iticparis.dev    |
| node5   | 172.20.0.15   | test        | Web        | iticparis.test   |
| node6   | 172.20.0.16   | test        | DNS        | iticparis.test   |
| node7   | 172.20.0.17   | test        | Nagios     | iticparis.test   |
| node8   | 172.20.0.18   | prod        | Web        | iticparis.prod   |
| node9   | 172.20.0.19   | prod        | Web        | iticparis.prod   |
| node10  | 172.20.0.20   | prod        | DNS        | iticparis.prod   |
| node11  | 172.20.0.21   | prod        | Nagios     | iticparis.prod   |

### Services Deployed
- **Web Servers** - Nginx with SSL, environment-specific pages
- **DNS Servers** - Bind9 with custom domain zones (iticparis.{env})
- **Nagios Monitoring** - Monitoring with secure web interface
- **Common Configuration** - Automated DNS client setup for all nodes

## 📁 Project Structure

```
lab-ansible/
├── docker-compose.yml                 # Container orchestration with static IPs
├── master/Dockerfile                  # Ansible control node (with SSH server)
├── node/Dockerfile                    # Target node template
├── .gitignore                         # Git ignore rules
└── ansible/                           # ⭐ Main Ansible directory
    ├── ansible.cfg                    # Ansible configuration
    ├── push_key.sh                    # SSH key deployment script
    ├── deploy.sh                      # Interactive deployment helper
    │
    ├── inventories/                   # 📋 Inventory and variables
    │   ├── hosts.ini                  # Main inventory with IP mappings
    │   ├── group_vars/                # Group variables
    │   │   ├── all.yml               # Global variables
    │   │   ├── dev.yml               # Dev environment (iticparis.dev)
    │   │   ├── test.yml              # Test environment (iticparis.test)
    │   │   ├── prod.yml              # Prod environment (iticparis.prod)
    │   │   ├── web.yml               # Web servers
    │   │   ├── dns.yml               # DNS servers
    │   │   └── nagios.yml            # Nagios servers
    │   └── host_vars/                # Host-specific variables (optional)
    │
    ├── playbooks/                     # 🎭 Playbooks and roles
    │   ├── site.yml                   # Main playbook (all services)
    │   ├── web.yml                    # Web servers only
    │   ├── dns.yml                    # DNS servers only
    │   ├── dns-client.yml             # Configure DNS clients
    │   ├── nagios.yml                 # Nagios monitoring
    │   └── roles/                     # Ansible roles
    │       ├── common/                # Common configuration (DNS client, hostname)
    │       ├── web/                   # Nginx + SSL role
    │       ├── dns/                   # Bind9 DNS server role
    │       └── nagios/                # Nagios monitoring role
    │
    └── secrets/                       # 🔐 Sensitive data (git-ignored)
        ├── keys/                      # SSH keys
        │   ├── id_rsa                # Private key (auto-generated)
        │   └── id_rsa.pub            # Public key (auto-generated)
        └── vault/                     # Ansible Vault (optional)
```

## 🚀 Quick Start

### 1. Start the Environment
```powershell
# From Windows PowerShell in the project directory
docker-compose up -d
```

This will start:
- 1 master container (172.20.0.10) with SSH exposed on port 2222
- 11 node containers (172.20.0.11-21) with static IPs

### 2. Access the Master Container
```powershell
# SSH from Windows to master
ssh -p 2222 ansible@localhost
# Password: ansible
```

### 3. Deploy SSH Keys
Once inside the master container:
```bash
cd /ansible
./push_key.sh
```

This script will:
- Generate SSH key pair (if not exists)
- Deploy public key to all 11 nodes using password authentication
- Enable passwordless SSH for Ansible automation

### 4. Test Connectivity
```bash
# Test Ansible connectivity to all nodes
ansible all -m ping

# Test connectivity by environment
ansible dev -m ping
ansible test -m ping
ansible prod -m ping

# Check inventory
ansible-inventory --list
```

### 5. Deploy Services

#### Full Infrastructure Deployment
```bash
# Deploy all services to all environments
ansible-playbook playbooks/site.yml

# Deploy to specific environment
ansible-playbook playbooks/site.yml --limit dev
ansible-playbook playbooks/site.yml --limit test
ansible-playbook playbooks/site.yml --limit prod
```

#### Individual Service Deployment
```bash
# Deploy DNS servers
ansible-playbook playbooks/dns.yml --limit dev

# Configure DNS clients (non-DNS servers)
ansible-playbook playbooks/dns-client.yml --limit dev

# Deploy web servers
ansible-playbook playbooks/web.yml --limit dev

# Deploy Nagios monitoring
ansible-playbook playbooks/nagios.yml --limit dev
```

## 🌍 Environment Details

### Development (dev)
- **Domain**: `iticparis.dev`
- **DNS Server**: node3 (172.20.0.13)
- **Web Servers**: node1, node2
- **Monitoring**: node4
- **Resources**: Minimal (2 workers, 512 connections)
- **Debug**: Enabled

### Test (test)
- **Domain**: `iticparis.test`
- **DNS Server**: node6 (172.20.0.16)
- **Web Server**: node5
- **Monitoring**: node7
- **Resources**: Moderate (2 workers, 768 connections)
- **Debug**: Enabled

### Production (prod)
- **Domain**: `iticparis.prod`
- **DNS Server**: node10 (172.20.0.20)
- **Web Servers**: node8, node9
- **Monitoring**: node11
- **Resources**: Full (4 workers, 1024 connections)
- **Debug**: Disabled

## 🔧 DNS Configuration

Each environment has its own DNS server that provides name resolution for that environment:

### DNS Servers
- **Dev DNS** (node3): Resolves `*.iticparis.dev` → 172.20.0.11-14
- **Test DNS** (node6): Resolves `*.iticparis.test` → 172.20.0.15-17
- **Prod DNS** (node10): Resolves `*.iticparis.prod` → 172.20.0.18-21

### DNS Clients
All non-DNS servers are automatically configured to use their environment's DNS server:
- Dev servers (node1, node2, node4) → Use node3 as DNS
- Test servers (node5, node7) → Use node6 as DNS
- Prod servers (node8, node9, node11) → Use node10 as DNS

Fallback DNS: 8.8.8.8, 1.1.1.1

## 🌐 Network Configuration

### SSH Access
```bash
# Windows → Master
ssh -p 2222 ansible@localhost

# Master → Any Node
ssh ansible@172.20.0.11  # Using IP
ssh ansible@node1         # Using hostname (Docker DNS)
```

### Network Troubleshooting
```bash
# From master container
# Ping all nodes
for i in {11..21}; do ping -c 1 172.20.0.$i; done

# Test DNS resolution
dig @172.20.0.13 iticparis.dev
nslookup node1 172.20.0.13

# Check network connectivity
ansible all -m shell -a "ip addr show"
```
- Enable passwordless SSH authentication for Ansible

## 🎭 Ansible Roles

### Common Role
Applied to all servers to configure base system settings:
- Sets hostname to FQDN (e.g., node1.iticparis.dev)
- Configures DNS resolution using environment's DNS server
- Updates `/etc/resolv.conf` and `/etc/hosts`
- Handles immutable files in Docker containers
- Tests DNS connectivity

### DNS Role
Configures Bind9 DNS servers:
- Installs Bind9 and utilities
- Configures DNS forwarders (8.8.8.8, 8.8.4.4, 1.1.1.1)
- Sets up zone files for environment domains
- Validates configuration syntax
- Manages named service

### Web Role
Configures Nginx web servers:
- Installs Nginx
- Configures SSL/TLS certificates
- Environment-specific web pages
- Security headers (HSTS, XSS protection)

### Nagios Role
Configures Nagios monitoring:
- Installs Nagios4
- Configures monitoring checks
- Secure web interface
- Email notifications

## 📋 Common Commands

### Inventory Management
```bash
# List all hosts
ansible all --list-hosts

# List by environment
ansible dev --list-hosts
ansible test --list-hosts
ansible prod --list-hosts

# List by role
ansible '*_web' --list-hosts
ansible '*_dns' --list-hosts
ansible '*_nagios' --list-hosts

# Show inventory graph
ansible-inventory --graph

# Check variables for a host
ansible node1 -m debug -a "var=hostvars[inventory_hostname]"
```

### Playbook Operations
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

# Run specific tags
ansible-playbook playbooks/dns.yml --tags config
ansible-playbook playbooks/site.yml --tags dns
```

### Ad-hoc Commands
```bash
# Run shell commands
ansible all -m shell -a 'uptime'
ansible dev -m shell -a 'df -h'

# Check service status
ansible '*_web' -m shell -a 'systemctl status nginx'
ansible '*_dns' -m shell -a 'systemctl status named'

# Copy files
ansible all -m copy -a 'src=/tmp/test.txt dest=/tmp/test.txt'

# Install packages
ansible dev -m apt -a 'name=htop state=present'
```

## 🔍 Verification & Testing

### DNS Verification
```bash
# Test DNS from master
docker exec master dig @172.20.0.13 iticparis.dev

# Test from inside a node
ansible node1 -m shell -a "cat /etc/resolv.conf"
ansible node1 -m shell -a "nslookup node3"
ansible node1 -m shell -a "dig iticparis.dev"
```

### Web Server Testing
```bash
# HTTP (should redirect to HTTPS)
curl http://node1

# HTTPS (ignore self-signed cert)
curl -k https://node1

# Check all web servers
for node in node1 node2 node5 node8 node9; do
  echo "=== $node ==="
  docker exec master curl -sk https://$node | grep -i environment
done
```

### Service Status
```bash
# Check all services
ansible '*_web' -m shell -a 'systemctl status nginx'
ansible '*_dns' -m shell -a 'systemctl status named'
ansible '*_nagios' -m shell -a 'systemctl status nagios4'
```

### 4. Deploy Services

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

## 🌐 Network Configuration

All containers have static IP addresses for reliable connectivity:

- **Master**: 172.20.0.10 (SSH: localhost:2222 from Windows)
- **Node1-11**: 172.20.0.11 - 172.20.0.21

See [IP-MAPPING.md](IP-MAPPING.md) for complete network documentation.

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
- **[IP-MAPPING.md](IP-MAPPING.md)** - Network configuration and IP addresses
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
```powershell
docker-compose down
```

### Remove All Data
```powershell
docker-compose down -v
```

### Complete Rebuild
```powershell
# Clean everything
docker-compose down -v

# Rebuild images
docker-compose build --no-cache

# Start containers
docker-compose up -d

# Wait a moment, then SSH to master
ssh -p 2222 ansible@localhost
# Password: ansible

# Deploy SSH keys
cd /ansible
./push_key.sh

# Test connectivity
ansible all -m ping

# Deploy full infrastructure
ansible-playbook playbooks/site.yml --limit dev
```

## ⚠️ Troubleshooting

### SSH Connection Issues
```bash
# Re-deploy SSH keys
./push_key.sh

# Test manual SSH
ssh ansible@172.20.0.11
# Password: ansible (if keys not deployed)

# Check SSH service on node
ansible node1 -m shell -a "systemctl status sshd"
```

### DNS Issues
```bash
# Check DNS server status
ansible node3 -m shell -a "systemctl status named"

# Check DNS configuration
ansible node3 -m shell -a "named-checkconf"

# Test DNS resolution
ansible node1 -m shell -a "cat /etc/resolv.conf"
ansible node1 -m shell -a "dig @172.20.0.13 iticparis.dev"
```

### Ansible Configuration Issues
```bash
# Verify ansible.cfg is being read
cd /ansible
ansible --version

# Check inventory
ansible-inventory --list

# Test with verbose output
ansible all -m ping -vvv
```

### Container Network Issues
```powershell
# Check container IPs
docker inspect master | Select-String "IPAddress"
docker inspect node1 | Select-String "IPAddress"

# Test network connectivity
docker exec master ping -c 2 172.20.0.11
```

### Permission Issues with /etc files
If you get "Device or resource busy" errors:
```bash
# The common role handles this automatically
# It removes immutable attributes from /etc/resolv.conf and /etc/hosts
# If issues persist, check the common role tasks
```

## 📚 Additional Resources

### Documentation
- **Ansible Documentation**: https://docs.ansible.com/
- **Docker Documentation**: https://docs.docker.com/
- **Bind9 Documentation**: https://bind9.readthedocs.io/
- **Nginx Documentation**: https://nginx.org/en/docs/

### Learning Path
1. Start with `ansible all -m ping` to test connectivity
2. Deploy DNS servers first: `ansible-playbook playbooks/dns.yml --limit dev`
3. Configure DNS clients: `ansible-playbook playbooks/dns-client.yml --limit dev`
4. Deploy web servers: `ansible-playbook playbooks/web.yml --limit dev`
5. Deploy monitoring: `ansible-playbook playbooks/nagios.yml --limit dev`
6. Repeat for test and prod environments

## 🎓 Lab Exercises

1. **DNS Configuration**: Modify DNS forwarders in group_vars/dns.yml
2. **Custom Web Pages**: Update templates in roles/web/templates/
3. **New Environment**: Add staging environment between test and prod
4. **Host Variables**: Create host-specific overrides in host_vars/
5. **Custom Roles**: Create a new role for additional services
6. **Tags**: Use tags to run specific parts of playbooks
7. **Handlers**: Add custom handlers for service restarts
8. **Facts**: Use ansible facts in your templates
9. **Conditionals**: Add when conditions for task execution
10. **Loops**: Implement loops for repetitive tasks

## 📝 License & Credits

**Educational Project** for ITIC Paris - Ansible Automation Training Course

**Author**: Oubaid HLAIMI 
**Managed by**: M. Melvin BISSOR
**Year**: 2025

---

**Happy Learning with Ansible! 🚀**
