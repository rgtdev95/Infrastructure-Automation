Perfect! Let's create a bash script for the control machine's maintenance and schedule it with cron.

## Step 1: Create the Maintenance Script

```bash
nano ~/maintenance-control-machine.sh
```

Paste this:

```bash
#!/bin/bash

# Maintenance script for control machine
# Performs system updates and reboot

LOG_FILE="/var/log/control-machine-maintenance.log"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "========================================="
log "Starting Control Machine Maintenance"
log "========================================="

# Update package list
log "Updating package list..."
sudo apt update 2>&1 | tee -a "$LOG_FILE"

# Upgrade packages
log "Upgrading packages..."
sudo apt upgrade -y 2>&1 | tee -a "$LOG_FILE"

# Auto remove unused packages
log "Removing unused packages..."
sudo apt autoremove -y 2>&1 | tee -a "$LOG_FILE"

# Clean up
log "Cleaning up package cache..."
sudo apt autoclean -y 2>&1 | tee -a "$LOG_FILE"

log "Updates completed successfully"
log "System will reboot in 60 seconds..."
log "========================================="

# Reboot after 60 seconds
sleep 60
sudo reboot
```

Save and exit (Ctrl+X, Y, Enter).

## Step 2: Make the Script Executable

```bash
chmod +x ~/maintenance-control-machine.sh
```

## Step 3: Test the Script (Without Reboot)

First, let's test without the reboot. Create a test version:

```bash
nano ~/test-maintenance.sh
```

Paste (same as above but without the reboot):

```bash
#!/bin/bash

LOG_FILE="/var/log/control-machine-maintenance.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "========================================="
log "Testing Control Machine Maintenance"
log "========================================="

log "Updating package list..."
sudo apt update 2>&1 | tee -a "$LOG_FILE"

log "Checking for upgrades (dry run)..."
sudo apt list --upgradable 2>&1 | tee -a "$LOG_FILE"

log "Test completed (no actual upgrade or reboot)"
log "========================================="
```

Make it executable and run:

```bash
chmod +x ~/test-maintenance.sh
./test-maintenance.sh
```

## Step 4: Set Up Cron Job

Open crontab:

```bash
crontab -e
```

If asked, choose your preferred editor (nano is easiest).

Add this line at the end (runs every Sunday at 4:00 AM Manila time):

```bash
# Control machine weekly maintenance - Sunday 4:00 AM
0 4 * * 0 /home/scriptadmin/maintenance-control-machine.sh
```

**Note:** We schedule it at 4 AM, which is 1 hour after the other servers finish (they run at 3 AM).

Save and exit (Ctrl+X, Y, Enter in nano).

## Step 5: Verify Cron Job

```bash
crontab -l
```

You should see your cron job listed.

## Step 6: Check Cron Logs

Cron logs to syslog. To see when it runs:

```bash
sudo grep CRON /var/log/syslog | tail -20
```

Or check maintenance logs:

```bash
sudo tail -f /var/log/control-machine-maintenance.log
```

---

## Cron Schedule Examples

If you want different timing, here are examples:

```bash
# Every Sunday at 4:00 AM
0 4 * * 0 /home/scriptadmin/maintenance-control-machine.sh

# Every Saturday at 2:00 AM
0 2 * * 6 /home/scriptadmin/maintenance-control-machine.sh

# Every day at 3:00 AM
0 3 * * * /home/scriptadmin/maintenance-control-machine.sh

# First day of every month at 3:00 AM
0 3 1 * * /home/scriptadmin/maintenance-control-machine.sh

# Every Monday at 1:00 AM
0 1 * * 1 /home/scriptadmin/maintenance-control-machine.sh
```

**Cron format:**
```
* * * * * command
│ │ │ │ │
│ │ │ │ └─── Day of week (0-7, 0 and 7 = Sunday)
│ │ │ └───── Month (1-12)
│ │ └─────── Day of month (1-31)
│ └───────── Hour (0-23)
└─────────── Minute (0-59)
```

---

## Test Manually

To test the script without waiting for cron:

```bash
~/maintenance-control-machine.sh
```

**Warning:** This will actually reboot the machine after 60 seconds!

---

## Update README with Control Machine Maintenance

```bash
nano ~/Infrastructure-Automation/Ansible/README.md
```

Add this section before "Troubleshooting":

```markdown
---

## Control Machine Maintenance

The control machine itself also needs regular maintenance.

### Bash Script Setup

**1. The maintenance script is located at:**
```bash
~/maintenance-control-machine.sh
```

**2. What it does:**
- Updates package list (`apt update`)
- Upgrades all packages (`apt upgrade -y`)
- Removes unused packages (`apt autoremove -y`)
- Cleans package cache (`apt autoclean -y`)
- Reboots the system after 60 seconds
- Logs everything to `/var/log/control-machine-maintenance.log`

**3. Scheduled via cron:**
```bash
# View cron jobs
crontab -l

# Edit cron jobs
crontab -e
```

**Current schedule:** Every Sunday at 4:00 AM (1 hour after other servers)

```
0 4 * * 0 /home/scriptadmin/maintenance-control-machine.sh
```

### Manual Execution

**Test without reboot:**
```bash
~/test-maintenance.sh
```

**Run full maintenance (will reboot!):**
```bash
~/maintenance-control-machine.sh
```

### View Logs

```bash
# View maintenance log
sudo tail -f /var/log/control-machine-maintenance.log

# View cron execution log
sudo grep CRON /var/log/syslog | tail -20
```

### Change Schedule

```bash
crontab -e
```

Modify the timing as needed. See cron format examples in the script comments.

---
```

Save and commit:

```bash
cd ~/Infrastructure-Automation/Ansible
git add README.md
git commit -m "Add control machine maintenance documentation"
git push
```

---

## Summary of Schedule

- **3:00 AM Sunday** - Server1 and Server2 maintenance (via Ansible)
- **4:00 AM Sunday** - Control machine maintenance (via cron)

This gives the control machine time to finish managing the other servers before it reboots itself!

Want to test the script now? (I recommend testing `test-maintenance.sh` first!)