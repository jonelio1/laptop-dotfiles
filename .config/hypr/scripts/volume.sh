#!/bin/bash

# Function to send notification
notify_vol() {
    # Get current volume information
    # Output is usually: "Volume: 0.45 [MUTED]" or "Volume: 0.45"
    info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

    # Extract the float value (e.g., 0.45)
    vol_float=$(echo "$info" | awk '{print $2}')

    # Convert to integer percentage (0.45 -> 45) for Dunst bar
    vol=$(awk "BEGIN {print int($vol_float * 100)}")

    # Check for [MUTED] string
    if [[ "$info" == *"[MUTED]"* ]]; then
        icon="audio-volume-muted"
        text="Muted"
    else
        # Choose icon based on volume level
        if [ "$vol" -gt 66 ]; then
            icon="audio-volume-high"
        elif [ "$vol" -gt 33 ]; then
            icon="audio-volume-medium"
        else
            icon="audio-volume-low"
        fi
        text="$vol%"
    fi

    # Send the notification
    # -h string:x-dunst-stack-tag:audio -> Makes notifications replace each other
    # -h int:value:$vol                 -> Draws the progress bar
    notify-send -a "Volume" -i "$icon" -h string:x-dunst-stack-tag:audio \
    -h int:value:"$vol" "Volume" "$text"
}

# Handle arguments
case $1 in
    up)
        # -l 1.0 limits volume to 100% (prevent blowing speakers)
        wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
        notify_vol
        ;;
    down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        notify_vol
        ;;
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        notify_vol
        ;;
esac
