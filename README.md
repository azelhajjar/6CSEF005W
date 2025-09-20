# Wireless Network Security Module Labs Repository

**University of Westminster**
**BSc Cyber Security and Forensics**
**Module Code:** 6CSEF005W
**Module Name:** Wireless Network Security

---

## Purpose of this Document

This repository supports the practical labs for the Wireless Network Security module. It includes:

* Setup instructions for Access Points, Kali Linux (Attacker), and other systems
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


---

## 🧰 Repository Structure

```plaintext
├── ap/               # Access Point setup scripts
│   └── files/           # Advanced AP flles for setups
├── captures/                # Wireshark PCAPs
├── configs/                 # Base setup and teardown for Pi/Kali
├── docs/                    # Configurations and setup documentation for (configs files)
```

---

## Environment Overview

| Role          | Device                | Purpose                               |
| ------------- | --------------------- | ------------------------------------- |
| Attacker      | Kali Linux            | Launches attacks and captures traffic |
| Victim Device | Android / Laptop      | Connects to test networks             |
| ------------- | --------------------- | ------------------------------------- |

## Where to Go Next

* For AP scripts documentation: [`docs/APs.md`](docs/APs.md)
* For configuration script documentation: [`docs/configs-readme.md`](docs/configs-readme.md)

---

© Dr Ayman El Hajjar – University of Westminster
*For academic use only.*

---
