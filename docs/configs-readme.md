
# Configs folder Overview

This folder is used to store scripts that may be required for the 6CSEF005W repository. 
It is updated regularly as module practical contents change.


**Contents**
- **setup-kali-base.sh** – configuration helper script  
- **alfa-driver.sh** – driver setup script for Alfa adapters  
- **switch-dns.sh** – script to switch DNS resolver profiles  
- **studentid.sh** – script for handling student ID setup  

## Kali baseline installer — `setup-kali-base.sh`

This repository includes a helper script used to prepare a **VM** for the wireless labs:

- **Filename**: `setup-kali-base.sh`  
- **Purpose**: Install required packages for the wireless practicals while ensuring `hostapd` and `dnsmasq` remain disabled by default so they do not conflict with the AP management scripts in this repo.

### What the script does
1. **Requires root** — the script aborts if not run with `sudo` (it checks EUID).  
2. **Installs packages** (non-interactively) via `apt-get`:
   - Core AP and networking: `hostapd`, `dnsmasq`, `iproute2`, `iptables`, `iw`, `rfkill`, `net-tools`
   - RADIUS and web: `freeradius`, `lighttpd`
   - Wi-Fi tooling: `aircrack-ng`, `reaver`, `bettercap`, `hcxdumptool`, `mdk4`, `wifite`
   - Packet capture / analysis: `tcpdump`, `wireshark`
   - Misc: `ca-certificates`, `curl`, `python3-pip`
3. **Installs Python tooling** with `pip3` (the script installs/updates `scapy`).  
4. **Disables and stops** `hostapd` and `dnsmasq` system services (uses `systemctl disable` / `stop`) so the AP scripts in this repository can bring them up and manage them without conflicts.  
5. Prints expected repository/runtime paths for the lab environment.

### Why hostapd/dnsmasq are disabled
The AP scripts in `ap/` (for example `open-ap.sh`) dynamically generate configuration files, assign IPs and start `hostapd`/`dnsmasq` as required. If the distribution-provided services are enabled and auto-starting, they can hold interfaces or ports and prevent the lab scripts from running correctly. This baseline script installs the packages but leaves the services disabled and stopped.

### Expected locations (printed by the script)
- Repository path expected: `/home/kali/6CSEF005W/`  
- Runtime/log directory: `/home/kali/tmp_ap/`

### How to run
From inside the repository (or wherever the script is copied):

```bash
sudo ./setup-kali-base.sh
```
The installer runs in non-interactive mode (DEBIAN_FRONTEND=noninteractive) so it can be used in automated VM provisioning. After it completes you may see a message about relogin/reboot — follow the message if it appears. 

**Notes**
- The script installs only the packages required for the labs; it does not configure APs or enable `hostapd/dnsmasq`. Use the AP scripts under `ap/` to create and manage wireless access points.
- The script installs scapy via pip3 for optional extension activities and packet crafting exercises.


## Alfa adapter driver installer — `alfa-driver.sh`

- **Filename**: `alfa-driver.sh`  
- **Purpose**: Install the RTL8812AU driver used by the Alfa AWUS036ACH (AC1200) on Kali Linux.  
- **Note**: If you are using Kali machine downloaded from the university servers, you do not need to run this, it is already installed.
- 
### What the script does
1. Updates APT package lists.  
2. Installs build prerequisites: `dkms`, `git`, `build-essential`, `libelf-dev`, and the matching `linux-headers` package for the running kernel.  
3. Clones the aircrack-ng RTL8812AU driver source to `/opt/rtl8812au` if the directory does not already exist.  
4. Registers the driver source with DKMS (`dkms add`) if not already registered.  
5. Builds and installs the driver via DKMS (`dkms build` and `dkms install`) for the `8812au/5.6.4.2` module version.  
6. Loads the kernel module with `modprobe 8812au`.

### Why DKMS is used
DKMS (Dynamic Kernel Module Support) recompiles and reinstalls the module automatically when kernel updates occur. This avoids the need to rebuild the driver manually after kernel upgrades.

### How to run
From the repository (or after copying the script to the target machine):

```bash
chmod +x alfa-driver.sh
sudo ./alfa-driver.sh
```

- Expected behaviour and outputs
  - The script prints informational messages as it proceeds. 
  - On success, DKMS will report the installed module and modprobe 8812au should load the driver so the Alfa adapter is recognised by the kernel.
- Notes
  - The script installs linux-headers-$(uname -r) for the currently running kernel. If the system has a different headers package (custom kernel), ensure matching headers are available before running.
  - If /opt/rtl8812au already exists, the script will skip cloning and continue with DKMS operations.
  - If a different driver version is required, update the DKMS module version strings in the script accordingly.
  - No persistent network or interface configuration is changed by this script; it only builds and installs the kernel module.

## DNS Switcher for Kali `switch-dns.sh`

This script (`switch-dns.sh`) makes it easy to switch between **University DNS** (for use on campus) and **Home DNS** (for use outside the university).  
It ensures that `/etc/resolv.conf` always contains the correct nameservers and can optionally lock it (`chattr +i`) to prevent overwriting.

---

### Features
- Creates two profile files on first run:
  - `/etc/resolv.conf.uni` – with University DNS servers
  - `/etc/resolv.conf.home` – with public resolvers for home use
- Switches `/etc/resolv.conf` between profiles
- Applies/removes the immutable flag automatically
- Keeps timestamped backups of old configs
- On first run, the script automatically creates the two profile files:
  - /etc/resolv.conf.uni → University + fallback DNS
  - /etc/resolv.conf.home → Public resolvers for home use
- These files are then used each time you switch.
---

### Profiles

For univeirty profile: 
```shell
search localdomain
nameserver 192.168.179.2 # University DNS
nameserver 161.74.92.25
nameserver 161.74.92.50 # Google DNS
nameserver 8.8.8.8
```

```shell
nameserver 8.8.8.8
nameserver 1.1.1.1
```


### Usage

**1- Make the script executable:**

```bash
chmod +x switch-dns.sh
Run with sudo from the same directory:
```
**2- Switch to University DNS profile**
```bash
sudo ./switch-dns.sh uni
```
**3- Switch to Home DNS profile**
```bash
sudo ./switch-dns.sh home
```
**4- Show which profile is currently active and whether resolv.conf is locked**
```bash
sudo ./switch-dns.sh status
```
**5**Display the current /etc/resolv.conf contents**
```bash
sudo ./switch-dns.sh show
```


## Student ID 

## Using `studentid.sh`

The `studentid.sh` script customises the terminal prompt to display your Student ID.  
```bash
chmod +x studentid.sh
```

### Set your Student ID
```bash
./studentid.sh
```
You will be prompted to enter your Student ID. After restarting the terminal, your prompt will look like:

```shell
Student ID: w1234567 | user@host:~/current/directory$
```

To reset to default prompt
```bash

./studentid.sh --reset
```
This restores your original .bashrc (from .bashrc.bak) and removes the Student ID prompt.
