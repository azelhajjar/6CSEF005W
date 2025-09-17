#!/bin/bash
# setup-radius-server.sh
# Install and configure FreeRADIUS for WPA2-Enterprise (PEAP/MSCHAPv2).
# Usage: sudo ./setup-radius-server.sh [--debug] [--verify] [--start]

set -euo pipefail

FILES_DIR="${FILES_DIR:-/home/kali/6CSEF005W/ap/files}"
AP_IP="${AP_IP:-192.168.140.1}"
RADIUS_SECRET_FILE="$FILES_DIR/radius.secret"
CLIENT_TMPL="$FILES_DIR/clients-6csef005w.conf.tmpl"
USERS_FILE_SRC="$FILES_DIR/radius-users"

DEBUG_MODE=0; VERIFY_MODE=0; START_MODE=0
for a in "$@"; do
  case "$a" in
    --debug)  DEBUG_MODE=1 ;;
    --verify) VERIFY_MODE=1 ;;
    --start)  START_MODE=1 ;;
  esac
done

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "[!] Run as root: sudo $0" >&2
  exit 1
fi

detect_layout() {
  if [ -d /etc/freeradius/3.0 ]; then echo "/etc/freeradius/3.0"
  elif [ -d /etc/freeradius ]; then echo "/etc/freeradius"
  else echo "/etc/freeradius/3.0"; fi
}
ETC="$(detect_layout)"
CLIENTS_D="$ETC/clients.d"; CLIENTS_CONF="$ETC/clients.conf"
MODS_AV="$ETC/mods-available"; MODS_EN="$ETC/mods-enabled"; MODS_CFG="$ETC/mods-config"
SERVICE_NAME="freeradius"

detect_group() {
  if getent group freerad >/dev/null; then echo "freerad"
  elif getent group radiusd >/dev/null; then echo "radiusd"
  else echo "freerad"; fi
}
FR_GROUP="$(detect_group)"

require_files() {
  [ -f "$RADIUS_SECRET_FILE" ] || { echo "[!] Missing: $RADIUS_SECRET_FILE"; exit 2; }
  [ -f "$USERS_FILE_SRC" ]    || { echo "[!] Missing: $USERS_FILE_SRC"; exit 2; }
}

install_pkgs() {
  echo "[*] Installing packages..."
  apt-get update -y
  DEBIAN_FRONTEND=noninteractive apt-get install -y freeradius freeradius-utils iptables-persistent
}

ensure_clients_include() {
  echo "[*] Rewriting clients.conf includes explicitly (no globs)..."
  touch "$CLIENTS_CONF"

  sed -i -E '/^\s*\$INCLUDE\s+.*clients\.d\/\*\.conf\s*$/d' "$CLIENTS_CONF"

  sed -i -E '/^\s*\$INCLUDE\s+clients\.d\/[A-Za-z0-9._-]+\.conf\s*$/d' "$CLIENTS_CONF"

  if ls "$CLIENTS_D"/*.conf >/dev/null 2>&1; then
    {
      echo "# (auto) explicit includes added by setup-radius-server.sh"
      for f in "$CLIENTS_D"/*.conf; do
        [ -f "$f" ] || continue
        echo "\$INCLUDE clients.d/$(basename "$f")"
      done
    } >> "$CLIENTS_CONF"
    echo "[i] Added explicit includes for files in $CLIENTS_D"
  else
    echo "[i] No .conf files in $CLIENTS_D yet."
  fi
}

fix_clients_dir_perms() {
  echo "[*] Fixing clients.d perms..."
  mkdir -p "$CLIENTS_D"
  chown root:"$FR_GROUP" "$CLIENTS_D" || true
  chmod 750 "$CLIENTS_D" || true
}

write_client_entry() {
  echo "[*] Writing AP client entry..."
  local secret; secret="$(tr -d '[:space:]' < "$RADIUS_SECRET_FILE")"
  [ -n "$secret" ] || { echo "[!] radius.secret empty"; exit 2; }

  local out="$CLIENTS_D/6csef005w.conf"
  if [ -f "$CLIENT_TMPL" ]; then
    sed -e "s#__RADIUS_SECRET__#${secret}#g" -e "s#__AP_IP__#${AP_IP}#g" "$CLIENT_TMPL" > "$out"
  else
    cat > "$out" <<EOF
client ap-6csef005w {
  ipaddr   = ${AP_IP}
  secret   = ${secret}
  nastype  = other
}
EOF
  fi
  chown root:"$FR_GROUP" "$out"; chmod 640 "$out"
}

ensure_localhost_client() {
  echo "[*] Ensuring localhost RADIUS client with correct secret..."
  local secret; secret="$(tr -d '[:space:]' < "$RADIUS_SECRET_FILE")"
  [ -n "$secret" ] || { echo "[!] radius.secret empty"; exit 2; }

  local candidates=()
  if [ -f "$CLIENTS_CONF" ]; then candidates+=("$CLIENTS_CONF"); fi
  if ls "$CLIENTS_D"/*.conf >/dev/null 2>&1; then
    for f in "$CLIENTS_D"/*.conf; do candidates+=("$f"); done
  fi

  local updated=0
  for f in "${candidates[@]}"; do
    if grep -qE 'ipaddr[[:space:]]*=[[:space:]]*127\.0\.0\.1' "$f"; then
      sed -i -E '/client[[:space:]]+[^}]+\{/,/}/ { /ipaddr[[:space:]]*=[[:space:]]*127\.0\.0\.1/,/}/ s/^[[:space:]]*secret[[:space:]]*=.*/\tsecret = '"$secret"'/' "$f"
      echo "[i] Updated localhost secret in: $f"
      updated=1
    fi
  done

  if [ "$updated" -eq 0 ]; then
    cat > "$CLIENTS_D/localhost.conf" <<EOF
client localhost {
  ipaddr = 127.0.0.1
  secret = ${secret}
  nastype = other
}
EOF
    chown root:"$FR_GROUP" "$CLIENTS_D/localhost.conf"; chmod 640 "$CLIENTS_D/localhost.conf"
    echo "[i] Created: $CLIENTS_D/localhost.conf"
  fi
}

enable_site_inner_tunnel() {
  echo "[*] Ensuring inner-tunnel site enabled..."
  if [ -d "$ETC/sites-available" ] && [ -d "$ETC/sites-enabled" ]; then
    if [ ! -e "$ETC/sites-enabled/inner-tunnel" ] && [ -e "$ETC/sites-available/inner-tunnel" ]; then
      ln -s "$ETC/sites-available/inner-tunnel" "$ETC/sites-enabled/inner-tunnel"
      echo "[i] Enabled inner-tunnel"
    else
      echo "[i] inner-tunnel already enabled"
    fi
  fi
}

install_users() {
  echo "[*] Installing users file..."
  cp -a "$USERS_FILE_SRC" "$ETC/users"
  chown root:"$FR_GROUP" "$ETC/users"; chmod 640 "$ETC/users"
}

fix_permissions() {
  echo "[*] Fixing mods-config/files perms..."
  if [ -d "$MODS_CFG/files" ]; then
    chown -R root:"$FR_GROUP" "$MODS_CFG/files"
    chmod 750 "$MODS_CFG/files"
    [ -f "$MODS_CFG/files/authorize" ] && chmod 640 "$MODS_CFG/files/authorize"
  fi
}

check_config() {
  echo "[*] Running freeradius -XC..."
  systemctl stop "$SERVICE_NAME" 2>/dev/null || true
  freeradius -XC || { echo "[!] freeradius -XC failed"; exit 3; }
}

restart_service() {
  if [ "$START_MODE" -eq 1 ]; then
    echo "[*] Starting and enabling service..."
    systemctl restart "$SERVICE_NAME"
    systemctl enable "$SERVICE_NAME"
    systemctl status --no-pager "$SERVICE_NAME" || true
  else
    echo "[i] Service not started. Use --start to enable after check."
  fi
}

enable_icmp_persistent() {
  echo "[*] Allowing ICMP echo-request..."
  iptables -I INPUT 1 -p icmp --icmp-type echo-request -j ACCEPT 2>/dev/null || true
  iptables-save > /etc/iptables/rules.v4
  command -v netfilter-persistent >/dev/null && netfilter-persistent save || true
}

summary() {
  echo "[OK] FreeRADIUS configured."
  echo " - ETC path:     $ETC"
  echo " - Clients dir:  $CLIENTS_D"
  echo " - Users file:   $ETC/users"
  echo " - inner-tunnel: enabled"
}

main() {
  require_files
  install_pkgs
  fix_clients_dir_perms
  write_client_entry
  ensure_localhost_client
  ensure_clients_include
  enable_site_inner_tunnel
  install_users
  fix_permissions
  check_config
  restart_service
  enable_icmp_persistent
  summary
}
main "$@"
