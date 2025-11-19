# IP Address Mapping

## Network Configuration
- **Network**: 172.20.0.0/16
- **Subnet**: ansible_net (Docker bridge)

## Hosts

### Control Node
| Hostname | IP Address    | Role          | SSH Port |
|----------|---------------|---------------|----------|
| master   | 172.20.0.10   | Control Node  | 2222     |

### Development Environment (dev.local)
| Hostname | IP Address    | Role          | Services          |
|----------|---------------|---------------|-------------------|
| node1    | 172.20.0.11   | Web Server    | Nginx + SSL       |
| node2    | 172.20.0.12   | Web Server    | Nginx + SSL       |
| node3    | 172.20.0.13   | DNS Server    | Bind9             |
| node4    | 172.20.0.14   | Monitoring    | Nagios4 + Nginx   |

### Test Environment (test.local)
| Hostname | IP Address    | Role          | Services          |
|----------|---------------|---------------|-------------------|
| node5    | 172.20.0.15   | Web Server    | Nginx + SSL       |
| node6    | 172.20.0.16   | DNS Server    | Bind9             |
| node7    | 172.20.0.17   | Monitoring    | Nagios4 + Nginx   |

### Production Environment (prod.local)
| Hostname | IP Address    | Role          | Services          |
|----------|---------------|---------------|-------------------|
| node8    | 172.20.0.18   | Web Server    | Nginx + SSL       |
| node9    | 172.20.0.19   | Web Server    | Nginx + SSL       |
| node10   | 172.20.0.20   | DNS Server    | Bind9             |
| node11   | 172.20.0.21   | Monitoring    | Nagios4 + Nginx   |

## Connection Information

### SSH to Master from Windows Host
```bash
ssh -p 2222 ansible@localhost
# Password: ansible
```

### SSH from Master to Nodes
```bash
# Using IP address
ssh ansible@172.20.0.11

# Using hostname (requires DNS or /etc/hosts)
ssh ansible@node1

# All nodes use:
# Username: ansible
# Auth: SSH key (/ansible/secrets/keys/id_rsa)
```

## Testing Connectivity

### From Windows Host
```powershell
# Ping master container
docker exec master ping -c 2 172.20.0.11

# Check all IPs
docker exec master ping -c 1 172.20.0.11
docker exec master ping -c 1 172.20.0.12
# ... etc
```

### From Master Container
```bash
# Ping all nodes
for i in {11..21}; do echo "=== 172.20.0.$i ==="; ping -c 1 172.20.0.$i; done

# SSH to all nodes
for i in {11..21}; do echo "=== 172.20.0.$i ==="; ssh -o ConnectTimeout=2 ansible@172.20.0.$i "hostname"; done

# Ansible ping
ansible all -m ping
```

## DNS Resolution

Currently, containers can reach each other by:
1. **IP Address**: `172.20.0.x` (always works)
2. **Container Name**: `node1`, `node2`, etc. (Docker DNS)
3. **Hostname**: Same as container name

To set up custom DNS with your Bind9 roles, you would configure zone files to map:
- `web1.dev.local` → `172.20.0.11`
- `web2.dev.local` → `172.20.0.12`
- etc.

## Port Mapping

| Service | Container Port | Host Port | Container      |
|---------|----------------|-----------|----------------|
| SSH     | 22             | 2222      | master         |
| SSH     | 22             | -         | node1-11       |
| HTTP    | 80             | -         | web servers    |
| HTTPS   | 443            | -         | web servers    |
| DNS     | 53             | -         | dns servers    |
| Nagios  | 443            | -         | nagios servers |

**Note**: Only the master SSH port is exposed to the host. All other services are accessible only within the Docker network or through the master container.
