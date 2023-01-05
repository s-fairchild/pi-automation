#!/bin/bash

main() {
    secret_archive=/var/container_secrets
    secrets="$(basename $secret_archive)"
    tar xvf /var/container_secrets || abort "failed to extract ${secret_archive}"
    readarray -d '' secret_files < <(find "$secrets" -name "*.secret" -print0)

    for s in ${secret_files[@]}; do
        if [ -f "$s" ]; then
            if podman secret create "$(basename $s)" "$s"; then
                shred -zu "$s"
            else
                abort "$s not found, exiting..."
            fi
        fi
    done

    cleanup
}

cleanup() {
    shred -zu "$secret_archive"
    shred -zu "${secrets}/*" 
    rm -rf "$secrets" 
}

#######################################
# abort echos a message and exits with code 1
#######################################
abort() {
    echo "${1}, Aborting."
    exit 1
}

main
