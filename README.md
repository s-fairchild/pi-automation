# How to run these playbooks

## Purpose

Configure and manage Raspberry Pi headless servers

## Arch Linux Arm

[ArchLinuxArm Installation Guide](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4)

- upstream aarch64 kernel
- raspberry pi firmware
- latest opensource software videocore driver
- motion camera server accepting RTSP feeds
- btrfs raid 10 for video files
- Emby media server
- PWM fan controlled via kernel driver
  - ICE Tower Fan in my case

## Running playbooks

- Enter the default alarm(alarm) password, then root(root) password when prompted

```bash
ansible-playbook -u alarm --become-method su -k -K -i inventory.yml secure_fresh_install.yml
```

- Setup rtsp server host

```bash
ansible-playbook -i inventory.yml -e "host=rpi3" -e "url=my_rtspserver_url" rtspserver-debian-playbook.yml 
```

- Update configuration only

```bash
ansible-playbook -i inventory.yml -e "host=rpi3" -e "url=my_rtspserver_url" -t update-config rtspserver-debian-playbook.yml 
```
