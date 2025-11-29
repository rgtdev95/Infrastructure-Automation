#!/bin/bash

# Maintenance script for control machine - TEST VERSION
# Performs dry-run without actual upgrade or reboot

LOG_DIR="/home/scriptadmin/logs"
LOG_FILE="$LOG_DIR/control-machine-maintenance.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to log with timestamp
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