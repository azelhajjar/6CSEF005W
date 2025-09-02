#!/bin/bash
# alfa-driver.sh
# Installs RTL8812AU driver for Alfa AWUS036ACH on Kali Linux
# Author: Dr Ayman El Hajjar

set -e

echo "[i] Installing RTL8812AU driver for Alfa adapter..."

sudo apt install -y dkms git build-essential libelf-dev linux-headers-$(uname -r)

if [ ! -d "/opt/rtl8812au" ]; then
  sudo git clone https://github.com/aircrack-ng/rtl8812au.git /opt/rtl8812au
fi

cd /opt/rtl8812au
sudo make
sudo make install



echo "[✓] RTL8812AU driver installed successfully."

echo "[i] Rebooting to apply driver if needed"
if [[ $SKIP_REBOOT -eq 0 ]]; then
  echo "[i] Rebooting to apply driver..."
  sudo reboot
else
  echo "[i] Reboot skipped (invoked with --noreboot)"
fi
