#  Lab 1: From Managed Mode to Monitor Mode – Capturing Wi-Fi Traffic

## Wireless Network Security -- 6CSEF005W --
**Lab activity:** Exploring Managed and Monitor Modes & Capturing Wi-Fi Traffic  
**Author:** Dr Ayman El Hajjar  

###  Objective

- Connect to an Open Access Point (AP) in **managed mode** and observe normal traffic.  
- Switch your wireless interface into **monitor mode** to passively capture all Wi-Fi frames.  
- Use the aircrack-ng suite to capture and analyse control and management frames, focusing on client association.

By the end of this lab activity, you should be able to:

- Differentiate between managed and monitor modes of operation for wireless interfaces.
- Use tools such as iwconfig, airmon-ng, and airodump-ng to configure and monitor wireless traffic.
- Capture association, authentication, beacon, and probe frames and understand their roles in the Wi-Fi connection process.
- Identify connected clients and access points based on frame analysis.
- Interpret and document findings using Wireshark or tcpdump, linking protocol behaviour to network actions.
- Recognise how attackers can exploit these broadcast management frames for reconnaissance.


---

###  Environment Setup

| Role     | Device       | Purpose                                |
|----------|--------------|---------------------------------------|
| AP       | Raspberry Pi*^ | Open AP broadcasting Wi-Fi          |
| Client   | Kali Linux   | Connects and captures Wi-Fi traffic   |

- **(*) Note**- Raspberry pi in the lab session will be controlled by the lab instructor to guide the activity.
- **(^) Note**- A rasberry pi is used to provide a wireless environment **isolated** from your Internet connected environment. 

- For more on how to set up the environment, see [Wireless Lab Environment](lab1.1-wireless-Lab-environment.md).

---

###  Step 1: Connect in Managed Mode

1. If you are just starting the lab, your interface should already be up and in managed mode. 
You can check if your wireless interface is correctly connected to your machine and is in managed mode by typing: 

```bash
iwconfig lab-wlan
```
    - Your wireless interface should be in `Managed mode`. If it is not , possibly for an incomplete previous activity, you will have to change it back to `Managed mode` before continuning.

```bash
sudo ip link set lab-wlan down
sudo iwconfig lab-wlan mode managed
sudo ip link set lab-wlan up
```

2. Connect to the Open AP:
- For this activity, you can either connect using the GUI interface on kali or using the terminal.

```bash
sudo iwconfig lab-wlan essid "6CSEF005W_Open_AP"
sudo dhclient lab-wlan
```

3. Confirm connection and IP:

    ```bash
    ip addr show lab-wlan
    ```
    
4. Start Wireshark or tcpdump to sniff traffic on `lab-wlan` in managed mode.



---

###  Step 2: Switch to Monitor Mode

1. Bring interface down and change mode:

    ```bash
    sudo ip link set lab-wlan down
    sudo iwconfig lab-wlan mode monitor
    sudo ip link set lab-wlan up
    ```

2. Use `airmon-ng` to verify:

    ```bash
    sudo airmon-ng start lab-wlan
    ```

3. Use `airodump-ng` to scan and capture traffic:

    ```bash
    sudo airodump-ng lab-wlan
    ```

---

###  Step 3: Capture Association Frames

1. Focus capture on the AP:

    ```bash
    sudo airodump-ng --bssid <AP_BSSID> -c <channel> -w capture wlan0mon
    ```

2. Have clients join or reconnect to the AP to capture association and authentication frames.

3. Stop capture after enough data collected (Ctrl+C).

---

###  Step 4: Analyse Captured Traffic

1. Open the `.cap` file in Wireshark.

2. Use display filters:

    - Beacon frames:

      ```
      wlan.fc.type_subtype == 0x08
      ```

    - Probe requests:

      ```
      wlan.fc.type_subtype == 0x04
      ```

    - Authentication frames:

      ```
      wlan.fc.type_subtype == 0x0b
      ```

    - Association request/response:

     ```
      wlan.fc.type_subtype == 0x00 || wlan.fc.type_subtype == 0x01
      ```

3. Identify:

    - SSID broadcast by the AP in beacons  
    - Probe requests by clients  
    - Client authentication and association handshake

---

###
 Learning Outcomes

- Understand how wireless NICs operate differently in managed vs. monitor mode.  
- Learn to capture and interpret IEEE 802.11 management frames.  
- Use the aircrack-ng suite tools for Wi-Fi reconnaissance.

---

###
 Cleanup

1. Return interface to managed mode:

```bash
sudo ip link set lab-wlan down
sudo iwconfig lab-wlan mode managed
sudo ip link set lab-wlan up
```

2. Disconnect from AP:

```bash
sudo dhclient -r wlan0
```

---

###  Optional Screenshots

- Interface mode before and after changes.  
- Airodump-ng scanning output.  
- Wireshark showing beacon and association frames.

---

###  Tips and regulations

- Monitor mode allows you to see all traffic, not just your client’s.  
- Be mindful of local regulations when capturing wireless traffic.

---
