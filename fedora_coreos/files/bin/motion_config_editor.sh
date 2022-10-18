#!/bin/bash -x
tmp_dir="/mnt/temp_config"
if [ -n "$1" ] && [ -d "$1" ]; then
    tmp_dir="$1"
elif [ ! -d "$1" ] && [ -n "$1" ]; then
    echo "$1 must be an existing directory"
    exit 1
fi
cp /mnt/motion/*.conf "$tmp_dir"

secrets=(
    "$motion_camera1"
    "$motion_camera2"
    "$motion_camera3"
)

i=1
for s in ${secrets[@]}; do
    if ! sed -i "s/PLACEHOLDER/$s/" "${tmp_dir}/camera${i}.conf"; then
        echo "Failed to replace placeholder"
        exit 1
    fi
    ((i++))
done
