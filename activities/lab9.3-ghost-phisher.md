
## Module Code: 6CSEF005W  
**Module name:** Wireless Network Security  
**Lab activity:** Ghost Phisher – GUI-based Wireless Attacks  
**Author:** Dr Ayman El Hajjar  

---

# Lab: Evil Twin and Phishing with Ghost Phisher

---

### Objective

Use **Ghost Phisher**, a GUI tool in Kali Linux, to:
- Launch Evil Twin APs
- Provide fake login portals
- Perform credential harvesting via DHCP, DNS, and Web spoofing

---

## Requirements

- Kali Linux (Ghost Phisher pre-installed)
- A wireless adapter supporting AP/injection mode
- No active firewalls or services blocking port 80 or DHCP

---

## Launching Ghost Phisher

From terminal:
```bash
ghost-phisher
```

Or find it under:
`Applications > Kali Linux > Wireless Attacks > Ghost Phisher`

---

## Step-by-Step Usage

### 1. Wireless AP Configuration

- Go to **Fake Access Point Settings**
- Enter SSID: `FreePublicWiFi`
- Interface: `wlan0`
- Select channel (e.g., 6)
- Click **Start Fake AP**

---

### 2. DHCP Configuration

- Enable the DHCP server
- Set:
  - Range: `192.168.2.10 - 192.168.2.50`
  - Gateway: `192.168.2.1`
- Click **Start DHCP Server**

---

### 3. DNS Spoofing

- Tick **Enable DNS Server**
- Redirect all domains to: `192.168.2.1`
- Click **Start DNS Server**

---

### 4. Phishing Page Hosting

- Enable **HTTP Server**
- Place HTML login page in:
  ```bash
  /usr/share/ghost-phisher/Phishing Pages/index.html
  ```
- Credentials will be logged automatically

---

## Test from Client

1. Connect to `FreePublicWiFi`
2. Try to browse a website
3. You'll be redirected to the fake login portal
4. Enter credentials → observe log window

---

## Captured Data

Ghost Phisher logs:
- Credentials
- Connection attempts
- DNS queries

Logs stored in:
```bash
/root/.ghost-phisher/logs/
```

---

## Discussion Points

- How does this differ from manual hostapd setup?
- What risks do GUI tools pose in attacker hands?
- Can HTTPS mitigate this attack?

---

##  Summary

| Component       | Feature             | Purpose                            |
|------------------|----------------------|------------------------------------|
| Fake AP          | `hostapd` wrapper    | Broadcast spoofed SSID             |
| DHCP Server      | Internal             | Assign IPs to clients              |
| DNS Server       | Spoofing             | Redirect traffic to local server   |
| Web Server       | Phishing portal      | Capture login attempts             |
| Logging          | Auto-logs in GUI     | View real-time captured data       |

---

##  Teardown

Click **Stop** on all Ghost Phisher modules  
Run:
```bash
sudo ./teardown_ap.sh
```

---

##  Optional Screenshots

- Ghost Phisher GUI
- Fake portal login
- Logged credentials panel

---
