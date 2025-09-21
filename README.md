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

Each time you set up the Virtual machine, on a university machine, you will need to **clone** the VM each time.
- To clone the module repository - 
1. Make sure you are in your home directory:
```bash
cd ~
git clone https://github.com/azelhajjar/6CSEF005W.git
```

This is to ensure that you are working on a clean Kali VM and not following from someone elses work. 

- **Clone**: The first time you set up the labs on your laptop, use `git clone` to copy the entire repository:


```bash
cd 6CSEF005W
```
## 2. Updating the Repository: Clone vs Pull

- **Clone**: The first time you set up the labs on your laptop, use `git clone` to copy the entire repository:
```bash
git clone https://github.com/azelhajjar/6CSEF005W.git

### 2. Make Scripts Executable

Make all `.sh` scripts executable:

```bash
find . -type f -name "*.sh" -exec chmod +x {} \;
```

## 🧰 Repository Structure

```plaintext
├── ap/               # Access Point setup scripts
│   └── files/           # Advanced AP flles for setups
├── captures/                # Wireshark PCAPs
├── configs/                 # Base setup and teardown for Pi/Kali
├── docs/                    # Configurations and setup documentation for (configs files)
```
For setup 


## Launching an Access Point (When working in pairs)

In most in-class activities the lab tutor will run the AP while you perform the attacker role from your own machine.

**However**, for some activities you will work in **pairs**: one student runs the AP and the other performs the attacker activity
- This arrangement prevents an AP from being taken down quickly and stopping other students from completing their work;
- It also means paired students can continue the exercise regardless of what others are doing. More information about this will be provided in each activity where it is needed.

When you need to run an AP, you should browse the `ap` folder in the repository and run the AP related to the activity. More information will be in the lab weekly activity document on Blackboard.
- To run an Access Point on one Virtual Machine
1. Make sure you Alfa adapter is attached to the VM. You can check if the VM can see it correctly:
```bash
iw dev
```
2. Go to the `ap` folder: 
```bash
cd ~/6CSEF005W/ap/
```
3. Run the script: for example for the Open Access Point, run: 
```bash
sudo ./open-ap.sh
```
4. To stop the AP, press `ctrl+c` . This will run the `teardown-ap.sh` script and return your alfa adapter to manged mode. 

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
