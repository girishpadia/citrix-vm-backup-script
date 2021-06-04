#!/bin/bash
export XE_EXTRA_ARGS="server=<servername>,port=<port>,username=<username>,password=<password>"
# Change path variable value to appropriate path you want save backup.
PATH="/mnt"
DT=`date +%F`
echo $DT
# Create a file named "vm-list.txt" with the name of each VMs you want to take backup, each in new line
file="$PATH/vm-list.txt"
while IFS= read -r VMNAME
do
        #VMNAME="HSD1"
        echo $VMNAME
        # get uuid of a VM
        VMID=`xe vm-list name-label=$VMNAME power-state=running | head -1 | cut -d ":" -f 2`
        VMID=`echo $VMID | sed 's/ *$//g'`
        echo $VMID
        ## Create a snapshot of the VM by its uuid
        VMSNAPSHOTID=`xe vm-snapshot new-name-label="$VMNAME-$DT" vm=$VMID`
        echo $VMSNAPSHOTID
        ## Export the snapshot to a file.
        xe snapshot-export-to-template snapshot-uuid=$VMSNAPSHOTID filename=$PATH/$VMNAME-$DT
        ## Destroy the snapshot
        xe snapshot-destroy snapshot-uuid=$VMSNAPSHOTID
done <"$file"
