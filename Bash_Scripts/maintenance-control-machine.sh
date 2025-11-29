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