#!/bin/sh
# Adapted from mechakotik/dots; emit nothing on unsupported hardware.
profile_file=/sys/firmware/acpi/platform_profile
[ -r "$profile_file" ] || exit 0
IFS= read -r profile < "$profile_file" || exit 0

case "$profile" in
    low-power|quiet|cool) icon=quiet ;;
    balanced|balanced-performance) icon=balanced ;;
    performance) icon=performance ;;
    *) icon=default ;;
esac

printf '{"alt":"%s"}\n' "$icon"
