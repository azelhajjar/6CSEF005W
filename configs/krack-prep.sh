#!/bin/bash
set -euo pipefail

sudo apt update
sudo apt-get install -y --no-install-recommends python3-venv git libnl-3-dev libnl-genl-3-dev pkg-config libssl-dev net-tools sysfsutils python3-scapy python3-pycryptodome virtualenv  

echo "Creating directory..."
mkdir -p ~/Desktop/krack-lab
echo "Directory created. Contents of Desktop:"
ls -la ~/Desktop/
echo "Changing to krack-lab directory..."
cd ~/Desktop/krack-lab
echo "Current directory: $(pwd)"
echo "Starting git clone..."
git clone https://github.com/vanhoefm/krackattacks-scripts.git
git clone https://github.com/AlmogJakov/Krack-Attack.git
ls -la

python3 -m venv venv
source venv/bin/activate
pip install pycryptodome

sed -i 's/from Crypto.Cipher import/from Cryptodome.Cipher import/g' krackattacks-scripts/krackattack/libwifi/wifi.py
sed -i 's/from Crypto.Cipher import/from Cryptodome.Cipher import/g' krackattacks-scripts/krackattack/libwifi/crypto.py
sed -i 's/"channel (\\d+)"/r"channel (\\d+)"/g' krackattacks-scripts/krackattack/libwifi/wifi.py
sed -i 's/"type (\\w+)"/r"type (\\w+)"/g' krackattacks-scripts/krackattack/libwifi/wifi.py
sed -i 's/wpa_passphrase=abcdefgh/wpa_passphrase=password123/g' krackattacks-scripts/hostapd/hostapd.conf
sed -i 's/ssid=testnetwork/ssid=6CSEF005W-WPA2-AP/g' krackattacks-scripts/hostapd/hostapd.conf 
sed -i 's/channel=1/channel=6/g' krackattacks-scripts/hostapd/hostapd.conf
sed -i "s/pool=Net('192.168.100.0\/24')/pool=Net('192.168.140.0\/24')/g" krackattacks-scripts/krackattack/krack-test-client.py
sed -i "s/network='192.168.100.0\/24'/network='192.168.140.0\/24'/g" krackattacks-scripts/krackattack/krack-test-client.py
sed -i "s/gw='192.168.100.254'/gw='192.168.140.254'/g" krackattacks-scripts/krackattack/krack-test-client.py
sed -i 's/192.168.100.254/192.168.140.254/g' krackattacks-scripts/krackattack/krack-test-client.py
sed -i 's/dhcp-range=192.168.100.10,192.168.100.200,8h/dhcp-range=192.168.140.10,192.168.140.200,8h/g' krackattacks-scripts/hostapd/dnsmasq.conf
sed -i 's/dhcp-option=3,192.168.100.1/dhcp-option=3,192.168.140.1/g' krackattacks-scripts/hostapd/dnsmasq.conf
sed -i 's/dhcp-option=6,192.168.100.1/dhcp-option=6,192.168.140.1/g' krackattacks-scripts/hostapd/dnsmasq.conf

cd ~/Desktop/krack-lab/krackattacks-scripts/krackattack
./build.sh
./pysetup.sh
sudo ./disable-hwcrypto.sh
cd /home/kali/Desktop/krack-lab/Krack-Attack
rm מחברת\ עבודה.*
cd home/kali/Desktop/
echo "KRACK lab environment setup complete!"
echo "Lab files located in: ~/Desktop/krack-lab/"
