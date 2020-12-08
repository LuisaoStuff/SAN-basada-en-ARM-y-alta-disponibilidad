#!/bin/bash

sync=$(drbdadm status | egrep -o 'peer-disk:.*' | cut -d ":" -f 2)

while [ "$sync" != "UpToDate" ]; do

	sync=$(drbdadm status | egrep -o 'peer-disk:.*' | cut -d ":" -f 2)
        percentage=$(drbdadm status | egrep -o '[0-9]+\.[0-9]+')
        echo "  $percentage% syncronized"
        sleep 1

done

echo "All syncronized!"

