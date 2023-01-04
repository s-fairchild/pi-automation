#

### Purpose

Deploy a self hosted Fedora CoreOS server to serve as
  * Motion camera server
    * Records rtsp streams to local raid
  * v4l2rtspserver
    * Provides rtsp stream for a local camera. This allows remote viewing via an rtsp client app, and recording with `motion`
  * Pihole
    * Sinkhole/Ad blocking DNS server
  * Unbound recursive DNS server
    * Upstream DNS for pihole
    * Note: Other upstream DNS servers such as Google's may be used if unbound causes too much latency
  * Emby/Plex media server
  * Graylog logging server
    * Log collection and visualization
    * Requires:
      * MongoDB
      * Elasticsearch 7.10.2
  * Local beat metric shippers
  * OpenVPN/Wireguard
    * Remote network access, mainly for DNS and Cameras
  * nginx reverse proxy server (in progress)
    * Provide endpoints for all web based applications via port 80/443
  * Gollum git backed wiki
    * Notes

### Files and Directories

1. `kore_common.bu`
  * Primary butane file containing all common configurations across environments
1. `kore_libvirt.bu`
  * Configuration for libvirt vm
1. `kore_btrfs_raid10.bu`
  * btrfs raid configuration used in bare metal production deployment
1. `kore_md_raid5.bu`
  * Linux software md raid config
1. `kore_production.bu`
  * Used to make an easy selection from hardware butane configs
  * Also used to hardcode UUID for filesystem reuse
1. `files/`
  * Directory containing all files used by butane to embed in ignition file for deployed system use
1. `isos/`
  * Directory containing custom created modified iso images with embedded ignition files
1. `scripts/`
  * Directory contains helper scripts for deploying/testing

### How to use this repository

1. Test in libvirt vm
  * Testing configuration in a libvirt vm
  ```bash
  make libvirt
  ```
1. Deploy to bare metal with iso
  * Production bare metal iso creation
  ```bash
  # Download latest iso image
  podman run --security-opt label=disable --pull=always --rm -v .:/data -w /data \
    quay.io/coreos/coreos-installer:release download -s stable -p metal -f iso

  # Move downloaded iso file to isos/
  # Example filename, your's will be a newer version
  mv ./fedora-coreos-37.20221106.3.0-live.x86_64.iso isos/fedora-coreos-37.20221106.3.0-live.x86_64.iso

  # Wipe destination USB drive
  wipefs -a /dev/sdX

  # This generates a new ignition file and creates a new iso file from the default
  ./scripts/create_custom_iso.sh -i isos/fedora-coreos-37.20221106.3.0-live.x86_64.iso -d /dev/nvme0n1

  # A new created custom ISO file should exist with custom_date_ prefixed
  ls -l isos/custom_2023-01-04_fedora-coreos-37.20221106.3.0-live.x86_64.iso

  # Write the image to your installation media previously wiped
  sudo dd if=isos/custom_2023-01-04_fedora-coreos-37.20221106.3.0-live.x86_64.iso of=/dev/sdc status=progress bs=1M
  ```
1. Insert installation media into bare metal server and boot to it
  * Server will boot once into the live installer image
  * Once the installer image has written to the destination device
  * Note: **REMOVE THE INSTALLATION MEDIA** to prevent an install loop

### References

1. [Fedora CoreOS Documentation](https://docs.fedoraproject.org/en-US/fedora-coreos/)

1. `create_custom_iso.sh` usage
```bash
USAGE:
./scripts/create_custom_iso.sh -i <ISO_FILE> -d <SERVER_BOOT_DRIVE>

ARGS:
    -i          ISO file downloaded with coreos-installer
    -d          Destination device file name to install Fedora CoreOS to when booting custom ISO image
    -h          This help message

EXAMPLES:
    ./scripts/create_custom_iso.sh -i isos/fedora-coreos-37.20221106.3.0-live.x86_64.iso -d /dev/nvme0n1
```
