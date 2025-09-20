#!/bin/bash
# setup-kali-base.sh
# Baseline setup for setup-kali-base for wireless labs.
# - Installs required packages only
# - Leaves hostapd/dnsmasq disabled so they don't conflict with AP scripts

set -euo pipefail

require_root() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo "[!] Please run as root (use: sudo $0)"
    exit 1
  fi
}

apt_install() {
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y --no-install-recommends \
    hostapd dnsmasq iproute2 iptables \
    lighttpd freeradius \
    aircrack-ng tcpdump iw rfkill net-tools \
    ca-certificates curl reaver bettercap hcxdumptool mdk4  \
    wifite wireshark python3-pip
}

service_sanity() {
  systemctl disable hostapd 2>/dev/null || true
  systemctl disable dnsmasq 2>/dev/null || true
  systemctl stop hostapd 2>/dev/null || true
  systemctl stop dnsmasq 2>/dev/null || true
}

main() {
  require_root
  echo "[*] Installing required packages..."
  apt_install

  echo "[*] Installing Python tools..."
  pip3 install -U scapy

  echo "[*] Disabling hostapd/dnsmasq auto-start..."
  service_sanity

  echo "[✓] Baseline installation complete."
  echo "Repo path expected at: /home/kali/6CSEF005W/"
  echo "Runtime directory:     /home/kali/tmp_ap/"
}
echo "[i] If you see a 'Relogin or restart required' message,"
echo "    please log out or reboot your VM before continuing."
main "$@"
