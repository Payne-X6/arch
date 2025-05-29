# Desktop environment

## Installation
### Audio server

```bash
sudo pacman -S pipewire pipewire-audio wireplumber
systemctl --user enable pipewire
systemctl --user start pipewire
```

### Greeter / Desktop manager

```bash
sudo pacman -S sddm uwsm
```

### Desktop compositor

First install vulkan graphics driver.

```bash
sudo pacman -S vulkan-icd-loader vulkan-tools
```

For SW rendering

```bash
sudo pacman -S vulkan-swrast
```

For virtio rendering

```bash
sudo pacman -S vulkan-virtio
```

Then install compositor alone

```bash
sudo pacman -S hyprland 
```

or you can install whole ecosystem at once

```bash
sudo pacman -S hyprpaper hyprland hypridle hyprlock hyprcursor hyprpolkitagent hyprsunset xdg-desktop-portal-hyprland
```

omited `hyprpicker`, for me it's useless applicaiton.

### Desktop apps

There are at least 3 applications, that you will need for the best `Hyprland` experience. Terminal emulator, file manager and applicaiton starter. Install them by

```bash
sudo pacman -S kitty dolphin wofi
```

### Top bar

```bash
sudo pacman -S waybar
```

## Start

After installing everything you need, you can enable and start desktop manager

```bash
sudo systemctl enable sddm.service
sudo systemctl start sddm.service
```
