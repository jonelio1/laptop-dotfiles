#!/bin/bash

# CONFIGURATION
INTERFACE="wg"  # <--- IMPORTANT: Ensure this matches your interface name!
CONNECTED_ICON=""    # Locked padlock (Secure)
DISCONNECTED_ICON="" # Unlocked padlock (Insecure)

# CHECK STATUS
# We check if the interface exists and has an IP address
if ip link show $INTERFACE > /dev/null 2>&1 && \
   ip addr show $INTERFACE | grep -q "inet"; then
    STATUS="connected"
    TEXT="$CONNECTED_ICON VPN"
    TOOLTIP="WireGuard Connected ($INTERFACE)"
    CLASS="connected"
else
    STATUS="disconnected"
    TEXT="$DISCONNECTED_ICON VPN"
    TOOLTIP="WireGuard Disconnected"
    CLASS="disconnected"
fi

# HANDLE TOGGLE
if [ "$1" == "toggle" ]; then
    if [ "$STATUS" == "connected" ]; then
        nmcli connection down $INTERFACE
    else
        nmcli connection up $INTERFACE
    fi
    exit
fi

# OUTPUT JSON FOR WAYBAR
echo "{\"text\": \"$TEXT\", \"class\": \"$CLASS\", \"tooltip\": \"$TOOLTIP\"}"
