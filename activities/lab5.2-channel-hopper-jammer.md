
## Module Code: 6CSEF005W  
**Module name:** Wireless Network Security  
**Lab activity:** Channel Hopper Jamming  
**Author:** Dr Ayman El Hajjar  

---

#  Lab Activity: Multi-Channel Jamming via Channel Hopping
## How todo this lab

In this lab you are working in pairs. 
- One pc will act as the attacker
- Another PC will act as the Access Point
---

###  Objective

In this lab, you will simulate a jamming attack that disrupts multiple wireless channels by hopping between them rapidly and transmitting interference (e.g. beacon floods, deauths, or noise). The goal is to demonstrate how attackers can target more than one frequency.

---

###  Warning

This attack impacts all 2.4 GHz channels. Perform only in a fully isolated test environment.

---

##  Step 1: Enable Monitor Mode

Put your wireless interface into monitor mode:

```bash
sudo airmon-ng start wlan0
```

---

## 🌀 Step 2: Launch the Channel Hopper Jammer

Run the provided script:

```bash
sudo ./channel_hopper_jammer.sh
```

This script:
- Hops across Wi-Fi channels 1–13
- Dwells briefly on each
- Can be used with other jamming tools in parallel

---

##  Step 3: Observe Impact on Devices

Use `airodump-ng` or client scan tools to:
- Watch for inconsistent visibility of networks
- Monitor dropped signals
- Test latency/connectivity under interference

---

##
 Discussion Points

- What limitations does this technique have?
- Why might an attacker prefer this over fixed-channel jamming?
- How can wireless intrusion prevention systems (WIPS) detect it?

---

##
 Cleanup

```bash
sudo pkill bash
sudo airmon-ng stop wlan0mon
```

---

##  Optional Screenshots

Include in `tasks/img/`:
- Channel hopping log
- Wi-Fi scan results showing erratic signal
- Impact on client devices

---

## Summary


| Phase     | Tool/Script               | Purpose                                   |
|-----------|---------------------------|-------------------------------------------|
| Setup     | `airmon-ng`               | Enable monitor mode                       |
| Execution | `channel_hopper_jammer.sh`| Hop across channels and interfere signal  |
| Impact    | `airodump-ng`, Wi-Fi scan | Observe degraded performance across bands |

---
