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

- First boot setup for Arch Linux Arm host
- Enter the default alarm(alarm) password, then root(root) password when prompted

```bash
ansible-playbook -u alarm --become-method su -k -K -i inventory.yml 1-customize_secure_users_playbook.yml
```

- Running setup a second time after the alarm user has been removed
  - Use `--become-method sudo` now that root user has been locked
  - Don't use `-u alarm -k -K` now that we have an ssh key for authentication and password-less sudo for our current user

```bash
ansible-playbook --become-method sudo -i inventory.yml 1-customize_secure_users_playbook.yml
```

- Update shell env files only
  - use shell-env tag with `-t shell-env`

```bash
ansible-playbook 1-customize_secure_users_playbook.yml --become-method sudo -i inventory.yml -t shell-env
```

- Setup rtsp server host

```bash
ansible-playbook rtspserver-debian-playbook.yml -i inventory.yml -e "host=rpi3" -e "url=my_rtspserver_url"
```

- Update configuration only

```bash
ansible-playbook rtspserver-debian-playbook.yml -i inventory.yml -e "host=rpi3" -e "url=my_rtspserver_url" -t update-config
```
