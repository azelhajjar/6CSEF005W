#!/bin/bash
# teardown-ap.sh
# Stop hostapd/dnsmasq started by lab scripts, clear IPs,
# reset wlan0 to managed, and clean runtime files.

set -euo pipefail

# Load .env if present
ENV_FILE="$(dirname "$0")/.env"
if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  . "$ENV_FILE"
fi

INTERFACE="${INTERFACE:-wlan0}"
RUNTIME_DIR="${RUNTIME_DIR:-/home/kali/tmp_ap}"

require_root() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo "[!] Please run as root (use: sudo $0)"
    exit 1
  fi
}

stop_daemon_by_pid() {
  local name="$1"
  local pidfile="$2"
  if [ -f "$pidfile" ]; then
    local pid
    pid="$(cat "$pidfile" 2>/dev/null || true)"
    if [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null; then
      echo "[i] Stopping $name (pid $pid)..."
      kill "$pid" || true
      sleep 1
      if kill -0 "$pid" 2>/dev/null; then
        echo "[i] Sending SIGKILL to $name (pid $pid)..."
        kill -9 "$pid" || true
      fi
    fi
    rm -f "$pidfile"
  fi
}

stop_daemons() {
  echo "[i] Stopping daemons if running..."
  stop_daemon_by_pid "hostapd"   "$RUNTIME_DIR/hostapd.pid"
  stop_daemon_by_pid "dnsmasq"   "$RUNTIME_DIR/dnsmasq.pid"

  # Fallback: kill any instance bound to our runtime config directory
  pgrep -a hostapd 2>/dev/null | grep -q "$RUNTIME_DIR" && pkill -f "$RUNTIME_DIR" || true
  pgrep -a dnsmasq 2>/dev/null | grep -q "$RUNTIME_DIR" && pkill -f "$RUNTIME_DIR" || true
}

reset_interface() {
  echo "[i] Resetting interface $INTERFACE..."
  ip link set "$INTERFACE" down 2>/dev/null || true
  # Return to managed type in case it was set to __ap or monitor
  iw dev "$INTERFACE" set type managed 2>/dev/null || true
  # Flush any IPs and routes
  ip addr flush dev "$INTERFACE" 2>/dev/null || true
  ip link set "$INTERFACE" up 2>/dev/null || true
}

clean_runtime() {
  echo "[i] Cleaning runtime files in $RUNTIME_DIR..."
  rm -f "$RUNTIME_DIR/hostapd.conf" \
        "$RUNTIME_DIR/dnsmasq.conf" \
        "$RUNTIME_DIR/hostapd.pid" \
        "$RUNTIME_DIR/dnsmasq.pid" \
        "$RUNTIME_DIR/hostapd_cli.sock" \
        "$RUNTIME_DIR"/hostapd_*.log \
        "$RUNTIME_DIR"/dnsmasq_*.log \
        "$RUNTIME_DIR"/.state_* 2>/dev/null || true
}

main() {
  require_root
  echo "[*] Teardown starting..."
  stop_daemons
  reset_interface
  clean_runtime
  echo "[✓] Teardown complete. $INTERFACE is up in managed mode with no IP."
}

main "$@"
