# Wireless Network Security Module Labs Repository

**University of Westminster**
**BSc Cyber Security and Forensics**
**Module Code:** 6CSEF005W
**Module Name:** Wireless Network Security

---

## Purpose of this repositoru

This repository supports the practical labs for the Wireless Network Security module. It includes:

* Setup instructions for Access Points, Kali Linux (Attacker), and other systems
* Descriptions of attack scenarios and lab activities
* Tool and software requirements
* Folder structure and usage guidelines
* Links to markdown lab guides

## Weekly Lab Structure and Release Schedule

Below are the lab activities that we will be doing over the term. Access Point scripts and any other files needed for each activity will be released on the day to the module repository.  
The accompanying lab activity can be downloaded from Blackboard; you will find it in the **Lab Activities** section under the corresponding week. The table below maps week → lab title → when it will appear.

| Week | Topic               | When it will appear |
|------|------------------------------------------------|---------------------|
| Week 1 | Environment setup / Linux basics              | Released Week 1     |      
| Week 2 | Wireshark, reconnaissance, open APs           |  Released Week 2     |
| Week 3 | WEP AP-side attacks and cracking              |  Released Week 3     |
| Week 4 | WPA2 AP-side attacks and cracking             | Released Week 4     |
| Week 5 | WPA2 Enterprise attacks                       | Released Week 5     |
| Week 7 | Physical layer attacks, MAC filters, DoS      | Released Week 7     |
| Week 8 | Client-side attacks                           |  Released Week 8     |
| Week 9 | Evil twin and rogue access points             | Released Week 9     |
| Week 10|  Captive Attacks                              | Released Week 10    |

Notes:
* PCAPs produced during in-class runs will be stored in `captures/` and linked from the corresponding lab guide. They will be released in Week 10 to support your assignment completion.

---

## Getting the Repository- - On a university machine
Each time you set up the Virtual machine, on a university machine, you will need to **clone** the VM each time.

- **Clone**: Each  time you set up the labs on your laptop, use `git clone` to copy the entire repository:
```bash
git clone https://github.com/azelhajjar/6CSEF005W.git
```
**Note** Observe in which folder you are cloning the repository. If you have just opened a terminal, the terminal will default to `/home/kali` and if you clone the repository there, the repository will sit in `/home/kali/6CSEF005W`. If you want the repository to be on the Desktop, you will need to first browse to the Desktop location using `cd ~/Desktop`.

### 2. Make Scripts Executable

Make all `.sh` scripts executable:

```bash
find . -type f -name "*.sh" -exec chmod +x {} \;
```

```bash
cd 6CSEF005W
```
## Getting the Repository- On your own machine
**On your own machine, you can update the Repository weekly rather than clonning it: Clone vs Pull**

On your own machine, you do not need to download the repository each time. Once downloaded using the same method as above, you can simply go to the folder where it is and use `git pull` to fetch any updates.
Make sure you are in the correct folder first. For example, if you cloned the repository to the Kali home folder, go to the repository folder using `cd ~/6CSEF005W` and then type:

```bash
git pull
```
## 🧰 Repository Structure

```plaintext
├── ap/               # Access Point setup scripts
│   └── files/           # Advanced AP flles for setups
├── captures/                # Wireshark PCAPs
├── configs/                 # Base setup and teardown for Pi/Kali
├── docs/                    # Configurations and setup documentation for (configs files)
```

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
| ------------- | ------------------------------------------------------ | ------------------------------------- |
| Attacker      | Kali Linux            | Launches attacks and captures traffic |
| Victim Device | Android / Laptop /Kali/Host machine (Windows)      | Connects to test networks             |
| ------------- | ------------------------------------------------------ | ------------------------------------- |

## Where to Go Next

* For AP scripts documentation: [`docs/APs.md`](docs/APs.md)
* For configuration script documentation: [`docs/configs-readme.md`](docs/configs-readme.md)

---

© Dr Ayman El Hajjar – University of Westminster
*For academic use only.*

---
