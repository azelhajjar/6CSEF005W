#!/bin/bash
# rename-interface.sh
# Renames a network interface persistently using systemd .link rules
# Usage: sudo ./rename-interface.sh [current_iface] [new_name]

set -e

DEFAULT_TARGET="lab-wlan"
LINK_DIR="/etc/systemd/network"

if [[ $EUID -ne 0 ]]; then
  echo "[!] Please run as root: sudo $0 [current_iface] [new_name]"
  exit 1
fi

if [[ $# -ge 1 ]]; then
  selected_iface="$1"
else
  selected_iface="wlan0"
fi

if [[ $# -ge 2 ]]; then
  new_name="$2"
else
  new_name="$DEFAULT_TARGET"
fi

if [[ ! -d "/sys/class/net/$selected_iface" ]]; then
  echo "[!] Interface '$selected_iface' not found."
  exit 1
fi

mac=$(cat "/sys/class/net/$selected_iface/address")
link_file="$LINK_DIR/10-$new_name.link"

echo "[i] Creating systemd .link file at $link_file"
mkdir -p "$LINK_DIR"

cat <<EOF > "$link_file"
[Match]
MACAddress=$mac

[Link]
Name=$new_name
EOF

echo "[i] Reloading udev rules..."
udevadm control --reload
systemctl restart systemd-udevd

echo "[✓] Rule written. System will reboot now to apply ."
sudo reboot