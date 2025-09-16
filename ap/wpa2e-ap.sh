#!/bin/bash
# /home/kali/6csef005w/ap/wpa2e-ap.sh
# Start a WPA2-Enterprise (802.1X) AP with hostapd + dnsmasq on a VM using wlan0.
# Files (secrets, etc.): /home/kali/6csef005w/ap/files
# Runtime files/logs:     /home/kali/tmp_ap
# Structure, env, colours, teardown, and tail logic identical to open-ap.sh

set -euo pipefail

RESET=$'\033[0m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
CYAN=$'\033[0;36m'
RED=$'\033[0;31m'

info()    { printf "%b\n" "[${YELLOW}i${RESET}] $*"; }
ok()      { printf "%b\n" "[${GREEN}✓${RESET}] $*"; }
err()     { printf "%b\n" "[${RED}!${RESET}] $*" 1>&2; }

# --- Environment variables (same as open-ap.sh) ---
ENV_FILE="$(dirname "$0")/../.env"
[ -f "$ENV_FILE" ] && . "$ENV_FILE"

INTERFACE="${INTERFACE:-wlan0}"
AP_IP="${AP_IP:-192.168.140.1/24}"
AP_IP_BASE="${AP_IP_BASE:-192.168.140.1}"
REGDOM="${REGDOM:-GB}"
RUNTIME_DIR="${RUNTIME_DIR:-/home/kali/tmp_ap}"
COURSE_DIR="${COURSE_DIR:-/home/kali/6csef005w}"
SSID="${SSID:-6CSEF005W-WPA2E-AP}"
CHANNEL="${CHANNEL:-6}"

# --- WPA2-Enterprise (RADIUS) settings ---
# Use external RADIUS server (e.g., FreeRADIUS). Secret is read from a file under ap/files.
RADIUS_ADDR="${RADIUS_ADDR:-192.168.140.1}"
RADIUS_PORT="${RADIUS_PORT:-1812}"
RADIUS_SECRET_FILE="${RADIUS_SECRET_FILE:-$COURSE_DIR/ap/files/radius.secret}"

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
  mkdir -p "$(dirname "$RADIUS_SECRET_FILE")"
}

preflight() {
  if [ ! -f "$RADIUS_SECRET_FILE" ]; then
    err "Missing RADIUS secret file: $RADIUS_SECRET_FILE"
    err "Create it with the shared secret used by the RADIUS server (single line)."
    exit 2
  fi
  RADIUS_SECRET="$(tr -d '[:space:]' < "$RADIUS_SECRET_FILE")"
  if [ -z "${RADIUS_SECRET}" ]; then
    err "RADIUS secret file is empty: $RADIUS_SECRET_FILE"
    exit 2
  fi

  info "Setting regulatory domain: $REGDOM"
  iw reg set "$REGDOM" || true

  info "Resetting interface state: $INTERFACE"
  ip link set "$INTERFACE" down 2>/dev/null || true
  iw dev "$INTERFACE" set type __ap 2>/dev/null || true
  ip addr flush dev "$INTERFACE" 2>/dev/null || true
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
auth_algs=1
wmm_enabled=0
ignore_broadcast_ssid=0

# WPA2-Enterprise (802.1X with external RADIUS)
ieee8021x=1
wpa=2
wpa_key_mgmt=WPA-EAP
rsn_pairwise=CCMP

eapol_version=2
eap_server=0
auth_server_addr=$RADIUS_ADDR
auth_server_port=1812
auth_server_shared_secret=$(tr -d "[:space:]" < "$COURSE_DIR/ap/files/radius.secret")
# (Optional accounting; enable if your RADIUS has acct configured)
# acct_server_addr=$RADIUS_ADDR
# acct_server_port=1813
# acct_server_shared_secret=$RADIUS_SECRET

nas_identifier=$SSID
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
  /usr/sbin/hostapd -B -P "$RUNTIME_DIR/hostapd.pid" -f "$RUNTIME_DIR/hostapd_wpa2e.log" "$RUNTIME_DIR/hostapd.conf"

  info "Starting dnsmasq..."
  pkill dnsmasq 2>/dev/null || true
  dnsmasq --conf-file="$RUNTIME_DIR/dnsmasq.conf" \
          --pid-file="$RUNTIME_DIR/dnsmasq.pid" \
          --log-facility="$RUNTIME_DIR/dnsmasq_wpa2e.log"

  ok "AP Enabled: SSID ${CYAN}${SSID}${RESET} on ${CYAN}${INTERFACE}${RESET} (${CYAN}${AP_IP_BASE}${RESET})"
  info "RADIUS: ${RADIUS_ADDR}:${RADIUS_PORT} (secret from ${RADIUS_SECRET_FILE})"
  info "Logs: hostapd=${RUNTIME_DIR}/hostapd_wpa2e.log  dnsmasq=${RUNTIME_DIR}/dnsmasq_wpa2e.log"
}

tail_clean() {
  info "Showing connections and DHCP leases (Ctrl-C to stop)..."
  stdbuf -oL -eL tail -F "$RUNTIME_DIR/hostapd_wpa2e.log" "$RUNTIME_DIR/dnsmasq_wpa2e.log" | \
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
