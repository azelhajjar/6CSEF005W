
## Module Code: 6CSEF005W  
**Module name:** Wireless Network Security  
**Lab activity:** Beacon Flood Attack  
**Author:** Dr Ayman El Hajjar  

---

#  Lab Activity: Beacon Flooding with Fake SSIDs

## How todo this lab

In this lab you are working in pairs. 
- One pc will act as the attacker
- Another PC will act as the Access Point
---

###  Objective

This lab demonstrates how attackers can flood the wireless environment with fake beacon frames, creating dozens or hundreds of bogus SSIDs. This can confuse users, overwhelm client devices, and even crash older access points or Wi-Fi scanners.

---

###  Warning

Only perform this lab in an isolated environment. Flooding beacon frames can severely disrupt Wi-Fi discovery and scanning.

---

##  Step 1: Prepare the Environment

Ensure `mdk3` is installed and the interface is in monitor mode:

```bash
sudo airmon-ng start lab-wlan
```

---

## Step 2: Create a Fake Beacon List

Use the script or manually create a list of SSIDs:

Make sure you change the MAC address

```bash
cat > /tmp/beacon_list.txt << EOF
FakeAP1,00:11:22:33:44:55,2412,100
FakeAP2,66:77:88:99:AA:BB,2437,100
EOF
```

---

## Step 3: Launch the Beacon Flood

Run the script:

```bash
sudo ./beacon_flooder.sh
```

Or use `mdk3` directly:

```bash
sudo mdk3 wlan0mon b -f /tmp/beacon_list.txt
```

> Each entry will appear as a unique Wi-Fi network to nearby devices.

---

##  Step 4: Observe the Effect

On a client device:
- Open Wi-Fi scan list
- Notice a large number of fake SSIDs
- Attempt to connect (will fail)

---

##
 Discussion Points

- Why do these SSIDs appear in the list?
- Can this attack affect enterprise Wi-Fi setups?
- How might detection or mitigation tools identify this behaviour?

---

##
 Cleanup

```bash
sudo pkill mdk3
sudo airmon-ng stop wlan0mon
```

---

##  Optional Screenshots

Store in `tasks/img/`:
- Screenshot of Wi-Fi scan with fake SSIDs
- mdk3 terminal output
- Client confusion or scan delays

---

## Summary


| Phase     | Tool           | Purpose                                 |
|-----------|----------------|-----------------------------------------|
| Setup     | `mdk3`         | Send beacon frames with fake SSIDs      |
| Flood     | Script/Manual  | Overload nearby Wi-Fi scan lists        |
| Observe   | Client scan    | Demonstrate DoS or confusion effect     |

---



---

##  Background: Denial of Service (DoS) Attacks in Wi-Fi

Wireless LANs (WLANs) are highly susceptible to various Denial of Service (DoS) attacks due to the shared nature of the radio spectrum. Common DoS techniques include:

- **Deauthentication attacks**: Sending spoofed deauth packets to disconnect clients.
- **Disassociation attacks**: Sending spoofed disassociation frames to force reauthentication.
- **CTS/RTS flooding**: Exploiting control frame protocols to monopolise bandwidth.
- **Beacon flooding**: Overwhelming nearby clients with fake SSIDs to confuse and crash network scanners.

### Beacon Flooding as a DoS Attack

Beacon flooding is one of the most effective and low-effort Wi-Fi DoS attacks. Here's why:

- Client devices use beacon frames to discover available networks.
- By sending hundreds of fake beacons with random SSIDs, the attacker:
  - Confuses users with misleading network names.
  - Overloads network lists on vulnerable devices.
  - Potentially causes instability or UI crashes on older clients.
- The attack requires no connection or interaction with legitimate networks.
- It is usually performed using tools like `mdk3` or `mdk4`.

> ❗ As soon as clients refresh their Wi-Fi list, they’ll see dozens of fake APs.

This attack is effective against both home and enterprise setups where user confusion can lead to further phishing or Evil Twin attacks.

---
