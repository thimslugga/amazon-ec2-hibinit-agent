#!/bin/sh

PATH=/sbin:/bin:/usr/bin
failed='false'

# Hibernation selects the swapfile with highest priority. Since there may be
# other swapfiles configured, ensure /swap is selected as hibernation
# target by setting to maximum priority.
swap_priority=32767

hibernate() {
        # Enable swap file and then hibernate
        swapon --priority=$swap_priority /swap && systemctl hibernate
        if [ $? -ne 0 ]; then
            logger "Hibernation failed. Sleep for 2-min before retry attempt."
            failed='true'
            swapoff /swap
            sleep 120
        else
            failed='false'
        fi
}

case "$2" in
    SLPB|SBTN)
        # The iteration had been placed here to add retry logic to hibernation 
        # in case of failures and to avoid force stop of instances after 20min
        for i in 1 2 3; do
          hibernate
          if [ $failed == 'false' ]; then
            break
          fi
       done
       ;;
    *)
        logger "ACPI action undefined: $2" ;;
esac
