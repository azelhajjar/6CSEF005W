#!/bin/bash
# Install and configure FreeRADIUS for WPA2-Enterprise (PEAP/MSCHAPv2)
# Reads secret and templates from /home/kali/6csef005w/ap/files

set -euo pipefail

FILES_DIR="/home/kali/6csef005w/ap/files"
RADIUS_SECRET_FILE="$FILES_DIR/radius.secret"
CLIENT_TMPL="$FILES_DIR/clients-6csef005w.conf.tmpl"
USERS_FILE_SRC="$FILES_DIR/radius-users"

ETC="/etc/freeradius/3.0"
CLIENTS_D="$ETC/clients.d"
MODS_AV="$ETC/mods-available"
MODS_EN="$ETC/mods-enabled"

require_root() {
  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo "[!] Please run as root (sudo $0)" >&2
    exit 1
  fi
}

require_files() {
  [ -f "$RADIUS_SECRET_FILE" ] || { echo "[!] Missing: $RADIUS_SECRET_FILE"; exit 2; }
  [ -f "$CLIENT_TMPL" ]       || { echo "[!] Missing: $CLIENT_TMPL"; exit 2; }
  [ -f "$USERS_FILE_SRC" ]    || { echo "[!] Missing: $USERS_FILE_SRC"; exit 2; }
}

install_pkgs() {
  apt-get update -y
  DEBIAN_FRONTEND=noninteractive apt-get install -y freeradius freeradius-utils
}

write_clients() {
  local secret
  secret="$(tr -d '[:space:]' < "$RADIUS_SECRET_FILE")"
  [ -n "$secret" ] || { echo "[!] radius.secret is empty"; exit 2; }

  mkdir -p "$CLIENTS_D"
  sed "s#__RADIUS_SECRET__#${secret}#g" "$CLIENT_TMPL" > "$CLIENTS_D/6csef005w.conf"
  echo "[i] Wrote $CLIENTS_D/6csef005w.conf (AP client 192.168.140.1)"
}

enable_eap_peap_mschapv2() {
  [ -e "$MODS_EN/eap" ]   || ln -s "$MODS_AV/eap"   "$MODS_EN/eap"
  [ -e "$MODS_EN/mschap" ]|| ln -s "$MODS_AV/mschap" "$MODS_EN/mschap"
  sed -i 's/^\s*#\?\s*default_eap_type\s*=.*/\tdefault_eap_type = peap/' "$MODS_AV/eap"
}

install_users() {
  cp -a "$ETC/users" "$ETC/users.bak.$(date +%s)"
  cat "$USERS_FILE_SRC" > "$ETC/users"
  echo "[i] Installed users into $ETC/users"
}

check_config() {
  echo "[i] Checking configuration..."
  freeradius -C
}

restart_service() {
  systemctl restart freeradius || systemctl restart freeradius.service
  systemctl enable freeradius || true
  systemctl status --no-pager freeradius || true
}

show_summary() {
  echo "[OK] FreeRADIUS configured for WPA2-Enterprise (PEAP/MSCHAPv2)."
  echo " - Clients file: $CLIENTS_D/6csef005w.conf (AP 192.168.140.1)"
  echo " - Users file:   $ETC/users"
  echo " - EAP method:   PEAP with inner MSCHAPv2"
}

main() {
  require_root
  require_files
  install_pkgs
  write_clients
  enable_eap_peap_mschapv2
  install_users
  check_config
  restart_service
  show_summary
}

main "$@"
