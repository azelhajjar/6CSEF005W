#!/bin/bash
# Author: Dr Ayman El hajjar
# File: ap/wpa2e-ap.sh
# WPA2-Enterprise WiFi Access Point with RADIUS authentication
# Extra files: files/radius-users, files/radius.secret and clients-6csef005w.conf.tmpl
# Tailing: Clients association + DHCP lease events (MAC/IP)
# Note: Change SSID variable to customize AP name, credentials managed in RADIUS files
set -euo pipefail
RESET=$'\033[0m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; CYAN=$'\033[0;36m'; RED=$'\033[0;31m'
info(){ printf "[${YELLOW}i${RESET}] %s\n" "$*"; }
ok(){ printf "[${GREEN}✓${RESET}] %s\n" "$*"; }
err(){ printf "[${RED}!${RESET}] %s\n" "$*" >&2; }

ENV_FILE="$(dirname "$0")/../.env"; [ -f "$ENV_FILE" ] && . "$ENV_FILE"

INTERFACE="${INTERFACE:-wlan0}"
AP_IP="${AP_IP:-192.168.140.1/24}"
AP_IP_BASE="${AP_IP_BASE:-192.168.140.1}"
REGDOM="${REGDOM:-GB}"
RUNTIME_DIR="${RUNTIME_DIR:-/home/kali/tmp_ap}"
COURSE_DIR="${COURSE_DIR:-$(dirname "$(dirname "$(realpath "$0")")")}"
FILES_DIR="${FILES_DIR:-$COURSE_DIR/ap/files}"
SSID="${SSID:-6CSEF005W-WPA2E-AP}"
CHANNEL="${CHANNEL:-8}"

RADIUS_ADDR="${RADIUS_ADDR:-127.0.0.1}"
RADIUS_PORT="${RADIUS_PORT:-1812}"
RADIUS_SECRET_FILE="${RADIUS_SECRET_FILE:-$FILES_DIR/radius.secret}"

require_root(){ [ "${EUID:-$(id -u)}" -eq 0 ] || { err "Run with sudo"; exit 1; }; }
cleanup_trap(){ info "CTRL-C received, tearing down..."; "$COURSE_DIR/ap/teardown-ap.sh" || true; exit 130; }
ensure_dirs(){ mkdir -p "$RUNTIME_DIR"; }

docheckbefore(){
  [ -f "$RADIUS_SECRET_FILE" ] || { err "Missing $RADIUS_SECRET_FILE"; exit 2; }
  RADIUS_SECRET="$(tr -d '[:space:]' < "$RADIUS_SECRET_FILE")"
  [ -n "$RADIUS_SECRET" ] || { err "Empty RADIUS secret"; exit 2; }
  
  # Check if FreeRADIUS is running, start if needed
  if ! systemctl is-active --quiet freeradius; then
    info "Starting FreeRADIUS service..."
    systemctl start freeradius || { err "Failed to start FreeRADIUS"; exit 2; }
    sleep 2
  fi
  
  info "Setting regdom $REGDOM"; iw reg set "$REGDOM" || true
  info "Resetting $INTERFACE"; ip link set "$INTERFACE" down 2>/dev/null || true
  
  # Set fixed MAC address FIRST, before any mode changes
  info "Setting fixed MAC address for consistent BSSID"
  ip link set dev "$INTERFACE" address 02:11:22:33:44:55
  
  iw dev "$INTERFACE" set type __ap 2>/dev/null || true
  ip addr flush dev "$INTERFACE" 2>/dev/null || true
  ip link set "$INTERFACE" up; sleep 1
  info "Assigning $AP_IP"; ip addr add "$AP_IP" dev "$INTERFACE" 2>/dev/null || true
}

write_hostapd_conf(){
  cat > "$RUNTIME_DIR/hostapd.conf" <<EOF
interface=$INTERFACE
driver=nl80211
ssid=$SSID
country_code=$REGDOM
ieee80211d=1
hw_mode=g
channel=$CHANNEL
auth_algs=1
wmm_enabled=1
ieee80211n=1

# WPA2-Enterprise
ieee8021x=1
wpa=2
wpa_key_mgmt=WPA-EAP
rsn_pairwise=CCMP
eapol_version=2
eap_server=0
auth_server_addr=$RADIUS_ADDR
auth_server_port=$RADIUS_PORT
auth_server_shared_secret=$RADIUS_SECRET
nas_identifier=$SSID

logger_syslog=-1
logger_syslog_level=2
logger_stdout=-1
logger_stdout_level=2
EOF
}

write_dnsmasq_conf(){
  cat > "$RUNTIME_DIR/dnsmasq.conf" <<EOF
interface=$INTERFACE
bind-interfaces
domain-needed
bogus-priv
dhcp-authoritative
dhcp-range=192.168.140.50,192.168.140.150,255.255.255.0,12h
dhcp-option=3,$AP_IP_BASE
dhcp-option=6,$AP_IP_BASE
no-resolv
log-dhcp
EOF
}

start_services(){
  info "Starting hostapd..."
  /usr/sbin/hostapd -B -P "$RUNTIME_DIR/hostapd.pid" -f "$RUNTIME_DIR/hostapd_wpa2e.log" "$RUNTIME_DIR/hostapd.conf"
  info "Starting dnsmasq..."
  pkill dnsmasq 2>/dev/null || true
  dnsmasq --conf-file="$RUNTIME_DIR/dnsmasq.conf" \
          --pid-file="$RUNTIME_DIR/dnsmasq.pid" \
          --log-facility="$RUNTIME_DIR/dnsmasq_wpa2e.log"
  ok "AP Enabled: SSID ${CYAN}${SSID}${RESET} on ${CYAN}${INTERFACE}${RESET} (${CYAN}${AP_IP_BASE}${RESET})"
  info "RADIUS: $RADIUS_ADDR:$RADIUS_PORT (secret from $RADIUS_SECRET_FILE)"
}

setup_unmanaged_interface() {
  local config_file="/etc/NetworkManager/conf.d/99-unmanaged-devices.conf"
  
  if grep -q "interface-name:$INTERFACE" "$config_file" 2>/dev/null; then
    info "NetworkManager already configured to ignore $INTERFACE"
    return
  fi
  
  info "Configuring NetworkManager to ignore $INTERFACE..."
  
  cat > "$config_file" <<EOF
[keyfile]
unmanaged-devices=interface-name:$INTERFACE
EOF
  
  systemctl restart NetworkManager
  sleep 2
  ok "NetworkManager configured to ignore $INTERFACE"
}
tail_clean(){
  info "Showing EAP + DHCP events..."
  stdbuf -oL -eL tail -F "$RUNTIME_DIR/hostapd_wpa2e.log" "$RUNTIME_DIR/dnsmasq_wpa2e.log" | \
  awk -v GREEN="$GREEN" -v CYAN="$CYAN" -v YELLOW="$YELLOW" -v RESET="$RESET" '
    /CTRL-EVENT-EAP-STARTED/ { 
      ts=strftime("%H:%M:%S"); mac=$NF;
      printf("[%s] %sEAP-START%s %s\n",ts,YELLOW,RESET,mac); fflush(); 
    }
    /CTRL-EVENT-EAP-SUCCESS/ { 
      ts=strftime("%H:%M:%S"); mac=$NF;
      printf("[%s] %sEAP-SUCCESS%s %s\n",ts,GREEN,RESET,mac); fflush(); 
    }
    /IEEE 802\.1X: authenticated.*EAP type:/ {
      ts=strftime("%H:%M:%S"); mac=$(NF-5);
      printf("[%s] %sEAP-AUTH%s %s (PEAP)\n",ts,GREEN,RESET,mac); fflush();
    }
    /AP-STA-CONNECTED/ { 
      mac=$NF; ts=strftime("%H:%M:%S"); 
      printf("[%s] %sCONNECT%s %s\n",ts,GREEN,RESET,mac); fflush(); 
    }
    /DHCPACK\(wlan0\)/ { 
      ts=strftime("%H:%M:%S"); ip=$5; mac=$6; host=$7; if (host=="") host="-";
      printf("[%s] %sDHCP%s %s -> %s %s\n",ts,CYAN,RESET,mac,ip,host); fflush(); 
    }
  '
}

main(){
  require_root
  setup_unmanaged_interface
  trap cleanup_trap INT TERM
  "$COURSE_DIR/ap/teardown-ap.sh" || true
  ensure_dirs
  docheckbefore
  write_hostapd_conf
  write_dnsmasq_conf
  start_services
  tail_clean
}
main "$@"
