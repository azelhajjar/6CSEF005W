
## Module Code: 6CSEF005W  
**Module name:** Wireless Network Security  
**Lab activity:** Evil Twin Access Point & Credential Capture  
**Author:** Dr Ayman El Hajjar  

---

# Lab Activity: Evil Twin Attack with Fake Login Page

---

### Objective

This lab simulates an Evil Twin attack by creating a rogue AP that mimics a legitimate one. A fake captive portal is hosted to capture user credentials when clients connect.

---

### Target Setup

- **Legit SSID:** `6CSEF005W_WPA2_AP`  
- **Rogue SSID:** Same as above  
- **Security:** WPA2-PSK (simulated with open or WPA2 as needed)  
- **Channel:** Same as legit AP  
- **Gateway:** `192.168.140.1`  
- **Web Server:** Fake login page hosted using Python or Apache  

---

## Step 1: Set Up the Evil Twin AP

Use the setup script on the malicious Pi:

```bash
sudo ./setup_evil-twin_ap.sh 6CSEF005W_WPA2_AP WPA2
```

This creates a fake AP broadcasting the same SSID.

---

## Step 2: Host the Fake Login Page

On the same Pi, run:

```bash
cd /var/www/html
sudo cp /home/labadmin/fake_portal/index.html .
sudo python3 -m http.server 80
```

> Ensure the fake page mimics a university or enterprise login.

---

## Step 3: Lure the Client

Deauthenticate the victim to force reconnection:

```bash
sudo aireplay-ng --deauth 5 -a <BSSID> wlan0mon
```

Client may auto-connect to the stronger rogue AP.

---

## Step 4: Capture Credentials

On the malicious Pi:

```bash
tail -f /var/log/apache2/access.log
```

Or monitor `index.html` submissions via netcat, PHP, or Python.

> Store logs in `tasks/img/` or `/home/labadmin/credentials.log`

---

## Discussion Points

- Why do devices sometimes connect to the rogue AP?
- What could make the fake portal more convincing?
- How would you prevent this attack?

---

## Cleanup

```bash
sudo pkill hostapd
sudo pkill dnsmasq
sudo pkill python3
sudo ip link set wlan0 down
sudo ip addr flush dev wlan0
sudo ip link set wlan0 up
```

---

## Optional Screenshots

Include in `tasks/img/`:
- Screenshot of fake login page
- Credential logs
- Hostapd and dnsmasq status

---

## Summary

| Phase     | Tool / Script             | Purpose                              |
|-----------|---------------------------|--------------------------------------|
| Setup     | `setup_evil-twin_ap.sh`   | Mimic real SSID                      |
| Deauth    | `aireplay-ng`             | Force client to switch               |
| Hosting   | `python3 -m http.server`  | Serve fake login page                |
| Capture   | `tail -f` or server logs  | Monitor and record credentials       |

---
#  Evil Twin Access Point Lab

This lab guides you through setting up an **Evil Twin Access Point (AP)** using a Raspberry Pi configured as a malicious node. The Evil Twin AP mimics a legitimate wireless network, luring clients into connecting to it.

---

##  Objectives

- Understand the principles behind Evil Twin attacks
- Configure a fake AP with matching SSID and security type
- Observe client behaviour when encountering fake networks
- Capture credentials or monitor traffic (optional extensions)

---

##
 Requirements

- Malicious Pi unit (`6CSEF005W-MAL-AP`)
- Wireless USB adapter attached (named `lab-wlan`)
- SSH access to the Pi: `ssh labadmin@6CSEF005W-MAL-AP`
- Known SSID and security type of a legitimate AP
- Teardown script: `configs/teardown_mal_ap.sh`

---

##  Script Location

`/home/labadmin/6CSEF005W/configs/setup_evil_twin_ap.sh`

This script allows dynamic setup of a fake AP with chosen SSID and security type.

---

##  Usage

SSH into the malicious Pi and run:

```bash
sudo ./configs/setup_evil_twin_ap.sh <SSID> <SECURITY_TYPE>
```

Where:
- `<SSID>` is the wireless network name to impersonate
- `<SECURITY_TYPE>` must be one of:
  - `OPEN`
  - `WEP`
  - `WPA2`
  - `ENTERPRISE` *(simulated using WPA2-PSK)*

###  Example: Mimic UoW_Secure with WPA2

```bash
sudo ./configs/setup_evil_twin_ap.sh UoW_Secure WPA2
```

---

##  What the Script Does

- Configures `lab-wlan` with IP `192.168.140.1`
- Launches `hostapd` with fake SSID and specified security
- Starts `dnsmasq` to hand out IPs (range: `192.168.140.10–50`)
- Runs until interrupted (Ctrl+C)
- All output logged to `/tmp/hostapd.log` and `/tmp/dnsmasq.log`

---

##
 What to Observe

1. From a victim machine, scan for nearby networks
2. Notice multiple APs with the same SSID
3. Try connecting to the Evil Twin AP
4. Watch:
   - If connection succeeds (for Open/WEP)
   - Whether the device warns of duplicate networks
   - How users might be tricked into entering credentials

---

##  Stopping the Evil Twin

To stop the fake AP, simply press `Ctrl+C` in the terminal running the script.

Alternatively, reset the interface and restore the idle AP:

```bash
sudo ./configs/teardown_mal_ap.sh
```

This will:
- Kill `hostapd` and `dnsmasq`
- Reset the wireless interface
- Restart the idle AP (`6CSEF005W-Idle-MAL-AP`)

---

## 🔬 Optional Extensions

- 🔎 **Packet Capture**: Use `tcpdump` or `Wireshark` to sniff traffic on `lab-wlan`
-  **Handshake Capture**: Try capturing WPA2 handshakes for cracking
- 🎭 **Captive Portal**: Deploy a fake login page using a web server (advanced)

---

##  Notes

- Do not run this script concurrently with another AP script.
- This script mimics security at surface level — no Radius backend is used.
- Always teardown the setup when finished.

---

##  Default Login

| Username   | Password                    |
| ---------- | --------------------------- |
| `labadmin` | *(set during provisioning)* |
