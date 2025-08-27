#!/bin/bash
# rename-interface.sh
# Renames a USB wireless interface to a user-defined name (default: lab-wlan)
# Usage: ./rename-interface.sh [current_iface] [new_name]
# Author: Dr Ayman El Hajjar

DEFAULT_TARGET="lab-wlan"
udev_file="/etc/udev/rules.d/70-persistent-net.rules"

echo "[i] Scanning for USB wireless interfaces..."

# Step 1: Find USB network interfaces
usb_candidates=()
for iface in $(ls /sys/class/net); do
  if [[ -d "/sys/class/net/$iface/device" ]]; then
    driver_path=$(readlink -f "/sys/class/net/$iface/device/driver")
    if [[ "$driver_path" == *"usb"* ]]; then
      usb_candidates+=("$iface")
    fi
  fi
done

# Step 2: Confirm wireless capability
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
    echo "[!] Specified interface '$selected_iface' is not a valid USB wireless interface."
    exit 1
  fi
else
  if [[ ${#usb_wireless[@]} -eq 0 ]]; then
    echo "[!] No USB wireless interfaces found."
    exit 1
  fi
  selected_iface="${usb_wireless[0]}"
fi

# Step 4: Target name logic
if [[ $# -ge 2 ]]; then
  new_name="$2"
else
  new_name="$DEFAULT_TARGET"
fi

echo "[+] Selected interface: $selected_iface"
echo "[+] New name will be: $new_name"

mac=$(cat "/sys/class/net/$selected_iface/address")
echo "[i] MAC address: $mac"

# Write udev rule
echo "SUBSYSTEM==\"net\", ACTION==\"add\", ATTR{address}==\"$mac\", NAME=\"$new_name\"" | sudo tee "$udev_file" > /dev/null

echo "[+] Interface $selected_iface will be renamed to $new_name on next boot."
echo "[i] udev rule written to: $udev_file"

read -p "[?] Do you want to reboot now to apply changes? (y/n): " reboot_choice
if [[ "$reboot_choice" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]; then
  echo "[i] Rebooting..."
  sudo reboot
else
  echo "[i] Please reboot manually before continuing."
fi

exit 0
