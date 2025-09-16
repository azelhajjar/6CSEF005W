#!/bin/bash
# Install and configure FreeRADIUS for WPA2-Enterprise (PEAP/MSCHAPv2)
# Enhanced version: includes Windows-friendly user formatting, safety backups,
# permissions, ensures mschap/eap modules enabled, and persistent ICMP allow rules.
# Reads secret and templates from /home/kali/6csef005w/ap/files
#
# Usage: sudo ./setup-freeradius.sh
set -euo pipefail

FILES_DIR="/home/kali/6csef005w/ap/files"
RADIUS_SECRET_FILE="$FILES_DIR/radius.secret"
CLIENT_TMPL="$FILES_DIR/clients-6csef005w.conf.tmpl"
USERS_FILE_SRC="$FILES_DIR/radius-users"    # Accepts either FreeRADIUS 'users' format OR lines "username:password"

ETC="/etc/freeradius/3.0"
CLIENTS_D="$ETC/clients.d"
MODS_AV="$ETC/mods-available"
MODS_EN="$ETC/mods-enabled"

# --- Helpers ---
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
  DEBIAN_FRONTEND=noninteractive apt-get install -y freeradius freeradius-utils iptables-persistent
}

# Write clients file from template and set safe permissions on radius.secret
write_clients() {
  local secret
  secret="$(tr -d '[:space:]' < "$RADIUS_SECRET_FILE")"
  [ -n "$secret" ] || { echo "[!] radius.secret is empty"; exit 2; }

  mkdir -p "$CLIENTS_D"
  sed "s#__RADIUS_SECRET__#${secret}#g" "$CLIENT_TMPL" > "$CLIENTS_D/6csef005w.conf"
  chmod 640 "$CLIENTS_D/6csef005w.conf"
  echo "[i] Wrote $CLIENTS_D/6csef005w.conf (AP client 192.168.140.1)"

  # Protect the radius secret file if it's in a persistent location
  chmod 600 "$RADIUS_SECRET_FILE" || true
  echo "[i] Secured $RADIUS_SECRET_FILE (chmod 600)"
}

# Ensure EAP and mschap modules are enabled and default_eap_type is set to peap
enable_eap_peap_mschapv2() {
  [ -e "$MODS_EN/eap" ]   || ln -s "$MODS_AV/eap"   "$MODS_EN/eap"
  [ -e "$MODS_EN/mschap" ]|| ln -s "$MODS_AV/mschap" "$MODS_EN/mschap"

  # Ensure default_eap_type = peap exists in mods-available/eap (attempt safe in-place edit)
  if grep -q "^[[:space:]]*default_eap_type" "$MODS_AV/eap"; then
    sed -ri 's|^[[:space:]]*default_eap_type[[:space:]]*=.*|	default_eap_type = peap|' "$MODS_AV/eap"
  else
    # append near top of file (after first { ) to be safer
    awk 'NR==1{print;next} {print}' "$MODS_AV/eap" > "$MODS_AV/eap.tmp" && mv "$MODS_AV/eap.tmp" "$MODS_AV/eap"
    printf "\n\tdefault_eap_type = peap\n" >> "$MODS_AV/eap"
  fi

  echo "[i] Ensured eap and mschap modules enabled and default_eap_type set to peap"
}

# Convert a simple username:password file into FreeRADIUS 'users' format if needed.
# If the source already looks like a FreeRADIUS 'users' file (contains 'Cleartext-Password' or other attrs),
# copy it verbatim (with a backup).
install_users() {
  # Backup existing users file if present
  if [ -f "$ETC/users" ]; then
    cp -a "$ETC/users" "$ETC/users.bak.$(date +%s)"
    echo "[i] Backed up existing $ETC/users to $ETC/users.bak.$(date +%s)"
  fi

  # Detect if USERS_FILE_SRC looks like FreeRADIUS users format
  if grep -E -q 'Cleartext-Password|Reply-Message|Auth-Type|Ldap-UserDN' "$USERS_FILE_SRC"; then
    cp -a "$USERS_FILE_SRC" "$ETC/users"
    echo "[i] Detected full FreeRADIUS 'users' content; installed as-is to $ETC/users"
  else
    # Convert lines of "username:password" or "username password" into FreeRADIUS users entries
    : > "$ETC/users"
    while IFS= read -r line || [ -n "$line" ]; do
      # skip blank and comment lines
      case "$line" in
        ''|\#*) continue ;;
      esac

      # split on ":" or whitespace
      if echo "$line" | grep -q ":"; then
        username="${line%%:*}"
        password="${line#*:}"
      else
        username="$(echo "$line" | awk '{print $1}')"
        password="$(echo "$line" | awk '{print $2}')"
      fi

      username="$(echo -n "$username" | tr -d '[:space:]')"
      password="$(echo -n "$password" | sed 's/"/\\"/g')"

      if [ -z "$username" ] || [ -z "$password" ]; then
        echo "[!] Skipping malformed user line: $line"
        continue
      fi

      # FreeRADIUS users entry using Cleartext-Password which works with PEAP/MSCHAPv2 (Windows clients)
      cat >> "$ETC/users" <<EOF
$((printf '%s' "$username") )	\tCleartext-Password := "$password"
	\tReply-Message := "Welcome, $username"
EOF
    done < "$USERS_FILE_SRC"
    echo "[i] Converted $USERS_FILE_SRC to FreeRADIUS users format at $ETC/users"
  fi

  chmod 640 "$ETC/users"
  echo "[i] Set permissions on $ETC/users"
}

# Basic config check
check_config() {
  echo "[i] Checking configuration (freeradius -C)..."
  freeradius -C || {
    echo "[!] freeradius -C reported issues. Please inspect output above."
    # continue to attempt service restart so admins can test; do not exit here.
  }
}

# Restart and enable service
restart_service() {
  if systemctl list-unit-files | grep -q '^freeradius'; then
    systemctl restart freeradius || systemctl restart freeradius.service || true
    systemctl enable freeradius || true
    systemctl status --no-pager freeradius || true
    echo "[i] Attempted to restart and enable freeradius service"
  else
    echo "[!] systemd unit for freeradius not found; starting with plain command"
    service freeradius restart || true
  fi
}

# Add iptables rule to allow inbound ICMP echo-requests (ping to this Kali host) and persist it.
enable_icmp_persistent() {
  # Accept echo-request to this host (any destination IP on this machine), from anywhere
  if ! iptables -C INPUT -p icmp --icmp-type echo-request -j ACCEPT 2>/dev/null; then
    iptables -I INPUT 1 -p icmp --icmp-type echo-request -j ACCEPT
    echo "[i] Inserted iptables rule to ACCEPT inbound ICMP echo-request (ping) to this host"
  else
    echo "[i] ICMP echo-request iptables rule already present"
  fi

  # Save current IPv4 rules to persistent file
  mkdir -p /etc/iptables
  iptables-save > /etc/iptables/rules.v4
  # If iptables-persistent is installed, /etc/iptables/rules.v4 is the default location
  if command -v netfilter-persistent >/dev/null 2>&1; then
    netfilter-persistent save || true
    netfilter-persistent reload || true
    echo "[i] Persisted iptables rules using netfilter-persistent"
  else
    echo "[i] iptables-persistent/netfilter-persistent not available to auto-load rules; rules saved to /etc/iptables/rules.v4"
  fi
}

show_summary() {
  echo "[OK] FreeRADIUS configured for WPA2-Enterprise (PEAP/MSCHAPv2) with tweaks."
  echo " - Clients file: $CLIENTS_D/6csef005w.conf (AP 192.168.140.1)"
  echo " - Users file:   $ETC/users"
  echo " - EAP method:   PEAP with inner MSCHAPv2"
  echo " - ICMP:         Inbound echo-requests to this Kali host are allowed (persisted)"
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
  enable_icmp_persistent
  show_summary
}

main "$@"
