#!/bin/bash
secrets=(
    v4l2rtspserver
    v4l2rtspserver_url
    pihole
    motion_camera1
    motion_camera2
    motion_camera3
    plex
    graylog_root_password_sha2
    graylog
    v4l2rtspserver_camera1_url
    v4l2rtspserver_camera2_url
    v4l2rtspserver_camera3_url
)
secret_dir=/var/container_secrets

for s in ${secrets[@]}; do
    ds="${secret_dir}/${s}"
    if [ -f "$ds" ]; then
        if podman secret create "$s" "$ds"; then
            shred -zu "$ds"
        else
            echo "$ds not found, exiting..."
            exit 1
        fi
    fi
done
