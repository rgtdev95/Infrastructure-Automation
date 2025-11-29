Here's a simplified README for the control machine maintenance:

```bash
nano ~/Infrastructure-Automation/Bash_Scripts/README.md
```

Paste this:

```markdown
# Control Machine Maintenance Scripts

Automated maintenance scripts for the Ansible control machine.

---

## Overview

- **Location**: `/home/scriptadmin/Infrastructure-Automation/Bash_Scripts/`
- **Logs**: `/home/scriptadmin/logs/control-machine-maintenance.log`
- **Schedule**: Every Sunday at 4:00 AM (Asia/Manila timezone)

---

## Scripts

### 1. `maintenance-control-machine.sh`
Main maintenance script that performs:
- `apt update` - Update package lists
- `apt upgrade -y` - Upgrade all packages
- `apt autoremove -y` - Remove unused packages
- `apt autoclean -y` - Clean package cache
- Reboot system after 60 seconds

### 2. `test-maintenance.sh`
Test version that performs dry-run without actual upgrade or reboot.

---

## Setup (Already Configured)

### Scripts are executable:
```bash
chmod +x maintenance-control-machine.sh
chmod +x test-maintenance.sh
```

### Cron job is configured:
```bash
# View cron jobs
crontab -l

# Edit cron jobs
crontab -e
```

**Current cron configuration:**
```
# Control machine weekly maintenance - Every Sunday at 4:00 AM Manila Time
0 4 * * 0 /home/scriptadmin/Infrastructure-Automation/Bash_Scripts/maintenance-control-machine.sh
```

---

## Usage

### Run Test (No Reboot)
```bash
cd ~/Infrastructure-Automation/Bash_Scripts
./test-maintenance.sh
```

### Run Full Maintenance (Will Reboot!)
```bash
./maintenance-control-machine.sh
```
**Warning:** System will reboot after 60 seconds!

### View Logs
```bash
# View entire log
cat /home/scriptadmin/logs/control-machine-maintenance.log

# View last 20 lines
tail -20 /home/scriptadmin/logs/control-machine-maintenance.log

# Watch in real-time
tail -f /home/scriptadmin/logs/control-machine-maintenance.log
```

### Check Cron Execution
```bash
# Check if cron ran the script
sudo grep CRON /var/log/syslog | grep maintenance

# Check recent cron activity
sudo grep CRON /var/log/syslog | tail -20
```

---

## Cron Schedule Configuration

### Edit Schedule
```bash
crontab -e
```

### Common Schedules

| Schedule | Cron Expression | Description |
|----------|----------------|-------------|
| Every Sunday 4 AM | `0 4 * * 0` | Current setting |
| Every Saturday 2 AM | `0 2 * * 6` | Saturday maintenance |
| Daily 3 AM | `0 3 * * *` | Every day |
| First of month 3 AM | `0 3 1 * *` | Monthly |
| Every Monday 1 AM | `0 1 * * 1` | Weekly Monday |

### Cron Format
```
* * * * * command
│ │ │ │ │
│ │ │ │ └─── Day of week (0-7, Sunday = 0 or 7)
│ │ │ └───── Month (1-12)
│ │ └─────── Day of month (1-31)
│ └───────── Hour (0-23)
└─────────── Minute (0-59)
```

### After Changing Schedule
```bash
# Verify changes
crontab -l

# Check cron service
sudo systemctl status cron
```

---

## Timezone

System timezone: **Asia/Manila (PHT, UTC+8)**

### Check Timezone
```bash
timedatectl
```

### Change Timezone (if needed)
```bash
sudo timedatectl set-timezone Asia/Manila
```

All cron jobs run in the system's local timezone.

---

## Maintenance Schedule Overview

| Time | Server | Method |
|------|--------|--------|
| 3:00 AM Sunday | server1 & server2 | Ansible (systemd timer) |
| 4:00 AM Sunday | control-machine | Bash script (cron) |

Control machine maintenance runs 1 hour after other servers to avoid conflicts.

---

## Troubleshooting

### Cron Not Running

**Check cron service:**
```bash
sudo systemctl status cron
```

**Start/enable cron:**
```bash
sudo systemctl start cron
sudo systemctl enable cron
```

### Script Errors

**Test manually:**
```bash
./test-maintenance.sh
```

**Check script permissions:**
```bash
ls -l maintenance-control-machine.sh
# Should show: -rwxr-xr-x
```

**Fix permissions if needed:**
```bash
chmod +x maintenance-control-machine.sh
```

### Check Logs

**Maintenance log:**
```bash
cat /home/scriptadmin/logs/control-machine-maintenance.log
```

**System log:**
```bash
sudo journalctl -u cron -n 50
```

**Cron execution log:**
```bash
sudo grep "maintenance-control-machine" /var/log/syslog
```

### Sudo Password Required

The script uses `sudo` commands. Make sure passwordless sudo is configured:

```bash
sudo visudo
```

Verify this line exists:
```
scriptadmin ALL=(ALL) NOPASSWD: ALL
```

---

## Testing Cron Job

To test without waiting for Sunday:

### 1. Edit crontab
```bash
crontab -e
```

### 2. Set to run in 2 minutes
Example: If current time is 10:45, set to 10:47:
```bash
47 10 * * * /home/scriptadmin/Infrastructure-Automation/Bash_Scripts/maintenance-control-machine.sh
```

### 3. Watch the logs
```bash
tail -f /home/scriptadmin/logs/control-machine-maintenance.log
```

### 4. Restore original schedule
```bash
crontab -e
```
Change back to:
```bash
0 4 * * 0 /home/scriptadmin/Infrastructure-Automation/Bash_Scripts/maintenance-control-machine.sh
```

**Warning:** Test will actually reboot the machine!

---

## Quick Reference

```bash
# View cron schedule
crontab -l

# Edit cron schedule  
crontab -e

# Test script (no reboot)
./test-maintenance.sh

# View logs
tail -20 /home/scriptadmin/logs/control-machine-maintenance.log

# Check cron activity
sudo grep CRON /var/log/syslog | tail -20

# Check timezone
timedatectl
```

---

## Security Notes

- Script runs with user privileges, uses `sudo` for system commands
- Passwordless sudo configured for automation
- Logs stored in user's home directory
- 60-second delay before reboot allows for manual cancellation if needed

---

## Last Updated

November 29, 2024
```

Save and exit (Ctrl+X, Y, Enter).

---

## Now Commit to Git

```bash
cd ~/Infrastructure-Automation
git add Bash_Scripts/README.md
git add Bash_Scripts/maintenance-control-machine.sh
git add Bash_Scripts/test-maintenance.sh
git commit -m "Add control machine maintenance scripts and documentation"
git push
```

---

This simplified README includes:
✅ Overview and file locations
✅ What each script does
✅ How to use them
✅ Complete cron configuration with examples
✅ Troubleshooting guide
✅ Quick reference commands

All in one easy-to-follow document! 🎯