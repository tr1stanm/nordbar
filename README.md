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
The chain link icon in the top corner monitors when the VPN is connected or disconnected via the systemd service.  
Left click on the icon to toggle connection status.  
Right click to pull up the NordVPN GUI to select a country to connect to.

If you specify a default country during installation, the vpn will automatically reconnect
to that country when toggling. this can be useful if you don't want to connect to whatever
nordVPN decides will be your default based on your geographic location.

## demo
https://github.com/user-attachments/assets/7b2864fd-0102-4422-b46c-2c2ad7fd66b7

## installation
This module was developed on Hyprland. However, waybar works with any wayland-based compositor.  
If you're not using hyprland, however, be aware the install/uninstall scripts will not work properly and you'll need to manually restart waybar as the script uses a hyprctl command to do so.

### automatic install
Back up your waybar config files first!!  
```bash
mkdir ~/.config/waybarbackup
cp ~/.config/waybar/* ~/.config/waybarbackup
```  
This way if anything does awry during installation you have clean configs to restore to.

`git clone` this repo into some directory on your machine.  
```bash
cd nordbar
chmod +x install.sh uninstall.sh

# if you want to specify a default country:
./install.sh {your country name}

# otherwise
./install.sh
```

Done!

Automatic uninstallation is just as easy, just run `./uninstall.sh`.

### manual install
Recommended if not using Hyprland or if you've done custom configs for waybar already.  
The install script uses sed and awk to insert settings relevant to nordbar into the waybar 
config and style.css, so if any formatting is not as expected the commands may fail.

I'd also highly recommend against running the automatic uninstall if the above is the case as well.  
I am not responsible for anyone's configs getting deleted or modified in ways they don't want as 
a result of the uninstall script. 

#### Copy nord.sh and nordtoggle.sh from git directory to ~/.config/scripts
  ```bash
  mkdir -p ~/.config/scripts ; cp nord.sh nordtoggle.sh ~/.config/scripts
  ```

#### Copy nordbar.service to ~/.config/systemd/user/
  ```bash
  mkdir -p ~/.config/systemd/user ; cp nordbar.service ~/.config/systemd/user/
  ```

#### Copy country-by-abbreviation.json to ~/.config/waybar/assets (helps with country name shortening)
  ```bash
  mkdir -p ~/.config/waybar/assets ; cp country-by-abbreviation.json ~/.config/waybar/assets
  ```

#### Enable systemd service
  ```bash
  systemctl --user enable --now nordbar
  ```

#### Add to your waybar config
  ```jsonc
  {
    "modules-right": [
      "custom/vpn",
    // ... your other modules
  ],
  "custom/vpn": {
      "format": "{text}",
      "exec": "~/.config/scripts/nord.sh",
      "on-click": "~/.config/scripts/nordtoggle.sh",
      "on-click-right": "nordvpn-gui &",
      "interval": 3,
      "return-type": "json",
      "tooltip": true
  },
  ```

#### Add to your waybar style.css
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

#### Add a default country (optional)
Open the togglenord.sh file in ~/.config/scripts and edit the DEFAULT_COUNTRY field to
equal whatever country you want.
I'd recommend running `nordvpn c your_country` (replacing your_country with the name of
the actual country) beforehand to make sure syntax, spelling, etc. are correct.
```bash
{your_editor_here} ~/.config/scripts/togglenord.sh
DEFAULT_COUNTRY="" -> DEFAULT_COUNTRY="your_country"
```

#### Restart waybar
On hyprland (cleaner):
```bash
pkill waybar ; hyprctl dispatch exec waybar
```
On any other wayland compositor: 
```bash
pkill waybar ; waybar &
```

Done!
