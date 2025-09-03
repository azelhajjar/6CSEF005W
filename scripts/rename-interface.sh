#!/bin/bash
# rename-interface.sh
# Renames the Alfa USB wireless interface to a custom name (default: lab-wlan)
# Ensures the built-in Pi Wi-Fi (brcmfmac) stays untouched
# Usage: sudo ./rename-interface.sh [current_iface] [new_name]
# Author: Dr Ayman El Hajjar

DEFAULT_TARGET="lab-wlan"
UDEV_RULE="/etc/udev/rules.d/70-persistent-net.rules"

echo "[i] Scanning for USB wireless interfaces (excluding built-in Wi-Fi)..."

usb_candidates=()

# Step 1: Find valid USB interfaces, skipping the internal brcmfmac Wi-Fi
for iface in $(ls /sys/class/net); do
    if [[ -d "/sys/class/net/$iface/device" ]]; then
        driver_path=$(readlink -f "/sys/class/net/$iface/device/driver")
        # Skip the internal Wi-Fi driver
        if [[ "$driver_path" == *"usb"* ]] && [[ "$driver_path" != *"brcmfmac"* ]]; then
            usb_candidates+=("$iface")
        fi
    fi
done

# Step 2: Verify wireless capability
valid_iw=($(iw dev | grep Interface | awk '{print $2}'))
usb_wireless=()
for iface in "${usb_candidates[@]}"; do
    if [[ " ${valid_iw[*]} " == *" $iface "* ]]; then
        usb_wireless+=("$iface")
    fi
done

# Step 3: Interface selection logic
if [[ $# -ge 1 ]]; then
    selected_iface="$1"
    if [[ ! " ${usb_wireless[*]} " =~ " $selected_iface " ]]; then
        echo "[!] Specified interface '$selected_iface' is not a valid Alfa USB wireless interface."
        exit 1
    fi
else
    if [[ ${#usb_wireless[@]} -eq 0 ]]; then
        echo "[!] No Alfa USB wireless interfaces found."
        exit 1
    fi
    selected_iface="${usb_wireless[0]}"
fi

# Step 4: Set new interface name
if [[ $# -ge 2 ]]; then
    new_name="$2"
else
    new_name="$DEFAULT_TARGET"
fi

echo "[+] Selected interface: $selected_iface"
echo "[+] New name will be: $new_name"

# Get the MAC address
mac=$(cat "/sys/class/net/$selected_iface/address")
echo "[i] MAC address for $selected_iface: $mac"

# Step 5: Write persistent udev rule
echo "SUBSYSTEM==\"net\", ACTION==\"add\", ATTR{address}==\"$mac\", NAME=\"$new_name\"" \
    | sudo tee "$UDEV_RULE" > /dev/null

echo "[+] Udev rule written: $UDEV_RULE"
echo "[+] Interface '$selected_iface' will be renamed to '$new_name' on next boot."

# Step 6: Prompt for reboot
read -p "[?] Do you want to reboot now to apply changes? (y/n): " reboot_choice
if [[ "$reboot_choice" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]; then
    echo "[i] Rebooting..."
    sudo reboot
else
    echo "[i] Please reboot manually to apply the renaming."
fi

exit 0
