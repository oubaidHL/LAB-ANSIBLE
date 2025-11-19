# Playbooks Directory

This directory contains all Ansible playbooks and roles for the lab environment.

## 📋 Playbooks

### site.yml
Main playbook that deploys all services to all environments.
```bash
ansible-playbook playbooks/site.yml
```

### web.yml
Deploys Nginx web servers with SSL.
```bash
ansible-playbook playbooks/web.yml
```

### dns.yml
Deploys Bind9 DNS servers.
```bash
ansible-playbook playbooks/dns.yml
```

### nagios.yml
Deploys Nagios monitoring with Nginx frontend.
```bash
ansible-playbook playbooks/nagios.yml
```

## 🎭 Roles

### Web Role
- Installs and configures Nginx
- Generates self-signed SSL certificates
- Deploys environment-specific web pages
- Configures HTTPS with security headers
- Uses handlers for service management

**Variables**: See `roles/web/defaults/main.yml`

### DNS Role
- Installs and configures Bind9
- Sets up DNS forwarders
- Configures domain zones
- Uses built-in Ansible facts
- Validates DNS configuration

**Variables**: See `roles/dns/defaults/main.yml`

### Nagios Role
- Installs Nagios4 monitoring
- Configures Nginx reverse proxy with SSL
- Sets up web interface authentication
- Deploys monitoring configuration
- Includes health checks

**Variables**: See `roles/nagios/defaults/main.yml`

## 🏷️ Available Tags

All roles support tags for selective execution:

- `packages` - Install packages only
- `config` - Configuration tasks only
- `ssl` - SSL/TLS related tasks
- `services` - Service management tasks
- `validation` - Verification tasks
- `debug` - Debug output tasks
- `summary` - Summary information

**Example**:
```bash
# Install packages only
ansible-playbook playbooks/site.yml --tags packages

# Skip SSL generation
ansible-playbook playbooks/site.yml --skip-tags ssl

# Debug information only
ansible-playbook playbooks/web.yml --tags debug
```

## 📚 Usage Examples

### Deploy to Specific Environment
```bash
ansible-playbook playbooks/site.yml --limit dev
ansible-playbook playbooks/site.yml --limit test
ansible-playbook playbooks/site.yml --limit prod
```

### Deploy to Specific Servers
```bash
ansible-playbook playbooks/web.yml --limit node1
ansible-playbook playbooks/site.yml --limit "node1,node2,node3"
```

### Dry Run (Check Mode)
```bash
ansible-playbook playbooks/site.yml --check
```

### Verbose Output
```bash
ansible-playbook playbooks/site.yml -v     # Verbose
ansible-playbook playbooks/site.yml -vv    # More verbose
ansible-playbook playbooks/site.yml -vvv   # Very verbose
ansible-playbook playbooks/site.yml -vvvv  # Debug level
```

## 🔧 Creating New Playbooks

Example template for a new playbook:

```yaml
---
- name: Description of what this playbook does
  hosts: target_group
  become: yes
  
  vars:
    custom_var: value
  
  pre_tasks:
    - name: Pre-deployment checks
      debug:
        msg: "Starting deployment"
  
  roles:
    - role: your_role
      when: condition
  
  post_tasks:
    - name: Post-deployment verification
      debug:
        msg: "Deployment complete"
  
  tags:
    - your_playbook
```

## 🎯 Best Practices

1. **Always test with --check first**
2. **Use tags for selective execution**
3. **Document role variables in defaults/main.yml**
4. **Keep playbooks simple, put logic in roles**
5. **Use handlers for service restarts**
6. **Validate configurations before applying**
7. **Include debug tasks for troubleshooting**
8. **Tag tasks appropriately**

---

For more information, see the main [PROJECT_STRUCTURE.md](../PROJECT_STRUCTURE.md)
