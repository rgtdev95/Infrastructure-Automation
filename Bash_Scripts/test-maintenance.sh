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