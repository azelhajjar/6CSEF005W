# 📡 Wireless Networks Security	 Cheat Sheet  
![Course](https://img.shields.io/badge/Module-6CSEF005W-blue)  
![Level](https://img.shields.io/badge/Level-Undergraduate-green)  
## Author: Dr Ayman El Hajjar
_Last updated: August 2025_

![Hacker](https://img.shields.io/badge/hackaday-darkblue?logo=hackaday&logoColor=white&style=flat-square)
![kalilinux](https://img.shields.io/badge/kalilinux-darkblue?logo=kalilinux&logoColor=white&style=flat-square)
![Terminal](https://img.shields.io/badge/Terminal-black?logo=gnometerminal&logoColor=white&style=flat-square)
![CLI](https://img.shields.io/badge/CLI-blue?logo=linux&logoColor=white&style=flat-square)
![nmcli](https://img.shields.io/badge/nmcli-orange?logo=gnubash&logoColor=white&style=flat-square)
![iw](https://img.shields.io/badge/iw-green?logo=wifi&logoColor=white&style=flat-square)
![iwconfig](https://img.shields.io/badge/iwconfig-lightgrey?logo=wifi&logoColor=white&style=flat-square)
![aircrack-ng](https://img.shields.io/badge/aircrack--ng-red?logo=kalilinux&logoColor=white&style=flat-square)
![wpa_supplicant](https://img.shields.io/badge/wpa__supplicant-purple?logo=lock&logoColor=white&style=flat-square)
---


<details>
<summary><strong>1. nmcli – Network Manager</strong></summary>

| Task                        | Command |
|-----------------------------|---------|
| Show devices                | `nmcli dev status` |
| List Wi-Fi networks         | `nmcli dev wifi list` |
| Set wlan0 unmanaged (off)   | `sudo nmcli dev set wlan0 managed no` |
| Set wlan0 managed (on)      | `sudo nmcli dev set wlan0 managed yes` |
| Connect to Open AP          | `nmcli dev wifi connect "SSID" ifname wlan0` |
| Connect to WEP AP           | `nmcli dev wifi connect "SSID" password "1234567890" ifname wlan0` |
| Connect to WPA/WPA2 PSK AP  | `nmcli dev wifi connect "SSID" password "mypassword" ifname wlan0` |
| Connect to WPA2 Enterprise  | `nmcli dev wifi connect "SSID" ifname wlan0 802-1x.identity "username" 802-1x.password "password"802-1x.phase2-auth "mschapv2"` |

</details>

---

<details>
<summary><strong>2. iw – Modern Wireless Utility</strong></summary>


| Task                        | Command |
|-----------------------------|---------|
| List interfaces             | `iw dev` |
| Show info for wlan0         | `iw wlan0 info` |
| Scan for networks           | `sudo iw wlan0 scan \| grep SSID` |
| List supported channels     | `iw list \| grep MHz` |
| Switch to Monitor mode      | `sudo ip link set wlan0 down`<br>`sudo iw wlan0 set type monitor`<br>`sudo ip link set wlan0 up` |
| Switch back to Managed mode | `sudo ip link set wlan0 down`<br>`sudo iw wlan0 set type managed`<br>`sudo ip link set wlan0 up` |
| Bring interface down        | `sudo ip link set wlan0 down` |
| Bring interface up          | `sudo ip link set wlan0 up` |

</details>

---

<details>
<summary><strong>3. iwconfig – Legacy Wireless Utility</strong></summary>


| Task                        | Command |
|-----------------------------|---------|
| Show wireless interfaces    | `iwconfig` |
| Change to monitor mode      | `sudo iwconfig wlan0 mode monitor` |
| Change back to managed mode | `sudo iwconfig wlan0 mode managed` |
| Bring interface down        | `sudo ifconfig wlan0 down` |
| Bring interface up          | `sudo ifconfig wlan0 up` |


</details>

---

<details>
<summary><strong>4. wpa_supplicant Configs</strong></summary>

| Mode          | Config Example |
|---------------|----------------|
| Open AP       | `network={ ssid="Lab-Open" key_mgmt=NONE }` |
| WEP AP        | `network={ ssid="Lab-WEP" key_mgmt=NONE wep_key0="1234567890" wep_tx_keyidx=0 }` |
| WPA/WPA2 PSK  | `network={ ssid="Lab-WPA" psk="mypassword" }` |
| WPA2 Enterprise | `network={ ssid="Lab-WPA2E" key_mgmt=WPA-EAP eap=PEAP identity="username" password="password" phase2="auth=MSCHAPV2" }` |

**Run:**  
`sudo wpa_supplicant -B -i wlan0 -c wpa_supplicants/wpa.conf`

</details>

---

<details>
<summary><strong>5. Aircrack-ng Suite</strong></summary>

| Task                        | Command |
|-----------------------------|---------|
| Start monitor mode          | `sudo airmon-ng start wlan0` |
| Stop monitor mode           | `sudo airmon-ng stop wlan0mon` |
| Capture packets             | `sudo airodump-ng wlan0mon` |
| Capture on one AP           | `sudo airodump-ng -c <CH> --bssid <AP_MAC> -w capture wlan0mon` |
| Deauth attack               | `sudo aireplay-ng --deauth 10 -a <AP_MAC> -c <CLIENT_MAC> wlan0mon` |
| Crack WEP key               | `aircrack-ng -b <AP_MAC> capture-01.cap` |
| Crack WPA/WPA2 (wordlist)   | `aircrack-ng -w wordlist.txt -b <AP_MAC> capture-01.cap` |

</details>

---

## 📝 Quick Notes

- **nmcli** → Optional, high-level management  
- **iw / iwconfig** → Interface control (modern vs legacy)  
- **wpa_supplicant** → Manual configs for Open, WEP, WPA/WPA2, Enterprise  
- **aircrack-ng** → Reconnaissance, packet capture, and cracking  

---
**Author**: Dr Ayman El Hajjar<br>
**University of Westminster**
