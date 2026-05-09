#!/bin/bash

CONFIG_PATH="$HOME/.config/waybar/config"
STYLE_PATH="$HOME/.config/waybar/style.css"
SCRIPTS_DIR="$HOME/.config/scripts"
WAYBAR_ASSETS_DIR="$HOME/.config/waybar/assets"
SYSTEMD_DIR="$HOME/.config/systemd/user"
CACHE_DIR="$HOME/.cache/vpnmonitor"

echo "Uninstalling..."

sed -i '/"modules-right"/ {
    s/,"custom\/vpn"//g
    s/"custom\/vpn",//g
    s/"custom\/vpn"//g
}' "$CONFIG_PATH"


sed -i '/"custom\/vpn": {/,/},/d' "$CONFIG_PATH"
sed -i '/#custom-vpn/,/}/d' "$STYLE_PATH"

echo "Disabling + removing systemd service..."
systemctl --user disable --now nordbar.service
rm -f "$SYSTEMD_DIR/nordbar.service"

echo "Removing script and related assets..."
rm -f "$SCRIPTS_DIR/nord.sh"
rm -f "$SCRIPTS_DIR/togglenord.sh"
rm -f "$WAYBAR_ASSETS_DIR/country-by-abbreviation.json"
rm -f "$WAYBAR_ASSETS_DIR/vpnout.txt"
rm -f "$CACHE_DIR/ip_location.txt"
rmdir "$CACHE_DIR"      # rm -rf makes me nervous in shell scripts ok

echo "Restarting waybar..."
pkill waybar ; hyprctl dispatch exec waybar > /dev/null

if [[ $? -eq 0 ]]; then
    echo "Uninstall complete!"
else
    echo ""
    echo "Warning: Could not restart Waybar. Try restarting it manually."
    echo ""
fi
