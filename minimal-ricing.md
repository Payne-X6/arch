# Ricing of minimalistic installation

## Faster boot

### Decryption

LUKS partition with default number of iterations can take a while to open, when using GRUB with PBKDF2. Change number of iterations, use at least 1000 `<iterations>`, default/set value can be obtained from `sudo cryptsetup luksDump /dev/vda2`.

```
sudo cryptsetup luksChangeKey --key-slot=0 --pbkdf=pbkdf2 --pbkdf-force-iterations=<iterations> /dev/sda3
```

## Bash

### Default .bashrc

You can install default Arch `.bashrc` by 

```bash
sudo cat /etc/bash.bashrc > .bashrc
```

### Custom .bashrc

Install [bash/.bashrc](bash/.bashrc) file into home directory.

It has already setup custom prompt and neofetch print on startup.

### Completion by tab

Install

```bash
sudo pacman -S bash-completion
```

and use default or custom `.bashrc` above, not the profile default.

### Command not found hook

Install `pkgfile` package and update database, allow automatic update of database

```bash
sudo pacman -S pkgfile
sudo pkgfile --update
sudo systemctl enable pkgfile-update.timer
sudo systemctl start pkgfile-update.timer
```
Then load `/usr/share/doc/pkgfile/command-not-found.bash` and/or add to your `.bashrc`.

```bash
source /usr/share/doc/pkgfile/command-not-found.bash
```

## Neofetch

To install, run

```bash
sudo pacman -S neofetch
```

In `bash/.bashrc` file, `neofetch` is already setup to run on open new bash. If you want to add it to your setup, run something like this

```bash
echo -e "\nneofetch" >> .bashrc
```

or just copy my code from `bash/.bashrc` file (there is a check if `neofetch` is available).

## Vim

Install some ricing dependencies

```bash
sudo pacman -S git ctags ncurses curl vim
```

and use [vim/.vimrc](vim/.vimrc), or download vim-bootstraped `.vimrc`

```bash
curl 'https://vim-bootstrap.com/generate.vim' --data 'editor=vim' > .vimrc
```
