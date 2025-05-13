# Arch Linux Basic Installation Guide

This describes few additional steps to improve minimalistic Arch Linux user experience

## Install YAY package manager (for AUR packages)

```
pacman -S base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -rsic
cd ..
rm -rf yay
yay -S yay
```

## Install and configure snapper, then allow automatic snapshots

Install and configure snapper

```bash
pacman -S snapper
sudo umount /.snapshots
sudo rmdir /.snapshots
sudo snapper -c root create-config /
sudo mount /.snapshots
```

Then enable basic timers for snapper

```bash
sudo systemctl enable snapper-timeline.timer
sudo systemctl enable snapper-cleanup.timer
sudo systemctl start snapper-timeline.timer
sudo systemctl start snapper-cleanup.timer
```

and then enable snapshot hook for `pacman`, that creates pre-post snapshots for each `pacman` run

```bash
sudo pacman -S snap-pac # Install the snap-pac package for snapper integration with pacman;;;
```

Finally install and configure `snapper-rollback`

```bash
yay -S snapper-rollback
vim /etc/snapper-rollback.conf
```

And edit `subvol_snapshots` to use your `@.snapshots` subvolume, then edit `mountpoint` to use your root mountpoint (e.g. `\.btrfsroot`).
