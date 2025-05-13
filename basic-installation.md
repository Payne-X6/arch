# minimal instalation done, can reboot now # Minimal installation is complete, you can reboot now
```bash
Create User and Install Additional Tools
Bash

useradd -m -g users -G wheel payne # Create a new user 'payne' with a home directory and add to groups users and wheel
passwd payne # Set the password for the new user

logout # Log out of the chroot environment
login as payne # Log in as the newly created user

pacman -S sudo snapper base-devel git # Install the packages sudo, snapper, base-devel, and git
visudo # Open the file for sudo configuration
 - uncomment %wheel ALL # Uncomment the line to allow members of the wheel group to use sudo
Configure Snapper and Snapper-Rollback
Bash

mkdir AUR # Create a directory for packages from the AUR
cd AUR # Change directory to AUR
git clone [https://aur.archlinux.org/snapper-rollback.git](https://aur.archlinux.org/snapper-rollback.git) # Clone the snapper-rollback source code from the AUR
makepkg -rsic # Build and install the snapper-rollback package

sudo vim /etc/snapper-rollback.conf # Open the snapper-rollback configuration file
 - change subvol_snapshots to @.snapshots # Change the path to the subvolume for snapshots
 - change mountpoint to /.btrfsroot # Change the mount point for the root Btrfs partition

sudo umount /.snapshots # Unmount /.snapshots
sudo rmdir /.snapshots # Remove the /.snapshots directory (if it's empty)
sudo snapper -c root create-config / # Create a snapper configuration for the root directory
sudo snapper -c home create-config /home # Create a snapper configuration for home directories
sudo mount /.snapshots # Mount /.snapshots (snapper should create a new directory)

sudo systemctl enable snapper-timeline.timer # Enable the snapper-timeline timer for automatic snapshot creation
sudo systemctl enable snapper-cleanup.timer # Enable the snapper-cleanup timer for automatic cleanup of old snapshots
sudo systemctl start snapper-timeline.timer # Start the snapper-timeline timer
sudo systemctl start snapper-cleanup.timer # Start the snapper-cleanup timer

sudo pacman -S snap-pac # Install the snap-pac package for snapper integration with pacman;;;
```
