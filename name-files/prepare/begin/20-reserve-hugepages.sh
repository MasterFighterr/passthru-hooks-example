#!/bin/bash

## Load VM variables
source "/etc/libvirt/hooks/qemu.d/name/vm-vars.conf"

## Calculate number of hugepages to allocate from memory (in MB)
HUGEPAGES="$(($VM_MEMORY/$(($(grep Hugepagesize /proc/meminfo | awk '{print $2}')))))"

echo "Allocating hugepages at 2048 KiB per page..."
echo $HUGEPAGES > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
ALLOC_PAGES=$(cat /proc/sys/vm/nr_hugepages)


## If successful, notify user
if [ "$ALLOC_PAGES" -eq "$HUGEPAGES" ]
then
    echo "Succesfully allocated $ALLOC_PAGES / $HUGEPAGES pages!"
fi


## Drop caches to free up memory for hugepages if not successful
if [ "$ALLOC_PAGES" -ne "$HUGEPAGES" ]
then
    echo 3 > /proc/sys/vm/drop_caches
fi

## If not successful, try up to 10000 times to allocate
TRIES=0
while (( $ALLOC_PAGES != $HUGEPAGES && $TRIES < 1000 ))
do
    ## Defrag RAM then try to allocate pages again
    echo 1 > /proc/sys/vm/compact_memory
    echo $HUGEPAGES > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
    ALLOC_PAGES=$(cat /proc/sys/vm/nr_hugepages)
    ## If successful, notify user
    echo "Succesfully allocated $ALLOC_PAGES / $HUGEPAGES pages!"
    let TRIES+=1
done

## If still unable to allocate all requested pages, revert hugepages and quit
if [ "$ALLOC_PAGES" -ne "$HUGEPAGES" ]
then
    echo "Not able to allocate all hugepages. Reverting..."
    echo 0 > /proc/sys/vm/nr_hugepages
    exit 1
fi

sleep 1
