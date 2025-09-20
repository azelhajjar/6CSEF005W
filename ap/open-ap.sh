#!/bin/bash
# /home/kali/6csef005w/ap/open-ap.sh
# Start an OPEN AP with hostapd + dnsmasq on a VM using wlan0.
# Runtime files/logs: /home/kali/tmp_ap
# Tailing: Clients association + DHCP lease events (MAC/IP)

set -euo pipefail

RESET=$'\033[0m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
CYAN=$'\033[0;36m'
RED=$'\033[0;31m'


info()    { printf "[${YELLOW}i${RESET}] %s\n" "$*"; }
ok()      { printf "[${GREEN}✓${RESET}] %s\n" "$*"; }
err()     { printf "[${RED}!${RESET}] %s\n" "$*" 1>&2; }

# ---Envrionment variables(check for AP changes in class------
ENV_FILE="$(dirname "$0")/../.env"
[ -f "$ENV_FILE" ] && . "$ENV_FILE"

INTERFACE="${INTERFACE:-wlan0}"
AP_IP="${AP_IP:-192.168.140.1/24}"
AP_IP_BASE="${AP_IP_BASE:-192.168.140.1}"
REGDOM="${REGDOM:-GB}"
RUNTIME_DIR="${RUNTIME_DIR:-/home/kali/tmp_ap}"
COURSE_DIR="${COURSE_DIR:-/home/kali/6CSEF005W}"
SSID="${SSID:-6CSEF005W_OPEN_AP}"
CHANNEL="${CHANNEL:-6}"

require_root() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    err "Please run as root (sudo $0)"
    exit 1
  fi
}

cleanup_trap() {
  info "CTRL-C received: tearing down AP..."
  "$COURSE_DIR/ap/teardown-ap.sh" || true
  exit 130
}

ensure_dirs() {
  mkdir -p "$RUNTIME_DIR"
}

preflight() {
  info "Setting regulatory domain: $REGDOM"
  iw reg set "$REGDOM" || true

  info "Resetting interface state: $INTERFACE"
  ip link set "$INTERFACE" down 2>/dev/null || true
  iw dev "$INTERFACE" set type managed 2>/dev/null || true
  ip addr flush dev "$INTERFACE" 2>/dev/null || true
  
  # Set fixed MAC address for consistent BSSID
  info "Setting fixed MAC address for consistent BSSID"
  ip link set dev "$INTERFACE" address 02:11:22:33:44:55
  
  ip link set "$INTERFACE" up
  sleep 1
  
  ip link set "$INTERFACE" down 2>/dev/null || true
  iw dev "$INTERFACE" set type __ap 2>/dev/null || true
  
  # Set MAC again after AP mode change
  ip link set dev "$INTERFACE" address 02:11:22:33:44:55
  
  ip link set "$INTERFACE" up
  sleep 1

  info "Assigning static IP: $AP_IP"
  ip addr add "$AP_IP" dev "$INTERFACE" 2>/dev/null || true
}

write_hostapd_conf() {
  cat > "$RUNTIME_DIR/hostapd.conf" <<EOF
interface=$INTERFACE
driver=nl80211
ssid=$SSID
hw_mode=g
channel=$CHANNEL
bssid=02:11:22:33:44:55
auth_algs=1
wmm_enabled=0
ignore_broadcast_ssid=0
logger_syslog=-1
logger_syslog_level=2
logger_stdout=-1
logger_stdout_level=2
EOF
}

write_dnsmasq_conf() {
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

start_services() {
  info "Starting hostapd..."
  /usr/sbin/hostapd -B -P "$RUNTIME_DIR/hostapd.pid" -f "$RUNTIME_DIR/hostapd_open.log" "$RUNTIME_DIR/hostapd.conf"

  info "Starting dnsmasq..."
  pkill dnsmasq 2>/dev/null || true
  dnsmasq --conf-file="$RUNTIME_DIR/dnsmasq.conf" \
          --pid-file="$RUNTIME_DIR/dnsmasq.pid" \
          --log-facility="$RUNTIME_DIR/dnsmasq_open.log"

  ok "AP Enabled: SSID ${CYAN}${SSID}${RESET} on ${CYAN}${INTERFACE}${RESET} (${CYAN}${AP_IP_BASE}${RESET})"
  ok "Fixed BSSID: ${CYAN}02:11:22:33:44:55${RESET}"
  info "Logs: hostapd=${RUNTIME_DIR}/hostapd_open.log  dnsmasq=${RUNTIME_DIR}/dnsmasq_open.log"
}

tail_clean() {
  info "Showing connections and DHCP leases (Ctrl-C to stop)..."
  stdbuf -oL -eL tail -F "$RUNTIME_DIR/hostapd_open.log" "$RUNTIME_DIR/dnsmasq_open.log" | \
  awk -v GREEN="$GREEN" -v CYAN="$CYAN" -v RESET="$RESET" '
    /AP-STA-CONNECTED/ {
      mac=$NF; ts=strftime("%H:%M:%S");
      printf("[%s] %sCONNECT%s %s\n", ts, GREEN, RESET, mac); fflush();
    }
    /DHCPACK\(wlan0\)/ {
      ts=strftime("%H:%M:%S");
      ip=$5; mac=$6; host=$7; if (host=="") host="-";
      printf("[%s] %sDHCP%s %s -> %s %s\n", ts, CYAN, RESET, mac, ip, host); fflush();
    }
  '
}

main() {
  require_root
  trap cleanup_trap INT TERM
  "$COURSE_DIR/ap/teardown-ap.sh" || true
  ensure_dirs
  preflight
  write_hostapd_conf
  write_dnsmasq_conf
  start_services
  tail_clean
}

main "$@"