# Arch Linux Basic Installation Guide

This describes few additional steps to improve minimalistic Arch Linux user experience. Login as admin user (not `root`)

## Install manpages

```bash
sudo pacman -S man-db man-pages
```

## Install YAY package manager (for AUR packages)

```bash
sudo pacman -S base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -rsic
cd ..
rm -rf yay
yay -S yay
```

## Automatic update of mirrors

First create `ghostmirror` system user account and setup new mirrorlist path (not created yet, but we will create it in the moment).

```bash
yay -S ghostmirror
sudo useradd --system -m -U ghostmirror
sudo loginctl enable-linger ghostmirror
sudo vim /etc/pacman.conf
```
And edit paths at `[core] Include` and `[extra] Include` to `/home/ghostmirror/mirrorlist`.

Now login as ghostmirror user and create `mirrorlist`. Then cleanup home directory, disable login and lock user.

```bash
sudo su ghostmirror
cd ~
ghostmirror -PoclLS Czechia,Austria,Germany,Poland,Slovakia mirrorlist 30 state,outofdate,morerecent,ping
ghostmirror -PoDumlsS  mirrorlist mirrorlist light state,outofdate,morerecent,extimated,speed
exit
sudo chsh -s /usr/bin/nologin ghostmirror
sudo passwd -l ghostmirror
sudo rm -r ~ghostmirror/.bash*
```

## Snapshot automatization

### Install snapper

For snapshot management install and configure snapper

```bash
pacman -S snapper
sudo umount /.snapshots
sudo rmdir /.snapshots
sudo snapper -c root create-config /
sudo mount /.snapshots
```

### Automatization of snapshots

Optionaly, you can allow and start snapper timers for automatization

```bash
sudo systemctl enable snapper-timeline.timer
sudo systemctl enable snapper-cleanup.timer
sudo systemctl enable snapper-boot.timer
sudo systemctl start snapper-timeline.timer
sudo systemctl start snapper-cleanup.timer
sudo systemctl start snapper-boot.timer
```

and then enable snapshots hook for `pacman`, that creates pre-post snapshots for each `pacman` run

```bash
sudo pacman -S snap-pac
```

### Snapshot rollbacks

Optionaly install and configure `snapper-rollback` for easy rollback between snapshots.

```bash
yay -S snapper-rollback
vim /etc/snapper-rollback.conf
```

And edit `subvol_snapshots` to use your `@.snapshots` subvolume, then edit `mountpoint` to use your root mountpoint (e.g. `\.btrfsroot`).

### Snapshots entries at GRUB

Optionaly you can install `grub-btrfs` to add BTRFS snapshots to GRUB entries automatically

```bash
sudo pacman -S grub-btrfs inotify-tools
sudo systemctl enable grub-btrfsd
sudo systemctl start grub-btrfsd
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Next you will need HOOK in `initramfs` to boot into `overlayfs`. This will change (by default) read-only snapshots "writable" similar way Live CDs does, means all changes are written on the RAM and lost after reboot.

```bash
sudo vim /etc/mkinitcpio.conf
```

And add at the end of HOOKS array `grub-btrfs-overlayfs`. Then re-generate `initramfs`.

```bash
sudo mkinitcpio -p linux
```
