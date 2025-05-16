# Desktop environment installation

## Audio server

```bash
sudo pacman -S pipewire pipewire-audio
systemctl --user enable pipewire
systemctl --user start pipewire
```

## Greeter / Desktop manager

```bash
sudo pacman -S sddm uwsm
```

## Desktop compositor

First install vulkan graphics driver

```bash
sudo pacman -S vulkan-virtio
```

Then install compositor alone

```bash
sudo pacman -S hyprland 
```

or you can install whole ecosystem at once

```bash
sudo pacman -S hyprpaper hyprland hypridle hyprlock hyprcursor hyprpolkitagent hyprsunset
```

omited `hyprpicker`, for me it's useless applicaiton.
