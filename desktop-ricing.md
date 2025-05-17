#
## SDDM
### Theme

```bash
sudo pacman -S qt5-graphicaleffects qt5-declarative
yay -S sddm-sugar-candy-git
mkdir /etc/sddm.conf.d
```

And usy my theme configuration file

or create theme configuration file

```bash
echo -e "[Theme]\nCurrent=sugar-candy > /etc/sddm.conf.d/20-theme.conf
```
