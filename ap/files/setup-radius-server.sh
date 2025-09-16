#!/bin/bash
# setup-freeradius.sh
# Install and configure FreeRADIUS for WPA2-Enterprise (PEAP/MSCHAPv2) on fresh Debian/Ubuntu/Kali VMs.
# Usage:
#   sudo ./setup-freeradius.sh [--debug] [--verify]
#
# Environment overrides:
#   FILES_DIR=/path/to/files  (default: /home/kali/6CSEF005W/ap/files)
#   AP_IP=192.168.140.1       (default: 192.168.140.1)

set -euo pipefail

FILES_DIR="${FILES_DIR:-/home/kali/6CSEF005W/ap/files}"
AP_IP="${AP_IP:-192.168.140.1}"
RADIUS_SECRET_FILE="$FILES_DIR/radius.secret"
CLIENT_TMPL="$FILES_DIR/clients-6csef005w.conf.tmpl"
USERS_FILE_SRC="$FILES_DIR/radius-users"

DEBUG_MODE=0
VERIFY_MODE=0
for a in "$@"; do
  case "$a" in
    --debug)  DEBUG_MODE=1 ;;
    --verify) VERIFY_MODE=1 ;;
  esac
done

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "[!] Please run as root: sudo $0" >&2
  exit 1
fi

detect_layout() {
  if [ -d /etc/freeradius/3.0 ]; then
    echo "/etc/freeradius/3.0"
  elif [ -d /etc/freeradius ]; then
    echo "/etc/freeradius"
  else
    echo "/etc/freeradius/3.0"
  fi
}
ETC="$(detect_layout)"
CLIENTS_D="$ETC/clients.d"
CLIENTS_CONF="$ETC/clients.conf"
MODS_AV="$ETC/mods-available"
MODS_EN="$ETC/mods-enabled"
MODS_CFG="$ETC/mods-config"

detect_group() {
  if getent group freerad >/dev/null; then
    echo "freerad"
  elif getent group radiusd >/dev/null; then
    echo "radiusd"
  else
    echo "freerad"
  fi
}
FR_GROUP="$(detect_group)"
SERVICE_NAME="freeradius"

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
  echo "[*] Ensuring clients.d/*.conf is included by clients.conf..."
  touch "$CLIENTS_CONF"
  if ! grep -Eq '^\$INCLUDE[[:space:]]+clients\.d/\*\.conf' "$CLIENTS_CONF"; then
    printf '%s\n' '$INCLUDE clients.d/*.conf' >> "$CLIENTS_CONF"
    echo "[i] Added: \$INCLUDE clients.d/*.conf to $CLIENTS_CONF"
  else
    echo "[i] Include already present"
  fi
}

fix_clients_dir_perms() {
  echo "[*] Fixing clients.d directory ownership and permissions..."
  mkdir -p "$CLIENTS_D"
  chown root:"$FR_GROUP" "$CLIENTS_D" || true
  chmod 750 "$CLIENTS_D" || true
}

write_client_entry() {
  echo "[*] Writing clients.d entry..."
  local secret
  secret="$(tr -d '[:space:]' < "$RADIUS_SECRET_FILE")"
  [ -n "$secret" ] || { echo "[!] radius.secret is empty"; exit 2; }

  local out="$CLIENTS_D/6csef005w.conf"
  if [ -f "$CLIENT_TMPL" ]; then
    sed -e "s#__RADIUS_SECRET__#${secret}#g" \
        -e "s#__AP_IP__#${AP_IP}#g" \
        "$CLIENT_TMPL" > "$out"
  else
    cat > "$out" <<EOF
client ap-6csef005w {
  ipaddr   = ${AP_IP}
  secret   = ${secret}
  nas_type = other
}
EOF
  fi
  chown root:"$FR_GROUP" "$out" || true
  chmod 640 "$out"
}

enable_modules_and_peap() {
  echo "[*] Enabling modules (eap, mschap, files) and setting default_eap_type = peap..."
  mkdir -p "$MODS_EN" "$MODS_AV"
  [ -e "$MODS_EN/eap" ]    || [ ! -e "$MODS_AV/eap" ]    || ln -s "$MODS_AV/eap"    "$MODS_EN/eap"
  [ -e "$MODS_EN/mschap" ] || [ ! -e "$MODS_AV/mschap" ] || ln -s "$MODS_AV/mschap" "$MODS_EN/mschap"
  [ -e "$MODS_EN/files" ]  || [ ! -e "$MODS_AV/files" ]  || ln -s "$MODS_AV/files"  "$MODS_EN/files"

  if [ -f "$MODS_AV/eap" ]; then
    if grep -Eq '^[[:space:]]*default_eap_type[[:space:]]*=' "$MODS_AV/eap"; then
      sed -ri 's|^[[:space:]]*default_eap_type[[:space:]]*=.*|        default_eap_type = peap|' "$MODS_AV/eap"
    else
      awk '
        BEGIN{ins=0}
        /^\s*eap\s*\{/ { print; print "        default_eap_type = peap"; ins=1; next }
        { print }
        END{ if(!ins) print "        default_eap_type = peap" }
      ' "$MODS_AV/eap" > "$MODS_AV/eap.tmp" && mv "$MODS_AV/eap.tmp" "$MODS_AV/eap"
    fi
  fi
}

install_users() {
  echo "[*] Installing users file..."
  local users_path="$ETC/users"
  if [ -f "$users_path" ]; then
    cp -a "$users_path" "$users_path.bak.$(date +%s)"
    echo "[i] Backed up $users_path"
  fi

  if grep -Eq 'Cleartext-Password|Reply-Message|Auth-Type|Ldap-UserDN' "$USERS_FILE_SRC"; then
    cp -a "$USERS_FILE_SRC" "$users_path"
    echo "[i] Detected FreeRADIUS 'users' format; copied as-is."
  else
    : > "$users_path"
    while IFS= read -r line || [ -n "$line" ]; do
      case "$line" in ''|\#*) continue ;; esac
      local username password
      if printf '%s' "$line" | grep -q ':'; then
        username="${line%%:*}"; password="${line#*:}"
      else
        username="$(printf '%s' "$line" | awk '{print $1}')"
        password="$(printf '%s' "$line" | awk '{print $2}')"
      fi
      username="$(printf '%s' "$username" | tr -d '[:space:]')"
      password="$(printf '%s' "$password" | sed 's/"/\\"/g')"
      [ -n "$username" ] && [ -n "$password" ] || { echo "[!] Skipping malformed: $line"; continue; }
      printf '%s\tCleartext-Password := "%s"\n' "$username" "$password" >> "$users_path"
      printf '\tReply-Message := "Welcome, %s"\n\n' "$username" >> "$users_path"
    done < "$USERS_FILE_SRC"
    echo "[i] Converted simple list to FreeRADIUS users format."
  fi

  chown root:"$FR_GROUP" "$users_path" || true
  chmod 640 "$users_path"
}

fix_permissions() {
  echo "[*] Fixing mods-config/files ownership and modes..."
  if [ -d "$MODS_CFG/files" ]; then
    chown -R root:"$FR_GROUP" "$MODS_CFG/files" || true
    chmod 750 "$MODS_CFG/files" || true
    [ -f "$MODS_CFG/files/authorize" ] && chmod 640 "$MODS_CFG/files/authorize" || true
  fi
  usermod -a -G ssl-cert "$FR_GROUP" 2>/dev/null || true
}

sanity_clients_glob() {
  echo "[*] Verifying clients.d glob visibility..."
  # List dir and show printable/escaped names
  ls -ld "$CLIENTS_D"
  ls -la "$CLIENTS_D"
  ls -b  "$CLIENTS_D"
  # Root shell glob test
  bash -c 'for f in '"$CLIENTS_D"'/*.conf; do echo "MATCH:$f"; done'
  # Directory stat for traverse permissions
  stat -c 'dir=%n owner=%U group=%G mode=%A' "$CLIENTS_D"
}

check_config() {
  echo "[*] Running config checks..."
  # Stop to free the port then run extended check with full context
  systemctl stop "$SERVICE_NAME" 2>/dev/null || true
  if ! freeradius -XC; then
    echo "[!] freeradius -XC reported issues (see above)."
  fi
}

restart_service() {
  echo "[*] Starting and enabling service..."
  systemctl restart "$SERVICE_NAME" || systemctl restart "$SERVICE_NAME".service || true
  systemctl enable "$SERVICE_NAME" || true
  systemctl status --no-pager "$SERVICE_NAME" || true
}

enable_icmp_persistent() {
  echo "[*] Ensuring ICMP echo-request is allowed and persisted..."
  if ! iptables -C INPUT -p icmp --icmp-type echo-request -j ACCEPT 2>/dev/null; then
    iptables -I INPUT 1 -p icmp --icmp-type echo-request -j ACCEPT
    echo "[i] Inserted iptables rule"
  fi
  mkdir -p /etc/iptables
  iptables-save > /etc/iptables/rules.v4
  if command -v netfilter-persistent >/dev/null 2>&1; then
    netfilter-persistent save || true
    netfilter-persistent reload || true
  fi
}

verify_outputs() {
  echo "----- VERIFY: systemd failure context (if any) -----"
  systemctl status "$SERVICE_NAME" --no-pager || true
  journalctl -xeu "$SERVICE_NAME".service --no-pager | tail -n 80 || true

  echo "----- VERIFY: clients.conf include lines -----"
  sed -n '1,200p' "$CLIENTS_CONF" | nl -ba | sed -n '1,120p'
  grep -n '^\$INCLUDE[[:space:]]\+clients\.d/\*\.conf' "$CLIENTS_CONF" || echo "MISSING: \$INCLUDE clients.d/*.conf"

  echo "----- VERIFY: client file syntax -----"
  sed -n '1,120p' "$CLIENTS_D/6csef005w.conf" || true

  echo "----- VERIFY: critical permissions -----"
  ls -l "$CLIENTS_D/6csef005w.conf" 2>/dev/null || true
  ls -l "$ETC/users" 2>/dev/null || true
  [ -e "$MODS_EN/files" ] || ln -s "$MODS_AV/files" "$MODS_EN/files"
  ls -ld "$MODS_CFG/files" 2>/dev/null || true
  ls -l "$MODS_CFG/files/authorize" 2>/dev/null || true

  echo "----- VERIFY: final freeradius -XC -----"
  freeradius -XC || true
}

maybe_debug() {
  if [ "$DEBUG_MODE" -eq 1 ]; then
    echo "[*] Launching FreeRADIUS in foreground debug (freeradius -X)..."
    systemctl stop "$SERVICE_NAME" || true
    exec freeradius -X
  fi
}

summary() {
  echo "[OK] FreeRADIUS configured for WPA2-Enterprise (PEAP/MSCHAPv2)."
  echo " - ETC path:     $ETC"
  echo " - Clients file: $CLIENTS_D/6csef005w.conf (AP $AP_IP)"
  echo " - Users file:   $ETC/users"
  echo " - Modules:      eap, mschap, files (PEAP enforced)"
  echo " - ICMP:         Inbound echo-requests allowed and persisted"
  [ "$DEBUG_MODE" -eq 1 ] || echo " - Debug:        Run '$0 --debug' to start freeradius -X"
}

main() {
  require_files
  install_pkgs
  ensure_clients_include
  fix_clients_dir_perms
  write_client_entry
  enable_modules_and_peap
  install_users
  fix_permissions
  sanity_clients_glob
  check_config
  restart_service
  enable_icmp_persistent
  [ "$VERIFY_MODE" -eq 1 ] && verify_outputs
  summary
  maybe_debug
}

main "$@"
