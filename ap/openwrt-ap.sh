#!/bin/bash
# setup_pi_openwrt_base.sh
# Flash OpenWrt onto Raspberry Pi SD card
# Author: Dr Ayman El Hajjar

OPENWRT_VERSION="23.05.3"
DEVICE="rpi-5"  
ARCHIVE_NAME="openwrt-${OPENWRT_VERSION}-bcm27xx-bcm2711-${DEVICE}-squashfs-factory.img.gz"
DL_URL="https://downloads.openwrt.org/releases/${OPENWRT_VERSION}/targets/bcm27xx/bcm2711/${ARCHIVE_NAME}"
MOUNT_POINT="/mnt/openwrt-sd"

echo " Downloading OpenWrt for Raspberry Pi 4..."

wget "$DL_URL" -O "/tmp/${ARCHIVE_NAME}" || { echo " Download failed."; exit 1; }

echo "🗜️ Unzipping image..."
gunzip "/tmp/${ARCHIVE_NAME}" || { echo " Unzip failed."; exit 1; }

IMG_FILE="/tmp/${ARCHIVE_NAME%.gz}"

read -p "💾 Enter your SD card device (e.g., /dev/sdX or /dev/mmcblk0): " SD_DEVICE

echo " About to flash OpenWrt to $SD_DEVICE — THIS WILL ERASE ALL DATA."
read -p "Are you sure? (yes/no): " CONFIRM
[ "$CONFIRM" != "yes" ] && exit 1

echo "📝 Writing image to SD card..."
sudo dd if="$IMG_FILE" of="$SD_DEVICE" bs=4M conv=fsync status=progress || { echo " Flash failed."; exit 1; }

echo " OpenWrt has been written to $SD_DEVICE"
echo "➡️ Insert the SD card into your Raspberry Pi and power it up."
