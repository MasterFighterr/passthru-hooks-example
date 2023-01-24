#!/bin/bash

## Load VM variables
source "/etc/libvirt/hooks/qemu.d/name/vm-vars.conf"

## Set CPU governor to mode indicated by variable
CPU_COUNT=0
for file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
do
    echo $VM_ON_GOVERNOR > $file;
    echo "CPU $CPU_COUNT governor: $VM_ON_GOVERNOR";
    let CPU_COUNT+=1
done

## Set system power profile to performance
powerprofilesctl set $VM_ON_PWRPROFILE

sleep 1
