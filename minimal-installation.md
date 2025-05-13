# Arch Linux Minimal Installation Guide

This document describes my prefered steps to install minimalistic Arch Linux on UEFI using the Btrfs file system and disk encryption with LUKS over whole disk (`/boot` included). Because of it we can't use `systemd-boot` so `grub` was picked.

Boot into `archiso`.

## Disk Preparation

Choose a disk to install on, and run `fdisk` or any other alternative (shortcuts later could be different). `<disk>` is disk you choose to install on, for example `/dev/vda` for virtual machine disk.

```bash
fdisk /dev/vda <disk>
```

Set GPT partition table (`g`). Create new EFI partition (`n`) on the default start of the disc, with size around `+512M`. Set partition type (`t`) to EFI System (`1`). Create BTRFS partition, can be set to rest of the disk, because all other partitions can be subvolume of BTRFS. Type should be already Linux Filesystem (`20`). Write changes (`w`).

## Disk Formating and encryption

Format EFI partition, called `<disk>1` (eg. `/dev/vda1`)

```bash
mkfs.fat -F 32 <disk>1
```

Setup encryption for rest of the BTRFS disk partition `<disk>2` (eg. `/dev/vda2`). We have to use PBKDF2 encryption, because GRUB cant decrypt LUKS2 default encryption algorithm.

```bash
cryptsetup luksFormat --pbkdf=pbkdf2 <disk>2
```

And map decrypted disc into mapper (eg. `/dev/mapper/root`)

```bash
cryptsetup luksOpen <disk>2 root
```
Format and mount decrypted disk. Create BTRFS subvolumes, we need `@var_log` to be able read logs after rollback, `@.snapshots` as snapshot storage, `@swap` for swapfile (skip all related instructions if you don't want to use swapfile). I also create `@home` subvolume.

```bash
mkfs.btrfs /dev/mapper/root
mount /dev/mapper/root /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@swap
btrfs subvolume create /mnt/@var_log
btrfs subvolume create /mnt/@.snapshots
btrfs filesystem mkswapfile --size 16g --uuid clear /mnt/@swap/swapfile
umount /mnt
```

After unmount whole block disk, we mount into BTRFS subvolumes, and create whole system storage system. Omit `ssd` when not on ssd disk. Also mount whole btrfs disk (`subvolid=5`) at `/.btrfsroot` to enable rollbacks.

```bash
mount -o noatime,ssd,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/mapper/root /mnt
mount --mkdir -o noatime,ssd,compress=zstd,space_cache=v2,discard=async,subvol=@home /dev/mapper/root /mnt/home
mount --mkdir -o noatime,ssd,compress=zstd,space_cache=v2,discard=async,subvol=@swap /dev/mapper/root /mnt/swap
mount --mkdir -o noatime,ssd,compress=zstd,space_cache=v2,discard=async,subvol=@var_log /dev/mapper/root /mnt/var/log
mount --mkdir -o noatime,ssd,compress=zstd,space_cache=v2,discard=async,subvol=@.snapshots /dev/mapper/root /mnt/.snapshots
mount --mkdir -o noatime,ssd,compress=zstd,space_cache=v2,discard=async,subvolid=5 /dev/mapper/root /mnt/.btrfsroot
swapon /mnt/swap/swapfile
mount --mkdir /dev/vda1 /mnt/efi
```

## Install base system

First setup `pacman` mirrors

```bash
reflector -c Czechia -a 12 --sort rate --save /etc/pacman.d/mirrorlist
```

Install some basic packages. Change `vim` to your prefered text editor. `dhcpcd` is for DHCP network setting.

```bash
pacstrap /mnt base linux linux-firmware grub efibootmgr dhcpcd sudo vim
```

Create `fstab` of your system.

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

`chroot` into your system.

```bash
arch-chroot /mnt
```

## Configure system

Set timezone and reset clocks

```bash
ln -sf /usr/share/zoneinfo/Europe/Prague /etc/localtime
hwclock --systohc
```

Set locales

```bash
vim /etc/locale.gen
```

and uncomment preffered locales, for example (`en_US.UTF-8` and `cs_CZ.UTF-8`). Then re-generate locales and set preffered one as default

```bash
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

Set hostname

```bash
echo "arch" > /etc/hostname
```

Create default console configuration file (empty file)

```bash
touch /etc/vconsole.conf
```

Enable DHCP

```bash
systemctl enable dhcpcd.service
```

Setup `initramfs`

```bash
vim /etc/mkinitcpio.conf
```

Add btrfs into modules (`MODULES=(btrfs)`) and encryption into hooks (should be between `block` and `filesystems` - `HOOKS=(... block encrypt filesystems ...)`). Then generate `initramfs`

```bash
mkinitcpio -p linux
```

Set `root` password, then lock it for login (we will create another admin user)

```bash
passwd
passwd -l root
```

Then create admin user

```bash
useradd -m -g users -G wheel <username>
passwd <username>
```

and allow `wheel` group in `sudoer`

```bash
visudo
```

and uncoment `%wheel ALL=(ALL ALL) ALL` line.

## Configure bootloader

After encrypting `/boot`, we would be prompted about disk password twice, once before `initramfs` load, and then after system startup. This can be reduced to one prompt by passing key into `initramfs`. Create new random key

```bash
dd bs=512 count=4 if=/dev/random iflag=fullblock | install -m 0600 /dev/stdin /etc/cryptsetup-keys.d/root.key
```

and setup LUKS to accept it

```bash
cryptsetup luksAddKey /dev/vda2 /etc/cryptsetup-keys.d/root.key
```

Add key to `initramfs`

```bash
vim /etc/mkinitcpio.conf
```

and edit files, set key file there (`FILES=(/etc/cryptsetup-keys.d/root.key)`). And re-generate

```bash
mkinitcpio -p linux
```

Edit grub config to add modules for encrypted disk. Edit

```bash
vim /etc/default/grub
```

and allow

```bash
GRUB_ENABLE_CRYPTODISK=y
```

Install GRUB splited between `/efi` and `/boot`  partitions.

```bash
grub-install --target=x86_64-efi --efi-directory=/efi --boot-directory=/boot --bootloader-id=GRUB --modules=luks /dev/mapper/root
```

Configure GRUB to decrypt BTRFS partition (must set UUID of whole BTRFS partition)

```bash
vim /etc/default/grub
```
and add to `GRUB_CMDLINE_LINUX_DEFAULT` line `cryptdevice=UUID=<UUID>:root cryptkey=rootfs:/etc/cryptsetup-keys.d/root.key root=/dev/mapper/root`. Then generate GRUB configuration

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```
Minimal installation is done now. How to setup BTRFS and setup some other services you will find at [Basic Installation Guide](basic-installation.md) or you can just reboot.
