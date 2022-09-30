#!/bin/bash

main() {

    if [[ -n $1 ]]; then
        usbIds="$(findIds "HD Camera Manufacturer")"
    else
        usbIds="$(findIds "$1")"
        shift
    fi
    IFS=':' read -ra ids <<< "$usbIds"

    if [ "$1" == "vendor" ]; then
        echo -n "${ids[0]}"
    elif [ "$1" == "product" ]; then
        echo -n "${ids[1]}"
    else
        echo -n "${ids[@]}"
    fi
}

# findIds finds accepts 1) arguement which is the USB device name to search for
# The USB vendor and product IDs are returned with a colon : seperator character
findIds() {

    lsusb | grep "$1" | cut -d ' ' -f 6
}

main "$@"