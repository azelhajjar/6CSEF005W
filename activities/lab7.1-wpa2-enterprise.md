
## Module Code: 6CSEF005W  
**Module name:** Wireless Network Security  
**Lab activity:** WPA2-Enterprise AP and EAP Authentication  
**Author:** Dr Ayman El Hajjar  

---

#  Lab Activity: WPA2-Enterprise Access Point with FreeRADIUS

---

###  Objective

In this lab, you will configure and test a WPA2-Enterprise wireless network using a Raspberry Pi Access Point and a FreeRADIUS server. You'll connect using EAP authentication with test credentials.

---

##  Environment Setup

| Role        | Device / OS         | Details                          |
|-------------|----------------------|----------------------------------|
| AP          | Raspberry Pi         | hostapd + dnsmasq                |
| Radius      | Same Pi or separate  | FreeRADIUS                       |
| Client      | Kali or Linux device | connects using EAP credentials   |

---

##  Step 1: Setup Radius Server

Run this script on the Radius Pi:

```bash
sudo ./setup_pi_radius_server.sh
```

> This will:
> - Install FreeRADIUS
> - Configure clients.conf to accept requests from AP Pi (`192.168.140.1`)
> - Load user credentials from `users_list.txt`

---

##  Step 2: Launch WPA2-Enterprise Access Point

From the AP Pi, run:

```bash
sudo ./setup_wpa2_enterprise_ap.sh
```

This configures `hostapd` to use WPA2-EAP and point to the Radius server at `192.168.140.2`.

---

##  Step 3: Connect from a Client

From a Linux client:

1. Ensure `wpa_supplicant` is installed.
2. Create a configuration file:

```bash
cat > /tmp/wpa_enterprise.conf << EOF
network={
    ssid="6CSEF005W_WPA2_ENTERPRISE_AP"
    key_mgmt=WPA-EAP
    eap=PEAP
    identity="student1"
    password="password123"
    phase2="auth=MSCHAPV2"
}
EOF
```

3. Connect:

```bash
sudo wpa_supplicant -i wlan0 -c /tmp/wpa_enterprise.conf -B
sudo dhclient wlan0
```

---

##  Verification

From the Radius Pi:

```bash
sudo tail -f /var/log/freeradius/radius.log
```

> You should see Access-Accept for the client.

---

##
 Discussion Points

- Why is EAP more secure than WPA2-PSK?
- What happens if credentials are leaked?
- Can you sniff EAP traffic with Wireshark?

---

##
 Cleanup

On AP:

```bash
sudo ./teardown_ap.sh
```

On client:

```bash
sudo pkill wpa_supplicant
sudo ip link set wlan0 down
sudo ip addr flush dev wlan0
sudo ip link set wlan0 up
```

---

##  Optional Screenshots

Include in `tasks/img/`:
- FreeRADIUS logs showing successful authentication
- `hostapd.log` output from AP
- Client-side wpa_supplicant log

---

## Summary


| Step     | Tool / File             | Purpose                              |
|----------|-------------------------|--------------------------------------|
| Setup    | `setup_pi_radius_server.sh` | Radius server with user credentials |
| AP       | `setup_wpa2_enterprise_ap.sh` | WPA2-Enterprise using EAP auth     |
| Connect  | `wpa_supplicant`        | EAP connection from client           |
| Log      | `radius.log`, `hostapd.log` | Confirm successful connection      |

---
