# Ricing of basic installation

## Neofetch

```bash
sudo pacman -S neofetch
echo -e "\nneofetch" >> .bashrc
```

## Vim

```bash
sudo pacman -S git ctags ncurses curl vim
curl 'https://vim-bootstrap.com/generate.vim' --data 'editor=vim' > .vimrc
```
