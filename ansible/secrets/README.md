# Secrets Directory

This directory contains sensitive files that should **NEVER** be committed to version control.

## Structure

```
secrets/
├── keys/           # SSH keys and other cryptographic keys
│   ├── id_rsa      # Private SSH key (generated)
│   └── id_rsa.pub  # Public SSH key (generated)
└── vault/          # Ansible Vault encrypted files
    └── credentials.yml  # Encrypted credentials (optional)
```

## Important Notes

⚠️ **Security Warning**: 
- All files in this directory are automatically ignored by git (see .gitignore)
- Never share private keys or commit them to repositories
- Use Ansible Vault for encrypting sensitive data

## SSH Keys

SSH keys are automatically generated when running `push_key.sh` script.
Location: `secrets/keys/id_rsa` and `secrets/keys/id_rsa.pub`

## Ansible Vault

To create encrypted variables:

```bash
# Create a new vault file
ansible-vault create secrets/vault/credentials.yml

# Edit existing vault file
ansible-vault edit secrets/vault/credentials.yml

# Encrypt existing file
ansible-vault encrypt secrets/vault/credentials.yml

# Decrypt file
ansible-vault decrypt secrets/vault/credentials.yml
```

Example vault content:
```yaml
---
database_password: super_secret_password
api_key: your_api_key_here
ssl_passphrase: certificate_passphrase
```

## Usage in Playbooks

To use vault-encrypted variables:

```yaml
---
- hosts: all
  vars_files:
    - ../secrets/vault/credentials.yml
  tasks:
    - name: Use encrypted variable
      debug:
        msg: "Password is {{ database_password }}"
```

Run playbook with vault:
```bash
ansible-playbook -i inventories/hosts.ini playbooks/site.yml --ask-vault-pass
```

Or use a password file:
```bash
echo "your_vault_password" > secrets/.vault_pass
ansible-playbook -i inventories/hosts.ini playbooks/site.yml --vault-password-file secrets/.vault_pass
```
