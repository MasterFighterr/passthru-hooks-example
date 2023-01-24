#!/bin/bash

## Load VM variables
source "/etc/libvirt/hooks/qemu.d/name/vm-vars.conf"

## Isolate CPU cores as per set variable
systemctl set-property --runtime -- user.slice AllowedCPUs=$VM_ISOLATED_CPUS
systemctl set-property --runtime -- system.slice AllowedCPUs=$VM_ISOLATED_CPUS
systemctl set-property --runtime -- init.scope AllowedCPUs=$VM_ISOLATED_CPUS

sleep 1
