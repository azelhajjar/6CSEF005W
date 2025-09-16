# Wireless Network Security Module Labs Repository

**University of Westminster**
**BSc Cyber Security and Forensics**
**Module Code:** 6CSEF005W
**Module Name:** Wireless Network Security

---

## Purpose of this Document

This repository supports the practical labs for the Wireless Network Security module. It includes:

* Setup instructions for Raspberry Pi (Access Point), Kali Linux (Attacker), and other systems
* Descriptions of attack scenarios and lab activities
* Tool and software requirements
* Folder structure and usage guidelines
* Links to markdown lab guides

---

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/azelhajjar/6CSEF005W.git
```
```bash
cd 6CSEF005W
```

### 2. Make Scripts Executable

Make all `.sh` scripts executable:

```bash
find . -type f -name "*.sh" -exec chmod +x {} \;
```

### 3. Launch Script Manager

Use the menu-based launcher:

```bash
sudo ./ap_manager.sh
```

Follow on-screen prompts to select setup/config/attack scripts interactively.

---

## 🧰 Repository Structure

```plaintext
├── activities/              # Lab activities and tasks
├── adv-ap/               # Access Point setup scripts
│   ├── openwrt/             # OpenWRT image and config
│   └── radius/              # WPA2-Enterprise (FreeRADIUS)
├── APconfigs/               # Access Point setup scripts
│   └── malicious/           # Rogue/Evil Twin/DHCP setups
├── captures/                # Wireshark PCAPs
├── configs/                 # Base setup and teardown for Pi/Kali
├── docs/                    # Configurations and setup documentation for (configs files)
├── attacks-automation/      # Shell scripts automating attacks
├── lablaunch.sh            # Interactive launcher menu
```

---

## Environment Overview

| Role          | Device                | Purpose                               |
| ------------- | --------------------- | ------------------------------------- |
| AP Pi         | Raspberry Pi (Ubuntu) | Runs AP services (hostapd, dnsmasq)   |
| Malicious Pi  | Raspberry Pi or Kali  | Rogue/Evil Twin deployments           |
|               |  for working in pair  |                                       |
| Attacker      | Kali Linux            | Launches attacks and captures traffic |
| Victim Device | Android / Laptop      | Connects to test networks             |
| ------------- | --------------------- | ------------------------------------- |

## Where to Go Next

* Lab activity details: [`activities/activities.md`](activities/activities.md)
* Setup script documentation: [`docs/README.md`](docs/README.md)
* Interactive launcher: [`lablaunch.sh`](./lablaunch.sh)

---

© Dr Ayman El Hajjar – University of Westminster
*For academic use only.*

---
