# Inventories Directory

This directory contains all inventory and variable definitions for the Ansible lab.

## 📁 Structure

```
inventories/
├── hosts.ini              # Main inventory file
├── group_vars/            # Variables for groups of hosts
│   ├── all.yml           # Variables for all hosts
│   ├── dev.yml           # Development environment
│   ├── test.yml          # Testing environment
│   ├── prod.yml          # Production environment
│   ├── web.yml           # Web servers group
│   ├── dns.yml           # DNS servers group
│   └── nagios.yml        # Nagios servers group
└── host_vars/            # Variables for individual hosts (optional)
```

## 🎯 Hosts Inventory

The `hosts.ini` file defines:
- All server hostnames
- Environment groupings (dev, test, prod)
- Service groupings (web, dns, nagios)
- Global variables

## 📊 Variable Precedence

Ansible loads variables in this order (last wins):

1. **all.yml** - Variables for all hosts
2. **Environment group vars** (dev.yml, test.yml, prod.yml)
3. **Service group vars** (web.yml, dns.yml, nagios.yml)
4. **host_vars/** - Host-specific variables
5. **Playbook vars** - Variables defined in playbooks
6. **Command line** - Variables passed with -e flag

## 🌍 Environments

### Development (dev)
- Nodes: 1-4
- Domain: dev.local
- Purpose: Development and testing new features
- Resources: Minimal

### Test (test)
- Nodes: 5-7
- Domain: test.local
- Purpose: Pre-production testing
- Resources: Moderate

### Production (prod)
- Nodes: 8-11
- Domain: prod.local
- Purpose: Live production environment
- Resources: Full

## 🏷️ Groups

### Environment Groups
- `dev`, `test`, `prod` - Environment-specific hosts

### Service Groups
- `web` - All web servers (across all environments)
- `dns` - All DNS servers (across all environments)
- `nagios` - All Nagios monitoring servers

### Combined Groups
- `dev_web`, `test_web`, `prod_web` - Web servers per environment
- `dev_dns`, `test_dns`, `prod_dns` - DNS servers per environment
- `dev_nagios`, `test_nagios`, `prod_nagios` - Nagios per environment

## 📝 Working with Inventory

### View Inventory
```bash
# List all hosts
ansible all --list-hosts

# List specific group
ansible dev --list-hosts
ansible web --list-hosts
ansible dev_web --list-hosts

# Show inventory graph
ansible-inventory --graph

# Show all variables for a host
ansible node1 -m debug -a "var=hostvars[inventory_hostname]"
```

### Test Variables
```bash
# Check specific variable
ansible node1 -m debug -a "var=env"
ansible dev -m debug -a "var=dns_domain"
ansible web -m debug -a "var=nginx_http_port"

# Show all group variables for a group
ansible-inventory --host node1 --yaml
```

## 🎓 Adding New Hosts

### 1. Add to hosts.ini
```ini
[dev_web]
node1
node2
new_node_name  # Add here
```

### 2. Add to docker-compose.yml (if using Docker)
```yaml
new_node:
  build: ./node
  container_name: new_node_name
  networks:
    - ansible_net
```

### 3. Deploy SSH keys
```bash
bash push_key.sh
```

## 🔧 Custom Variables

### Group Variables
Create or edit files in `group_vars/`:

```yaml
# inventories/group_vars/web.yml
---
custom_web_setting: value
another_setting: true
```

### Host Variables
Create files in `host_vars/`:

```yaml
# inventories/host_vars/node1.yml
---
custom_hostname: special-node1
extra_packages:
  - htop
  - vim
```

## 🎯 Best Practices

1. **Use group_vars for shared settings** across multiple hosts
2. **Use host_vars sparingly** only for truly unique configurations
3. **Document variables** with comments
4. **Keep sensitive data in vault** files
5. **Use meaningful group names** that reflect purpose
6. **Organize by environment AND service** for flexibility
7. **Test variable precedence** before deploying to production

## 📖 Examples

### Target Specific Groups
```bash
# All development servers
ansible-playbook playbooks/site.yml --limit dev

# Only web servers in dev
ansible-playbook playbooks/web.yml --limit dev_web

# Multiple groups
ansible-playbook playbooks/site.yml --limit "dev,test"

# Specific hosts
ansible-playbook playbooks/site.yml --limit "node1,node2"
```

### Using Variables in Playbooks
```yaml
---
- hosts: web
  tasks:
    - name: Show environment
      debug:
        msg: "This is {{ env }} environment with domain {{ dns_domain }}"
```

---

For more information, see the main [PROJECT_STRUCTURE.md](../PROJECT_STRUCTURE.md)
