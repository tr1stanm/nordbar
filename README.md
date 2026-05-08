# nordbar
Waybar module and script for monitoring + changing NordVPN status

## dependencies
- waybar: https://github.com/Alexays/Waybar  
- nordVPN: https://aur.archlinux.org/packages/nordvpn-bin  
- nordVPN GUI: https://aur.archlinux.org/packages/nordvpn-gui  
- notify: https://aur.archlinux.org/packages/notify
- nerdfonts: https://www.nerdfonts.com/
- hyprland (optional): https://hypr.land/

## usage
the chain link icon in the top corner monitors when the VPN is connected or disconnected via the systemd service.  
left click on the icon to toggle connect status.  
right click to pull up the NordVPN GUI to select a country to connect to.

## installation
This module was developed on Hyprland. However, waybar works with any wayland-based compositor.  
If you're not using hyprland, however, be aware the install/uninstall scripts will not work properly 
and you'll need to manually restart waybar as the script uses a hyprctl command to do so.

### automatic install
Back up your waybar config files first!!  
`mkdir ~/.config/waybarbackup ; cp ~/.config/waybar/* ~/.config/waybarbackup`  
This way if anything does awry during installation you have clean configs to restore to.

`git clone` this repo into some directory on your machine.  
run `cd nordbar ; chmod +x install.sh uninstall.sh ; ./install.sh`

Done!

Automatic uninstallation is just as easy, just run `./uninstall.sh`.

### manual install
Recommended if not using Hyprland or if you've done custom configs for waybar already.  
The install script uses sed and awk to insert settings relevant to nordbar into the waybar 
config and style.css, so if any formatting is not as expected the commands may fail.

I'd also highly recommend against running the automatic uninstall if the above is the case as well.  
I am not responsible for anyone's configs getting deleted or modified in ways they don't want as 
a result of the uninstall script. 

1. copy nord.sh from git directory to ~/.config/scripts
  ```bash
  mkdir -p ~/.config/scripts ; cp nord.sh ~/.config/scripts
  ```

2. copy nordbar.service to ~/.config/systemd/user/
  ```bash
  mkdir -p ~/.config/systemd/user ; cp nordbar.service ~/.config/systemd/user/
  ```

3. copy country-by-abbreviation.json to ~/.config/waybar/assets (helps with country name shortening)
  ```bash
  mkdir -p ~/.config/waybar/assets ; cp country-by-abbreviation.json ~/.config/waybar/assets
  ```

4. enable systemd service
  ```bash
  systemctl --user enable --now nordbar
  ```

5. add to your waybar config
  ```jsonc
  {
    "modules-right": [
      "custom/vpn",
    // ... your other modules
  ],
  "custom/vpn": {
      "format": "{text}",
      "exec": "~/.config/waybar/scripts/nord.sh",
      "on-click": "~/.config/waybar/scripts/nord.sh --toggle",
      "on-click-right": "nordvpn-gui &",
      "interval": 3,
      "return-type": "json",
      "tooltip": true
  },
  ```

6. add to your waybar style.css
  ```css
  #custom-vpn {
    padding: 0px 5px;
    color: rgb(255,255,255);
    transition: all .3s ease;
  }
  
  #custom-vpn:hover {
      transition: all .3s ease;
      color: rgb(200,200,200);
  }
  ```

7. restart waybar  
on hyprland (cleaner):
```bash
pkill waybar ; hyprctl dispatch exec waybar
```
on any other wayland compositor: 
```bash
pkill waybar ; waybar &
```
