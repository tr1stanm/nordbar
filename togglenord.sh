#!/bin/bash

is_connected() {
    ip link show nordlynx &>/dev/null
}

DEFAULT_COUNTRY=""
(
    if is_connected; then
        nordvpn d > /dev/null
        while is_connected; do
            sleep 1
        done
    else
        if [[ -n $DEFAULT_COUNTRY ]]; then
            nordvpn c $DEFAULT_COUNTRY
        else
            nordvpn c
        fi
    fi
)

