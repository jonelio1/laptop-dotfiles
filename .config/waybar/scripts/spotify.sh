#!/bin/bash

class="custom-spotify"

if playerctl -p spotify status > /dev/null 2>&1; then
    # Get status (Playing/Paused)
    STATUS=$(playerctl -p spotify status)
    
    # Get Metadata
    TEXT=$(playerctl -p spotify metadata --format '{{artist}} - {{title}}')
    
    # Set Icon based on status
    if [ "$STATUS" == "Playing" ]; then
        ICON="" # Spotify Icon
        CLASS="playing"
    else
        ICON="" # Pause Icon
        CLASS="paused"
    fi
    
    # Output JSON
    echo "{\"text\": \"$ICON  $TEXT\", \"class\": \"$CLASS\", \"tooltip\": \"$TEXT ($STATUS)\"}"
else
    # Hide widget if Spotify isn't running
    echo ""
fi
