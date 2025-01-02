case "$DEVICE_TYPE" in
    "samsung")
        if [ ! -z "$DEVICE_ID" ]; then
            /opt/homebrew/bin/scrcpy -s "$DEVICE_ID" -S --stay-awake >> "$LOG_FILE" 2>&1 &
        else
            /opt/homebrew/bin/scrcpy --stay-awake -S >> "$LOG_FILE" 2>&1 &
        fi
        ;;
    "google")
        /opt/homebrew/bin/scrcpy --stay-awake -S >> "$LOG_FILE" 2>&1 &
        ;;
    *)
        /opt/homebrew/bin/scrcpy --stay-awake -S >> "$LOG_FILE" 2>&1 &
        ;;
esac
