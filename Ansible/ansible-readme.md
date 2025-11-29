# Infrastructure Automation with Ansible

This repository contains Ansible playbooks for automated homelab maintenance.

## Overview

- **Control Machine**: 10.0.0.113 (scriptadmin)
- **Target Servers**:
  - server1 (10.0.0.104) - ubsysadmin1 - Docker host
  - server2 (10.0.0.105) - ubsysadmin2 - Docker host + NFS mount

## Features

The maintenance playbook performs:
- System updates (apt update & upgrade)
- Docker container management (stop before reboot, start after)
- Server reboots
- NFS mount verification (server2 only)
- Container health checks

---

## Initial Setup

### 1. Prepare Control Machine

Install required packages:
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y ansible git
```

Verify installation:
```bash
ansible --version
```

### 2. Set Up SSH Key Authentication

Generate SSH key on control machine:
```bash
ssh-keygen -t ed25519 -C "ansible-automation"
# Press Enter for all prompts
```

Copy SSH key to target servers:
```bash
ssh-copy-id ubsysadmin1@10.0.0.104
ssh-copy-id ubsysadmin2@10.0.0.105
```

Test SSH connections (should connect without password):
```bash
ssh ubsysadmin1@10.0.0.104
exit
ssh ubsysadmin2@10.0.0.105
exit
```

### 3. Configure Passwordless Sudo on Target Servers

This is required for automated scheduling.

**On server1:**
```bash
ssh ubsysadmin1@10.0.0.104
sudo visudo
```
Add at the end:
```
ubsysadmin1 ALL=(ALL) NOPASSWD: ALL
```

**On server2:**
```bash
ssh ubsysadmin2@10.0.0.105
sudo visudo
```
Add at the end:
```
ubsysadmin2 ALL=(ALL) NOPASSWD: ALL
```

### 4. Clone This Repository

```bash
cd ~
git clone https://github.com/yourusername/Infrastructure-Automation.git
cd Infrastructure-Automation/Ansible
```

### 5. Test Ansible Connection

```bash
ansible all -m ping
```

Expected output:
```
server1 | SUCCESS => { "ping": "pong" }
server2 | SUCCESS => { "ping": "pong" }
```

---

## Files Structure

```
Ansible/
├── ansible.cfg                    # Ansible configuration
├── inventory.ini                  # Server inventory
├── maintenance.yml                # Main maintenance playbook
├── test_connection_script.sh      # Quick connection test script
└── README.md                      # This file
```

---

## Usage

### Test Connection

```bash
bash test_connection_script.sh
# OR
ansible all -m ping
```

### Run Maintenance Playbook

**Dry run (check mode) - shows what would happen:**
```bash
ansible-playbook maintenance.yml --check
```

**Test on single server:**
```bash
ansible-playbook maintenance.yml --limit server1
# OR
ansible-playbook maintenance.yml --limit server2
```

**Run on all servers:**
```bash
ansible-playbook maintenance.yml
```

### Check Docker Containers

```bash
ansible docker_hosts -a "docker ps"
```

### Check System Uptime

```bash
ansible all -a "uptime"
```

---

## Scheduling Weekly Maintenance

### Set Up Systemd Timer

**1. Create service file:**
```bash
sudo nano /etc/systemd/system/ansible-maintenance.service
```

Paste:
```ini
[Unit]
Description=Homelab Ansible Maintenance
After=network-online.target

[Service]
Type=oneshot
User=scriptadmin
WorkingDirectory=/home/scriptadmin/Infrastructure-Automation/Ansible
ExecStart=/usr/bin/ansible-playbook maintenance.yml
StandardOutput=append:/var/log/ansible-maintenance.log
StandardError=append:/var/log/ansible-maintenance.log
```

**2. Create timer file:**
```bash
sudo nano /etc/systemd/system/ansible-maintenance.timer
```

Paste (runs every Sunday at 3 AM):
```ini
[Unit]
Description=Weekly Homelab Ansible Maintenance Timer

[Timer]
OnCalendar=Sun *-*-* 03:00:00
Persistent=true
RandomizedDelaySec=30min

[Install]
WantedBy=timers.target
```

**3. Enable and start timer:**
```bash
sudo systemctl daemon-reload
sudo systemctl enable ansible-maintenance.timer
sudo systemctl start ansible-maintenance.timer
```

**4. Verify timer:**
```bash
# Check timer status
sudo systemctl status ansible-maintenance.timer

# See when it will run next
systemctl list-timers ansible-maintenance.timer

# View logs
sudo journalctl -u ansible-maintenance.service -f
```

### Change Schedule

Edit the timer file and modify `OnCalendar`:
```bash
sudo nano /etc/systemd/system/ansible-maintenance.timer
```

Examples:
- Daily at 2 AM: `OnCalendar=*-*-* 02:00:00`
- Every Monday at 3 AM: `OnCalendar=Mon *-*-* 03:00:00`
- First day of month: `OnCalendar=*-*-01 03:00:00`

Then reload:
```bash
sudo systemctl daemon-reload
sudo systemctl restart ansible-maintenance.timer
```

### Timezone Configuration

The systemd timer uses the control machine's local timezone.

**Check current timezone:**
```bash
timedatectl
```

**Set to Asia/Manila timezone:**
```bash
sudo timedatectl set-timezone Asia/Manila
timedatectl  # Verify
```

**The timer schedule `OnCalendar=Sun *-*-* 03:00:00` means:**
- Sunday at 3:00 AM in your local timezone (Asia/Manila = PHT +0800)

**List of common timezones:**
- `Asia/Manila` - Philippines (PHT, UTC+8)
- `Asia/Singapore` - Singapore (SGT, UTC+8)
- `Asia/Tokyo` - Japan (JST, UTC+9)
- `UTC` - Coordinated Universal Time

**After changing timezone, reload the timer:**
```bash
sudo systemctl daemon-reload
sudo systemctl restart ansible-maintenance.timer
systemctl list-timers ansible-maintenance.timer
```

---

## Maintenance Playbook Details

The `maintenance.yml` playbook performs these steps on each server (one at a time):

1. **Update System**
   - Run `apt update`
   - Run `apt upgrade -y`
   - Clean up packages

2. **Stop Docker Containers**
   - List running containers
   - Stop all containers gracefully

3. **Reboot Server**
   - Reboot with 600s timeout
   - Wait for server to come back online

4. **Verify NFS Mount** (server2 only)
   - Check `/home/ubsysadmin2/mnt/synology/Media` exists
   - Verify Anime, Movies, and TVShow folders are accessible
   - List contents to confirm mount is working

5. **Start Docker Containers**
   - Start all containers
   - Wait 10 seconds for startup
   - Verify containers are running

6. **Report Results**
   - Display running container names
   - Show NFS verification status
   - Fail if issues detected

---

## Inventory Groups

```ini
[homelab]          # All homelab servers
[docker_hosts]     # Servers running Docker
[nfs_hosts]        # Servers with NFS mounts (server2)
[all_servers]      # All servers to maintain
```

---

## Troubleshooting

### Ansible Can't Connect
```bash
# Test SSH manually
ssh ubsysadmin1@10.0.0.104

# Check SSH key
ls -la ~/.ssh/

# Re-copy SSH key
ssh-copy-id ubsysadmin1@10.0.0.104
```

### Permission Denied (sudo)
```bash
# Verify passwordless sudo on target server
ssh ubsysadmin1@10.0.0.104
sudo whoami  # Should not ask for password
```

### Playbook Fails
```bash
# Run with verbose output
ansible-playbook maintenance.yml -vvv

# Check logs on control machine
sudo tail -f /var/log/ansible-maintenance.log
```

### Timer Not Running
```bash
# Check timer status
systemctl status ansible-maintenance.timer

# Check service logs
sudo journalctl -u ansible-maintenance.service --since "1 day ago"

# Manually trigger service
sudo systemctl start ansible-maintenance.service
```

### Docker Containers Don't Start
```bash
# Check Docker status on target
ansible docker_hosts -a "systemctl status docker"

# Check container logs
ssh ubsysadmin1@10.0.0.104 "docker logs container-name"
```

### NFS Mount Issues
```bash
# Check mount on server2
ansible server2 -a "mount | grep synology"

# Check NFS folders
ansible server2 -a "ls -la /home/ubsysadmin2/mnt/synology/Media"

# Test manually
ssh ubsysadmin2@10.0.0.105
ls /home/ubsysadmin2/mnt/synology/Media/Anime
```

---

## Updating Playbooks

### Make Changes Locally
```bash
# Edit files on your local machine
# Commit and push to GitHub
git add .
git commit -m "Updated maintenance playbook"
git push
```

### Pull Changes on Control Machine
```bash
cd ~/Infrastructure-Automation/Ansible
git pull
```

### Test Changes
```bash
ansible-playbook maintenance.yml --check
```

---

## Server Information

### Server1 (10.0.0.104)
- **User**: ubsysadmin1
- **Docker Containers**: 13
  - vaultwarden, forgejo, docmost, coder
  - nginx_proxy_manager, homepage
  - woodpecker-server, woodpecker-agent
  - portainer, redis, pgadmin, postgres, dockmon
- **NFS**: Not configured

### Server2 (10.0.0.105)
- **User**: ubsysadmin2
- **Docker Containers**: 7
  - bazarr, embyserver, radarr, sonarr
  - sabnzbd, ghost-app, mysql
- **NFS Mount**: `/home/ubsysadmin2/mnt/synology/Media`
  - Anime, Movies, TVShow folders

---

## Useful Commands

```bash
# Check all server uptimes
ansible all -a "uptime"

# Check disk space
ansible all -a "df -h"

# Check memory usage
ansible all -a "free -h"

# Restart specific service
ansible all -a "systemctl restart docker" --become

# Run command on specific group
ansible docker_hosts -a "docker stats --no-stream"

# List all Docker containers
ansible docker_hosts -a "docker ps -a"

# Check NFS mount
ansible nfs_hosts -a "mount | grep synology"
```

---

## Security Notes

- SSH keys are used for authentication (no passwords in playbooks)
- Passwordless sudo is configured only for automation users
- Control machine should have restricted access
- Consider using Ansible Vault for sensitive variables
- Regularly update control machine and Ansible

---

## Future Improvements

- [ ] Add notification system (email/webhook on failures)
- [ ] Add backup verification tasks
- [ ] Monitor disk space before updates
- [ ] Add rollback capability
- [ ] Implement Ansible Vault for secrets
- [ ] Add health check endpoints monitoring
- [ ] Create separate playbooks for different maintenance tasks

---

## License

[Your License Here]

## Author

[Your Name]

## Last Updated

[Date]