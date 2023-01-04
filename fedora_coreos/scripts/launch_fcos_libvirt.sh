#!/bin/bash -x

IGNITION_CONFIG="${HOME}/src/github/pi-automation/fedora_coreos/kore_libvirt.ign"
IGNITION_FILE="${1:?Ignition file must be provided}"
IGNITION_CONFIG="/var/lib/libvirt/filesystems/$(basename ${IGNITION_FILE})"
IMAGE="${2:-/var/lib/libvirt/images/pool/fedora-coreos-37.20221106.3.0-qemu.x86_64.qcow2}"
VM_NAME="fcos-test-01"
VCPUS="4"
RAM_MB="4096"
STREAM="stable"
DISK_GB="20"
RAID_DISK_GB="10"

sudo cp "$IGNITION_FILE" "$IGNITION_CONFIG"
sudo chcon --verbose --type svirt_home_t "$IGNITION_CONFIG"
chcon --verbose --type virt_image_t "$IMAGE"
sudo chown qemu: "$IGNITION_CONFIG"
sudo chown qemu: "$IMAGE"

# --tpm backend.type=emulator,backend.version=2.0,model=tpm-tis \
# --boot menu=on,useserial=on \
virt-install --connect="qemu:///system" --name="${VM_NAME}" --vcpus="${VCPUS}" --memory="${RAM_MB}" \
    --os-variant="fedora-coreos-$STREAM" \
    --import \
    --graphics=spice \
    --disk="size=${DISK_GB},backing_store=${IMAGE}" \
    --disk="size=${RAID_DISK_GB}" \
    --disk="size=${RAID_DISK_GB}" \
    --disk="size=${RAID_DISK_GB}" \
    --disk="size=${RAID_DISK_GB}" \
    --disk="size=${RAID_DISK_GB}" \
    --network network=default \
    --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=${IGNITION_CONFIG}"

# sudo virsh destroy fcos-test-01 && sudo virsh undefine --remove-all-storage fcos-test-01
