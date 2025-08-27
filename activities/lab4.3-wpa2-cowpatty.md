
## Lab: WPA2 Cracking using Cowpatty

---

###  Step-by-Step

1. Capture handshake as usual
2. Run:

```bash
cowpatty -r capture.cap -f /usr/share/wordlists/rockyou.txt -s "YourSSID"
```

> Add `-v` for verbose output

---

### Summary


Cowpatty is simpler but slower than Hashcat and lacks GPU support.
