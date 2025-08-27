#!/bin/bash
# setup_kali_base.sh
# Wireless drivers and wireless tools for Kali Linux
# Author: Dr Ayman El Hajjar

set -e

echo "[i] Updating package lists..."
sudo apt update

echo "[i] Installing base network tools..."
sudo apt install -y iw wireless-tools net-tools dnsmasq hostapd python3-pip 

echo "[i] Installing wireless security tools..."
sudo apt install -y aircrack-ng reaver wash bettercap hcxdumptool mdk4 mac80211-utils wifite wireshark

echo "[i] Installing Python tools..."
pip3 install scapy

echo "[i] Installing RTL8812AU driver for Alfa adapter..."
echo "[i] Installing Alfa driver..."
sudo ./alfa-driver-kali.sh --noreboot

echo "[✓] Kali base setup complete."

read -p "[?] Reboot now to apply changes? (y/n): " reboot_choice
if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
  echo "[i] Rebooting..."
  sudo reboot
else
  echo "[i] Please reboot manually before continuing with wireless lab activities."
fi
