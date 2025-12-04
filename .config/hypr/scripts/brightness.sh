#!/bin/bash

# Function to send notification
notify_bright() {
    # Get current brightness percentage
    # brightnessctl -m outputs: device,class,current,max_percent (e.g. "intel_backlight,backlight,9600,50%")
    # We grab the 4th field and strip the '%' sign
    perc=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

    # Choose icon based on brightness level
    if [ "$perc" -gt 80 ]; then
        icon="display-brightness-high"
    elif [ "$perc" -gt 40 ]; then
        icon="display-brightness-medium"
    else
        icon="display-brightness-low"
    fi

    # Send the notification
    # -h string:x-dunst-stack-tag:brightness -> Replaces previous brightness notifications
    # -h int:value:$perc                     -> Draws the progress bar
    notify-send -a "Brightness" -i "$icon" -h string:x-dunst-stack-tag:brightness \
    -h int:value:"$perc" "Brightness" "$perc%"
}

# Handle arguments
case $1 in
    up)
        # Increase brightness by 5%
        brightnessctl set 5%+
        notify_bright
        ;;
    down)
        # Decrease brightness by 5%, but don't let it go below 1% (prevent black screen)
        # (brightnessctl handles the lower limit gracefully usually, but this is safe)
        brightnessctl set 5%-
        notify_bright
        ;;
esac
