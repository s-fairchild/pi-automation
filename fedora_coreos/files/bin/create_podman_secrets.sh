#!/bin/bash

secret_dir=/var/container_secrets
readarray -d '' secret_files < <(find "$secret_dir" -name "*.secret" -print0)

for s in ${secret_files[@]}; do
    if [ -f "$s" ]; then
        if podman secret create "$(basename $s)" "$s"; then
            shred -zu "$s"
        else
            echo "$s not found, exiting..."
            exit 1
        fi
    fi
done
