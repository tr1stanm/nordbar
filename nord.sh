#!/bin/bash

CACHE="$HOME/.cache/vpnmonitor/ip_location.txt"
WAYBAR_ASSETS="$HOME/.config/waybar/assets"

is_connected() {
    ip link show nordlynx &>/dev/null
}

get_connection_details() {
    local FULLSTATUS
    local IP CITY COUNTRY COUNTRYABBREV

    FULLSTATUS=$(nordvpn status)
    IP=$(awk -F': ' '/^IP:/ {print $2}' <<< "$FULLSTATUS")
    CITY=$(awk -F': ' '/^City:/ {print $2}' <<< "$FULLSTATUS")
    COUNTRY=$(awk -F': ' '/^Country:/ {print $2}' <<< "$FULLSTATUS")
    [[ -n "$IP" && -n "$CITY" && -n "$COUNTRY" ]] || return

    COUNTRYABBREV=$(
        jq --arg country "$COUNTRY" \
        '.[] | select(.country==$country).abbreviation' \
        ~/.config/waybar/assets/country-by-abbreviation.json | sed 's/"//g')
    if [[ -z $COUNTRYABBREV ]]; then
        COUNTRYABBREV="$COUNTRY"
    fi
    IP_AND_LOCATION=$(echo -e "$CITY, $COUNTRYABBREV\n$IP")
}

connect_msg() {
    if is_connected; then
        notify-send -r 9999 "$IP_AND_LOCATION"
    else
        notify-send -r 9999 "Disconnected from VPN"
    fi
}

record_connection() {
    if is_connected; then
        if [[ -z "$IP_AND_LOCATION" ]]; then
            get_connection_details
        fi
        echo -e "$IP_AND_LOCATION" > $CACHE
    fi
}

output() {
    if is_connected; then
        echo '{"text": ""}' > $WAYBAR_ASSETS/vpnout.txt
    else
        echo '{"text": ""}' > $WAYBAR_ASSETS/vpnout.txt
    fi
}

run() {
    if is_connected; then
        get_connection_details

        if [[ -f $CACHE ]] && [[ $(<"$CACHE") == "$IP_AND_LOCATION" ]]; then
            output
        else
            record_connection
            output
            connect_msg
        fi
    else
        if [[ -f $CACHE ]]; then
            connect_msg
            rm $CACHE
        fi
        output
    fi
}

get_connection_details
while true; do
    run
    sleep 3
done
