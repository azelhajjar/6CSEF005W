
## Module Code: 6CSEF005W  
**Module name:** Wireless Network Security  
**Lab activity:** Rogue DHCP and DNS Redirection  
**Author:** Dr Ayman El Hajjar  

---

# Lab Activity: Rogue DHCP Server and DNS Manipulation

---

### Objective

In this lab, you will simulate a Rogue DHCP attack by setting up a fake DHCP server that provides malicious network settings, such as an attacker-controlled DNS server. This technique can be used to redirect traffic or perform man-in-the-middle attacks.

---

### Setup Summary

- **Attacker IP (Gateway):** `192.168.142.1`  
- **Rogue Subnet:** `192.168.142.0/24`  
- **DNS Server:** `8.8.8.8` (or attacker IP if using DNS spoofing)  
- **Interface:** `wlan0`

---

## Step 1: Launch the Rogue DHCP Server

Use the script provided:

```bash
sudo ./setup_rogue_dhcp.sh
```

This will:
- Configure interface `wlan0`
- Launch `dnsmasq` with a rogue DHCP configuration
- Offer IPs in the `192.168.142.0/24` range

---

## Step 2: Connect a Victim Device

Connect a wireless client to the attacker's access point (e.g. Open or WEP AP).  
You can verify the IP and gateway given to the client:

```bash
ip a
ip r
cat /etc/resolv.conf
```

---

## Step 3: Optional DNS Redirection (Spoofing)

Modify the DNS server in the script to use your own malicious DNS:

```bash
DNS_SERVER="192.168.142.1"
```

Then run a tool like `dnsspoof`, `ettercap`, or custom DNS server to redirect domains.

---

## Step 4: Test the Setup

From the client device, try accessing a common domain:

```bash
ping google.com
```

Observe whether it resolves or redirects. You can redirect all traffic to a captive portal, phishing site, or packet sniffer.

---

## Discussion Points

- How can users protect against rogue DHCP servers?
- Would this work in networks with DHCP snooping enabled?
- What mitigation techniques exist at the switch level?

---

## Cleanup

```bash
sudo pkill dnsmasq
sudo ip link set wlan0 down
sudo ip addr flush dev wlan0
sudo ip link set wlan0 up
```

---

## Optional Screenshots

Save in `tasks/img/`:
- DHCP lease output
- Redirected DNS result
- `dnsmasq.conf` preview

---

## Summary

| Phase     | Tool / Script            | Purpose                                 |
|-----------|--------------------------|-----------------------------------------|
| Launch    | `setup_rogue_dhcp.sh`    | Serve fake IPs, gateway, DNS            |
| Connect   | Client connects to AP    | Receives rogue settings                 |
| Redirect  | `dnsspoof` or custom DNS | Hijack web traffic via DNS redirection  |

---
