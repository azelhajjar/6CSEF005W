# Access Point Setup with hostapd and dnsmasq

When an AP runs, for each lab , it uses two key components to create a wireless Access Point (AP):

- **hostapd**: handles the Wi-Fi access point itself (SSID, channel, authentication).
- **dnsmasq**: provides DHCP services so clients can get an IP address and DNS information.

This is a summary of the network settings for the Access Points.
- AP network: `192.168.140.0/24`
- AP address: `192.168.140.1`
- DHCP range: `192.168.140.50 – 192.168.140.150`
- Fixed AP MAC address: `02:11:22:33:44:55`

The acess point  script prepares the environment, writes the configuration files for both tools, starts them, and then shows client connection logs.
More details about the configurations is explained below


## Hostapd Configuration

The script writes a file called `hostapd.conf` under the runtime directory (`/home/kali/tmp_ap`):

- A hostapd.conf usually contains the following value:
  -  The interface: wireless card used (wlan0 by default)-  `interface=wlan0`
  - The nl80211 is the standard Linux Wi-Fi driver API - `driver=nl80211`
  - The name of the SSID - For example for Open AP `ssid=6CSEF005W_OPEN_AP`
  - The g means 2.4GHz 802.11g. `hw_mode=g`
  - the Wi-Fi channel to use. `channel=6`
  - The Open System authentication value. `auth_algs=1`
  - In addition to other vlaues related to logging, visibility, etc.. 
``
## Hostapd Configuration
The script also writes a file called `dnsmasq.conf` in the same runtime directory. 
- A hostapd.conf usually contains the following value:
  - The interface binds DHCP to the AP’s wireless card WLAN0. `nterface=wlan0`
  - `bind-interfaces` ensures it only listens on that interface
  - `dhcp-authoritative` marks this DHCP server as authoritative.
  - `dhcp-range=192.168.140.50,192.168.140.150,255.255.255.0,12h` leases IPs between .50 and .150 with a 12-hour lease time.
  - `dhcp-option=3,192.168.140.1` leases IPs between .50 and .150 with a 12-hour lease time.
  - `dhcp-option=6,192.168.140.1` DNS server, also the AP IP.
  - `no-resolv` ignores system DNS settings.
  - `log-dhcp` logs DHCP requests and leases.
- This file controls how clients receive network configuration.

## Runtime and Logs
- When launched, the script:
  - Prepares the wireless card (wlan0) to AP mode.
  - Assigns it the IP 192.168.140.1/24.
  - Starts hostapd in the background with logging to hostapd_open.log.
  - Starts dnsmasq with logging to dnsmasq_open.log.
  - Shows live events such as:
    - Client connections (MAC addresses).
    - DHCP assignments (MAC → IP → hostname).
    - Logs are stored in /home/kali/tmp_ap.

## Stopping the AP

When a user presses Ctrl+c, the ap script calls the script `teardown-ap.sh` . This ensures that the interface is relaced and the mode goes back to `managed mode`.

The script can also be run manually, specially if anyting went wrong and the teardown did not run by itself. 
Browse to the folder where the script is `cd ~/6CSEF005W/ap/` and run it using:

```bash
sudo ./teardown.sh
```
- This script kills hostapd/dnsmasq, removes IPs, and resets the wireless interface.

## Summary: 

- hostapd: builds the Wi-Fi access point.
- dnsmasq: provides DHCP and DNS.
- Configurations are auto-generated each time the AP starts.
- Logs show client activity in real time.
- Teardown script resets the environment safely.