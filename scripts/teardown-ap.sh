#!/bin/bash
# teardown-ap.sh - Stops rogue AP services and restores Idle MAL-AP
# Author: Dr Ayman El Hajjar

echo "[i] Searching for USB wireless interface..."

# Detect first USB wireless interface (no rename required)
usb_candidates=()
for iface in $(ls /sys/class/net); do
  if [[ -d "/sys/class/net/$iface/device" ]]; then
    driver_path=$(readlink -f "/sys/class/net/$iface/device/driver")
    if [[ "$driver_path" == *"usb"* ]]; then
      if iw dev | grep -q "Interface $iface"; then
        usb_candidates+=("$iface")
      fi
    fi
  fi
done

if [ ${#usb_candidates[@]} -eq 0 ]; then
  echo "[✗] No USB wireless interface found."
  exit 1
fi

INTERFACE="${usb_candidates[0]}"
echo "[✓] Using detected interface: $INTERFACE"

echo "[i] Tearing down active AP and restoring Idle MAL Access Point..."

# Stop all potential services
sudo pkill hostapd || true
sudo pkill dnsmasq || true
sudo pkill airbase-ng || true

# Wait until the interface is free
for i in {1..10}; do
  if ! lsof | grep -q "$INTERFACE"; then
    echo "[✓] Interface $INTERFACE is now free."
    break
  fi
  echo "[…] Waiting for $INTERFACE to be released (attempt $i)..."
  sleep 1
done

# Reset interface
echo "[i] Resetting $INTERFACE..."
sudo ip addr flush dev "$INTERFACE"
sudo iw dev "$INTERFACE" set type managed || sudo iwconfig "$INTERFACE" mode managed
sudo ip link set "$INTERFACE" down
sleep 1
sudo ip link set "$INTERFACE" up
sleep 1

# Flush firewall rules
echo "[i] Cleaning firewall..."
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X

# Remove NAT rules
sudo iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || true
sudo iptables -D FORWARD -i eth0 -o "$INTERFACE" -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
sudo iptables -D FORWARD -i "$INTERFACE" -o eth0 -j ACCEPT 2>/dev/null || true

# Disable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=0

# Cleanup
sudo rm -rf /var/run/hostapd

# Restore AP or reset interface depending on host
if systemctl list-units --type=service | grep -q "idle-ap.service"; then
# If host is Pi, run idle_ap.service 
  echo "[i] Restarting idle-ap.service..."
  sudo systemctl restart idle-ap.service
elif systemctl list-units --type=service | grep -q "idle-mal-ap.service"; then
# If host is Pi, run idle_mal_ap.service 
  echo "[i] Restarting idle-mal-ap.service..."
  sudo systemctl restart idle-mal-ap.service
else
  echo "[i] No idle services found. Resetting interface to managed mode..."
  # If host is Kali, reset itnerface to managed mode 
  sudo iw dev "$INTERFACE" set type managed || sudo iwconfig "$INTERFACE" mode managed
  sudo ip link set "$INTERFACE" down
  sleep 1
  sudo ip link set "$INTERFACE" up
fi

echo "[✓] Teardown complete. System restored to default state."
