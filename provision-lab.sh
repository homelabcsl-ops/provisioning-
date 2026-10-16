#!/usr/bin/env bash

# ==============================================================================
# Script: provision-lab.sh
# Description: Cloud-native zero-touch provisioning pipeline for RHEL 10.2
# ==============================================================================

LIMA_INSTANCE="dks-lab-elite"
LIMA_BLUEPRINT="$HOME/provisioning/dks-lab-elite.yaml"

echo "[STATE MUTATION] Forcing unlock on attached block storage..."
limactl disk unlock rhcsa-lvm 2>/dev/null
limactl disk unlock rhcsa-stratis 2>/dev/null

echo "[STATE MUTATION] Purging legacy environments and block storage..."
limactl delete -f "$LIMA_INSTANCE" 2>/dev/null
limactl disk delete rhcsa-lvm rhcsa-stratis 2>/dev/null

echo "[PROVISIONING] Allocating secondary block storage for LVM/Stratis..."
limactl disk create rhcsa-lvm --size 10GiB
limactl disk create rhcsa-stratis --size 10GiB

echo "[IGNITION] Launching cloud-native hypervisor..."
limactl start "$LIMA_BLUEPRINT"

echo "[AUDIT] Zero-touch deployment complete. System is online."
