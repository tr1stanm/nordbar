#!/bin/bash

CONFIG_PATH="$HOME/.config/waybar/config"
STYLE_PATH="$HOME/.config/waybar/style.css"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$HOME/.config/scripts"
WAYBAR_ASSETS_DIR="$HOME/.config/waybar/assets"
SYSTEMD_DIR="$HOME/.config/systemd/user"
CACHE_DIR="$HOME/.cache/vpnmonitor"

echo "Modifying waybar config + style.css..."
if ! grep -q '"custom/vpn"' "$CONFIG_PATH"; then
    sed -i '0,/"modules-right"/ {
    /"modules-right"/ {
        s/\[\s*\]/["custom\/vpn"]/
        t insert

        s/\]\s*,\s*$/,"custom\/vpn"],/

        :insert
        a\
    \
    "custom/vpn": {\
        "format": "{text}",\
        "exec": "~/.config/waybar/scripts/nord.sh",\
        "on-click": "~/.config/waybar/scripts/nord.sh --toggle",\
        "on-click-right": "nordvpn-gui &",\
        "interval": 3,\
        "return-type": "json",\
        "tooltip": true\
    },
    }
    }' "$CONFIG_PATH"
fi

cat <<EOF >> "$STYLE_PATH"

#custom-vpn {
    padding: 0px 5px;
    color: rgb(255,255,255);
    transition: all .3s ease;
}

#custom-vpn:hover {
    transition: all .3s ease;
    color: rgb(200,200,200);
}
EOF

echo "Installing script..."
mkdir -p "$SCRIPTS_DIR"
cp "$CURRENT_DIR/nord.sh" "$SCRIPTS_DIR/" 2> /dev/null

if [[ $? -eq 0 ]]; then
    echo "Installed to $SCRIPTS_DIR/nord.sh."
    chmod +x "$SCRIPTS_DIR/nord.sh"
else
    echo ""
    echo "Error: Could not install script. Is it in the current working directory?"
    echo ""
fi

echo "Installing assets..."
mkdir -p "$WAYBAR_ASSETS_DIR"
mkdir -p "$CACHE_DIR"
cp "$CURRENT_DIR/country-by-abbreviation.json" "$WAYBAR_ASSETS_DIR" 2> /dev/null

if [[ $? -eq 0 ]]; then
    echo "Installed to $SCRIPTS_DIR/country-by-abbreviation.json."
else
    echo ""
    echo "Error: Could not install json file. Is it in the current working directory?"
    echo ""
fi

echo "Installing systemd service..."
mkdir -p "$SYSTEMD_DIR"
cp "$CURRENT_DIR/nordbar.service" "$SYSTEMD_DIR" 2> /dev/null

if [[ $? -eq 0 ]]; then
    echo "Installed to $SYSTEMD_DIR/nordbar.service."
else
    echo ""
    echo "Error: Could not install systemd service. Is it in the current working directory?"
    echo ""
fi

echo "Starting service..."
systemctl --user enable --now nordbar.service

echo "Restarting waybar..."
pkill waybar ; hyprctl dispatch exec waybar > /dev/null 

if [[ $? -eq 0 ]]; then
    echo "Done!"
else
    echo ""
    echo "Warning: Could not restart waybar. Try restarting manually."
    echo ""
fi
