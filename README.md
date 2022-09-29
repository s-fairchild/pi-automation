# How to run these playbooks

## Purpose

Configure and manage Raspberry Pi headless servers
Primarily this project helps me to

- Deploy a fresh aarch64 install on a Raspberry Pi 4
  - Run motion server that collects rtsp feeds
  - Saves motion videos from those feeds to `/data/motion` on a Mobus 5 disk USB linux software raid (either linux raid or btrfs multiple device)
  - Deploy and modify the rtsp servers running raspbian at the moment. Arch Linux Arm dropped armv6 support unfortunately

## Fedora Server 37

Install image to sdcard with `arm-image-installer`

Update `sdcard="sdx"` with your device

```bash
sdcard="/dev/sdx"
sudo arm-image-installer --image=Fedora-Server-37_Beta-1.5.aarch64.raw.xz \
  --target=rpi4 \
  --media="$sdcard" \
  --norootpass \
  --resizefs \
  --showboot \
  --args "coherent_pool=6M smsc95xx.turbo_mode=N" \
  --addkey ~/.ssh/id_rsa.pub \
  --addconsole
```

## Arch Linux Arm

[ArchLinuxArm Installation Guide](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4)

- rpi-linux Raspberry Pi Foundation kernel and kernel headers
- latest opensource software videocore driver
- motion camera server accepting RTSP feeds
- External usb storage for `/data` directory. Mine is configured as a Linux software raid5 with 1 hotspare
- External drive for `/backup` to backup raid array to, within the same Mobus storage enclosure as raid 5
- Emby media server
- PWM fan controlled via [my software driver written in Go](https://github.com/s-fairchild/pwmfan-go)
  - ICE Tower Fan

## First boot

Run `first_boot_populate-pacman-keys.sh` directly on rpi via ssh or serial terminal to setup the alarm keys and install `python` to run playbooks.

- Example to run from interactive ssh session

```bash
scp first_boot_populate-pacman-keys.sh alarm@<ipaddress>:
ssh alarm@<ipaddress>
su -c ./first_boot_populate-pacman-keys.sh
```

- Example to run script remotely

```bash
scp first_boot_populate-pacman-keys.sh alarm@<ipaddress>:
# Quickly enter root password: root
# Note the password will be shown in terminal
ssh alarm@rpi4 'bash -s su -c' < first_boot_populate-pacman-keys.sh
```

## Running playbooks

### First boot setup for Arch Linux Arm host

- Enter the default alarm(alarm) password, then root(root) password when prompted

```bash
ansible-playbook 1-customize_secure_users-playbook.yml -u alarm -k -K --become-method su
```

### Next Install packages with `install_packages-playbook.yml`

- extra var `backup_dir` is required to create the backup subfolder. I'm using my controller hostname that I'll be backing up from

```bash
ansible-playbook setup_fstab-playbook.yml -e "backup_dir=$(hostname)"
```

### Add mounts to fstab with `setup_fstab-playbook.yml`

```bash
ansible-playbook setup_fstab-playbook.yml
```

### Configure Motion Server

- the 3rd rtsp name requires an extra variable
  - This will be modified later, I've hardcoded the first 3 names but they all need to be customizable

```bash
ansible-playbook motion_server_config-playbook.yml -e "rtsp3name=<your server name>"
```

### Other usage examples

- Running setup a second time after the alarm user has been removed
  - Don't use `-u alarm -k -K` now that we have an ssh key for authentication and password-less sudo for our current user

```bash
ansible-playbook 1-customize_secure_users_playbook.yml
```

- Update shell env files only
  - use shell-env tag with `-t shell-env`

```bash
ansible-playbook 1-customize_secure_users_playbook.yml -t shell-env
```

- Setup rtsp server host

```bash
ansible-playbook rtspserver-debian-playbook.yml -e "host=rpi3" -e "url=my_rtspserver_url"
```

- Update configuration only

```bash
ansible-playbook rtspserver-debian-playbook.yml -e "host=rpi3" -e "url=my_rtspserver_url" -t update-config
```

## How to's

enable early firmware UART

```bash
sed -i -e "s/BOOT_UART=0/BOOT_UART=1/" bootcode.bin
```

## TODO Items

- Setup firewalld playbook
- Cleanup variable placements
  - Set common configurable options in `env.yml` for others to replace when using this project
- Set all rtsp server names to variables
  - Configure more or less rtsp servers to be specified using a loop
- Collect mount UUIDs from host rather than hardcoding
- Switch `config.txt` to j2 template for customization when installing rpi kernel
- Configure /dev/vchiq with permissions: `crw-rw---- 1 root video 10, 125 Aug  9 23:29 /dev/vchiq` to allow video group to run `vcgencmd`
- Create systemd one shot service to run `tvservice -o` for less power usage by disabling HDMI interface