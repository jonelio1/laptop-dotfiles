#!/bin/bash

# 1. Get the raw list (SSID, Security, Bars)
# -t = terse (colon separated), -f = fields
# We save this raw data to reference later
raw_list=$(nmcli -t -f SSID,SECURITY,BARS device wifi list)

# 2. Format the list for Rofi (Pretty print for the user)
# We change the colons to spaces and icons for display only
display_list=$(echo "$raw_list" | awk -F: '{
    if($2=="") sec="🔓"; else sec="🔒"; 
    # Print formatted columns (SSID gets 30 chars padding)
    printf "%-30s %s %s\n", $1, sec, $3
}')

# 3. Show Rofi Menu & Get Selected Index
# -format i  -> Returns the line number (0, 1, 2...) instead of the text
# -mesg      -> Adds a helpful prompt
chosen_index=$(echo "$display_list" | rofi -dmenu -i -format i -p "Wi-Fi" -theme ~/.config/rofi/catppuccin-mocha.rasi)

# Exit if cancelled (index will be empty)
[ -z "$chosen_index" ] && exit

# 4. Retrieve the EXACT SSID using the index
# We look up the corresponding line in the raw_list.
# 'sed' uses 1-based indexing, so we add 1 to the Rofi index.
# We then extract the first field (SSID) before the colon.
chosen_line=$(echo "$raw_list" | sed -n "$((chosen_index + 1))p")
chosen_id=$(echo "$chosen_line" | cut -d: -f1)

# 5. Check if it's already a saved connection
# If we have a profile for this SSID, we usually just want to bring it 'up'
# instead of trying to create a new one (which causes conflicts).
if nmcli connection show "$chosen_id" > /dev/null 2>&1; then
    notify-send "WiFi" "Connecting to known network: $chosen_id"
    nmcli connection up "$chosen_id"
    exit
fi

# 6. Prompt for Password (if secured)
# Check the raw line for security info (field 2)
security=$(echo "$chosen_line" | cut -d: -f2)

if [ -n "$security" ]; then
    wifi_password=$(rofi -dmenu -p "Password: " -password -theme ~/.config/rofi/catppuccin-mocha.rasi)
    # If cancelled, exit
    [ -z "$wifi_password" ] && exit
fi

# 7. Connect (The Robust Way)
# name "$chosen_id" -> Forces a clean profile name (fixes 'property missing')
if [ -z "$wifi_password" ]; then
    nmcli device wifi connect "$chosen_id" name "$chosen_id"
else
    nmcli device wifi connect "$chosen_id" password "$wifi_password" name "$chosen_id"
fi

# 8. Notify result
if [ $? -eq 0 ]; then
    notify-send "WiFi" "Connected to $chosen_id"
else
    notify-send "WiFi" "Connection failed. Check password?"
fi
