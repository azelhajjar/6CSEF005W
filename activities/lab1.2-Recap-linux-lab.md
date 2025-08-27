

# Introduction to Linux
## 6CSEF005W

### PLEASE READ THIS
`NOTE` 
- In this lab, you only need to have access to a Linux machine. 
- If you are in CLG.43 or CLG.46, you can simply boot up from a Linux machine. 
- This is not meant to be a lab to follow step by step. It is also not a part of your assessment. This is a tutorial to help you navigate the labs and to be familiar with using the various commands and tools we will be using during this term.


# Introduction To Linux

- Linux is more than an OS. It’s an idea where everybody grows together and there’s something for everybody. 
- For this reason, there are many flavours and distributions for Linux. 
- The two most commonly used architecture for those distributions are either RPM based or Debian based. 
- `RPM Red Hat Linux` and `SUSE Linux` were the original major distributions that used the .rpm file format, which is today used in several package management systems.
- `Debian`: Debian is a distribution that emphasises free software. It supports many hardware platforms. Debian and distributions based on it use the .deb package format and the dpkg package manager and its frontends (such as apt-get or synaptic)
- `Kali and Ubuntu`, are Debian. All the labs in this module use Debian commands syntax.

`A note`- In most cases, Linux errors are self explanatory. Read the error the terminal throws at you.

## File system tree 

- Like Windows, a Unix-like operating system such as Linux organises its files in what is called a hierarchical directory structure.
- This means that they are organised in a tree-like pattern of directories (sometimes called folders in other systems), which may contain files and other directories.
- The first directory in the filesystem is called the root directory. The root directory contains files and subdirectories, which contain more files and subdirectories, and so on.
- Note that unlike Windows, which has a separate filesystem tree for each storage device, Unix-like systems such as Linux always have a single filesystem tree, regardless of how many drives or storage devices are attached to the computer.
- Storage devices are attached (or more correctly, mounted) at various points on the tree according to the whims of the system administrator, the person (or persons) responsible for the maintenance of the system.
- All files on a Linux system are stored on file systems which are organised into a single inverted tree of directories, know as a file system hierarchy.In the inverted tree, root lies at the top and the branches of directories and sub-directories stretch below the root.

```
/
├── bin     -> Operating System Binary Executables (Commands)
├── boot    -> Files related to booting (starting) the system
├── dev     -> Device files for hardware and virtual devices
├── etc     -> System configuration files
├── home    -> User home directories
├── lib     -> Shared libraries and kernel modules
│   ├── lib32
│   ├── lib64
│   └── libx32
├── media   -> Mount points for removable devices (e.g. USB)
├── mnt     -> Temporary mount points
├── opt     -> Optional software and add-ons
├── proc    -> Virtual files representing current system state
├── root    -> Root user’s home directory
├── run     -> Runtime data (e.g. sockets, process IDs)
├── sbin    -> System administration commands
├── srv     -> Data for services (e.g. web, FTP)
├── sys     -> Virtual FS for kernel/hardware info
├── tmp     -> Temporary files (auto-deleted after 10 days)
├── usr     -> User-installed software, binaries, docs
└── var     -> Dynamic files: logs, cache, spooled content
```

# Learning the shell

- When we speak of the command line, we are really referring to the shell. The shell is a program that takes keyboard commands and passes them to the operating system to carry out.
- Almost all Linux distributions supply a shell program from the GNU Project called bash.
- When using a graphical user interface, we need another program called a terminal emulator to interact with the shell. 
- It is called `terminal`

## Command Execution

- Most commands use `options` consisting of a single character preceded by a dash, such as `-l`.
- An option is a predefined value that changes the behaviour of a command.
- Options are typically single-letter flags, like `-a` or `-l`.

- The `ls` command lists files and directories in the current working directory.

- To list `all files`, including hidden ones (those beginning with a `.`):
```bash
ls -a
```
 - To display results in long format, showing permissions, ownership, and timestamps:
```bash
ls -l
```
- You can combine options, as in `-al`
```bash
ls -al
```
-Some newer commands support word options (also called `long options`), such as `--long`.
    - Note the two hyphens
```bash
ls --color
```
- If you want to know what options you can use for specific commands, you can read the manual for each command. 
- `man`: If you type `man ls` for example, this will give you the manual for ls command including all options for ls.


## Simple Commands

- `date`: This command displays the current time and date.
- `df`: To see the current amount of free space on your disk drives
- `free`: Likewise, to display the amount of free memory.
- If we press the up-arrow key we can see previous commands.  
- `history`: This command remembers the last 500 commands by default in most Linux distributions. 
- We can end a terminal session by either closing the terminal emulator window or entering the `exit` command at the shell prompt.

- An argument is a parameter that appears after the command
- Example: To use the cd command to change to the bin directory: 
```bash
cd /bin
```
- To execute multiple commands on a single line, separate them with semi-colons and press Enter only after the last one
```bash
pwd ; date ; ls`
```

# Checking Your Login with whoami

- If you’ve forgotten whether you’re logged in as root or another user, you can use the whoami command to see which user you’re logged in as: 

```bash
whoami
```
## Commands to navigate file systems

- The `pwd` command displays the current working directory.
- When you are using GIU, you can easily identify in which directory you are working.
- When you using command line, you need to use a command to help you identify this.  


# Manipulating Files and Directories

- To change your working directory (where we are standing in our tree-shaped maze) we use the `cd` command 

```bash
cd /bin
```
- This will change your working directory to `bin` directory
- To change to a desired directory you type the full path name of the file. For example if i want to navigate to the pictures File in my home directory
```bash
cd /home/kali/Pictures
```
- or
```bash
cd ~/Pictures
```
- The `~` represents the home folder of the current username you are signed in with.
```bash
cd ~
```
- There are some important shortcuts as well to navigate around folders using the cd command
- To change the working directory to your home directory.
`cd ..` To move to the parent of the current working directory.
- To change the working directory to the previous working directory.
- Before you continue with the next step, navigate to your user Desktop folder so that we can create a directory for out first lab. 
```bash
cd ~/Desktop
```
- The `mkdir` command is used to create directories.
- To create a directory called lab1
```bash
mkdir lab1
``` 
- You can read about the different options of the `mkdir` on the command manual using `man mkdir`
- The `cp` command copies files or directories.
- To  copy the single file or directory item1 to file or directory item2
```bash
cp item1 item2
```
- You can read  about the different options of the `cp` on the command manual using `man cp`

# Manipulating Files and Directories

- To change your working directory (where we are standing in our tree-shaped maze) we use the `cd` command:

```bash
cd /bin
```

- This will change your working directory to the `bin` directory.
- To change to a desired directory, you type the full path name. For example, if you want to navigate to the Pictures folder in your home directory:

```bash
cd /home/kali/Pictures
```

- or:

```bash
cd ~/Pictures
```

- The `~` represents the home folder of the current user you are signed in as.

```bash
cd ~
```

- There are some important shortcuts for navigating folders using `cd`:
  - `cd` — go to your home directory
  - `cd ..` — move to the parent of the current directory
  - `cd -` — switch to the previous working directory

- Before you continue with the next step, navigate to your Desktop folder so we can create a directory for our first lab:

```bash
cd ~/Desktop
```

- The `mkdir` command is used to create directories. For example, to create a directory called `lab1`:

```bash
mkdir lab1
```

- You can read more about `mkdir` by running `man mkdir`.

- The `cp` command copies files or directories. For example:

```bash
cp item1 item2
```

- This copies a file or directory named `item1` to a new location or filename `item2`.
- Learn more using `man cp`.

# Text Manipulation

- **Viewing Files**: Use the `cat` command to display a text file in the terminal. For example:

```bash
cat /etc/adduser.conf
```

- If the file is too long, you might not see all its contents. Use `head` or `tail` to view just part of the file:

```bash
head /etc/adduser.conf
```

- To show a specific number of lines from the top:

```bash
head -20 /etc/adduser.conf
```

- To show the last lines of a file:

```bash
tail /etc/adduser.conf
```

- Or to show the last 20 lines:

```bash
tail -20 /etc/adduser.conf
```

- To display file content with line numbers:

```bash
nl /etc/adduser.conf
```

- **Show text in terminal**: Use `echo` to print a string:

```bash
echo "this is my text"
```

- **Create empty files or update timestamps**: Use `touch`:

```bash
touch lab1
```

- If `lab1` already exists, this updates its timestamp.
- You can create multiple files at once:

```bash
touch lab1 lab2
```

- Learn more using `man touch`.

- Now let’s move to the `lab1` directory:

```bash
cd ~/Desktop/lab1
```

- To append text to a file named `example1`:

```bash
echo "This is my first line" >> example1
```

- `echo` prints the text.
- `>> example1` appends it to the file, creating it if it doesn’t exist.

- To determine a file type, use the `file` command:

```bash
file example1
```

- **View large files with paging**: Use `less`:

```bash
less /etc/passwd
```

- While viewing:
  - `Spacebar` — one page forward
  - `b` — one page back
  - `Enter` or ↓ — scroll one line down
  - `↑` — scroll one line up
  - `q` — quit and return to the shell

- **Move or rename files**: Use `mv`

```bash
mv example1 example2
```

- This renames `example1` to `example2`.

```bash
mv example2 ~/Desktop/example2
```

- This moves `example2` to the Desktop.

```bash
mv example2 ~/Desktop/lab1/example1
```

- This moves and renames the file.

- Learn more using `man mv`.

- Now let’s go back to the Desktop:

```bash
cd ~/Desktop/
```

- To delete the file `example2`:

```bash
rm example2
```

- To delete a directory, you need to use the `-r` (recursive) flag:

```bash
rm lab1
```

- This will **fail** if `lab1` is a directory with contents.

```bash
rm -r lab1
```

- This removes the directory and all its contents.

- Learn more using `man rm`.

# Permission

- Operating systems in the Unix tradition (like Linux) are not only multitasking but also **multiuser** systems.
- Multiuser capability means multiple users can access and use the same computer simultaneously. For example, remote users can log in via SSH and even run graphical applications using the X Window System.
- This design is inherited from Unix, which was built for large centralised systems where many users shared a single machine, such as university mainframes with multiple terminals.
- To ensure users don’t interfere with each other, Unix systems enforce **file permissions** and **process isolation**, protecting data and maintaining system stability.
- Access rights to files and directories are defined in terms of **read**, **write**, and **execute** permissions. You can see these when using the `ls -l` command.
- The three types of permission are:
  - `r` (read): Allows viewing the contents of a file or listing a directory.
  - `w` (write): Allows modifying a file or creating/deleting files in a directory. ⚠ Note: write access on a directory allows deleting files **even if** the user doesn’t have write access to the file itself.
  - `x` (execute): For files, it allows execution; for directories, it allows changing into them (e.g. using `cd`).
- Permissions apply to three user categories:
  - **Owner** – The user who owns the file.
  - **Group** – Users in the same group as the file.
  - **Other** – All other users.

- Files and directories can be assigned any combination of the above permissions for each of the three user types.
- Directory permissions work similarly but affect actions like entering (`cd`), listing (`ls`), and modifying contents (e.g. creating or deleting files).

## Changing Permissions with `chmod`
- Use the `chmod` command to change the mode (permissions) of a file or directory.
- Only the file’s **owner** or the **superuser (root)** can change its permissions.
- `chmod` supports two ways of specifying permissions:
  1. **Symbolic representation** (e.g. `u+x`)
  2. **Octal (numeric) representation** (e.g. `764`) — this is what we'll use here.

## Permission Values
| Permission | Symbol | Binary | Octal |
|------------|--------|--------|--------|
| read       | r      | 100    | 4      |
| write      | w      | 010    | 2      |
| execute    | x      | 001    | 1      |

### Example: Setting Permissions with Octal Mode

To set the following permissions for a file named `example1`:

- **Owner**: read, write, execute  
- **Group**: read, write  
- **Other**: read

Run:

```bash
chmod 764 example1
```

Breakdown:
- `7` = read (4) + write (2) + execute (1) → owner
- `6` = read (4) + write (2) → group
- `4` = read (4) → other

## Superuser Command

- One common issue for regular users is the inability to perform certain tasks that require superuser privileges.
- These tasks include installing or updating software, editing system configuration files, and accessing system directories or devices.
- In Windows, this is often done by granting administrative privileges. While this allows users to perform important tasks, it also means any program they run (including malicious ones) inherits those privileges — making the system more vulnerable to malware.
- In Linux, such tasks are handled securely using the `sudo` command, which allows a permitted user to execute a command with elevated (superuser) privileges.
- Let’s try copying a file (`example1`) into a system-protected directory like `/usr/bin`:
```bash
cp example1 /usr/bin
```
- This will return an error such as: `Permission denied`.
- Now try the same operation using `sudo`:
```bash
sudo cp example1 /usr/bin
```
- You will be prompted to enter your password.
- **Note**: When typing passwords in the terminal, nothing will appear — not even asterisks. This is intentional and done to protect the length and visibility of the password input.

# Adding and Removing Software
- During your labs, you may need to install or remove software packages.
- In Linux, the default package manager is the **Advanced Packaging Tool**, or `apt`. You can use either `apt` or `apt-get`. While `apt` is more user-friendly, `apt-get` provides additional functionality and scripting consistency.
- Before installing anything, it's recommended to **update your package list** to ensure you're working with the latest repository data:
```bash
sudo apt-get update
```
- Once updated, you can install software from the repository using the `install` option followed by the package name. For example:
```bash
sudo apt-get install chromium
```
- This installs the Chromium browser (an alternative to Firefox, which comes pre-installed with Kali).
```bash
sudo apt-get install git
```
- This installs Git, a tool used to interact with GitHub and download repositories.
- You can replace `git` with the name of any other package you wish to install.
## Removing Software
- To remove installed software, use the `remove` option:
```bash
sudo apt-get remove chromium
```
- This uninstalls Chromium but may leave behind some configuration files.
- To remove **everything** including config files, use `purge`:
```bash
sudo apt-get purge chromium
```

## Installing from GitHub
- Some software may not be available through `apt`, but can be downloaded from GitHub. First, ensure Git is installed:
```bash
sudo apt-get install git
```
- Then, use `git clone` to download repositories:
```bash
git clone https://github.com/ayman-eh/6CSEF005W.git
```
- In this example, we’re cloning the module repository. This may be updated during the term with new files for your lab work.

# Pipes and Connecting Things
- A **pipe** (`|`) takes the output of one command and passes it as input to another. This is extremely useful when combining simple tools into more powerful workflows.
```bash
echo "this is my first Linux lab" | wc
```
- In this example:
  - `echo` prints the string `"this is my first Linux lab"`.
  - The pipe (`|`) sends that string to the `wc` command.
  - `wc` (word count) then counts the number of **lines**, **words**, and **characters**.
- The output will be:
  ```
  1  6  27
  ```
  - This means: 1 line, 6 words, and 27 characters (including spaces and newline).
- In cybersecurity, we often deal with large log files or lengthy terminal outputs. It can be difficult to locate useful information in such cases.
```bash
grep "kali" /etc/passwd
```
- To add line numbers to the search results, making it easier to locate what you're looking for:
```bash
grep -n "kali" /etc/passwd
```
- The `-n` option displays the matching line numbers along with the content.
# Analysing Logs Using `awk`
- `awk` is another powerful tool for analysing text, especially structured data like logs or CSV files. It’s particularly effective when handling large volumes of data.
- Before using `awk`, ensure you’ve already downloaded the module repository:
```bash
git clone https://github.com/a-elhajjar/6cosc019w.git
cd 6CSEF005W
```
- Suppose you have a file called `users.log` and you want to extract the second column from each line (e.g. usernames or timestamps):
```bash
awk -F '\t' '{print $2}' users.log
```
- Explanation:
  - `-F '\t'` sets the field delimiter to a tab character.
  - `{print $2}` prints the second field from each line.
- If you want to print only the lines where the **first column** equals `"John"`:
```bash
awk '$1 == "John" {print $0}' users.log
```
- This command checks whether the first field equals `"John"`, and if so, prints the entire line.
**Note**: `awk` supports far more advanced operations — including conditional logic, text replacement, field reordering, and more. It’s well worth exploring for anyone working regularly with Linux and data parsing.
# Networking

- To check the IP address of your machine, you can use either `ifconfig` or the modern `ip` command:

```bash
ifconfig
```

```bash
ip address
```

- You can also use the shorthand versions:

```bash
ip a
# or
ip add
```

- These commands list all network interfaces and their associated IP addresses.
- When using `ifconfig` on Kali Linux, you may see several interfaces:
	- `eth0`: your main network interface (often used by the virtual machine)
	- `wlan0`: the wireless network interface (appears if a wireless card is attached)
	- `lo`: the loopback interface (localhost `127.0.0.1`)
	- `docker*`: virtual interfaces created by Docker for container networking

- The loopback (`127.0.0.1`) is commonly used by developers to test services locally.

- For each interface, you'll see details such as:
	- IP address
	- Subnet mask
	- Broadcast address
	- Packet statistics (sent, received, dropped)
	- Interface type (Ethernet, loopback, wireless, etc.)

- In most labs, the only interface we care about is `eth0`, which connects your Kali VM to the Host-Only lab network.
- To show details only for `eth0`:
```bash
ifconfig eth0
```
```bash
ip a show eth0
```
- In our lab setup, we often work within an isolated **Host-Only network**, used for safe penetration testing.
- If you've recently changed your VM’s network setting, you may need to bring `eth0` down and back up:
```bash
sudo ifconfig eth0 down
sudo ifconfig eth0 up
```
- To test basic connectivity, you can ping your host machine (usually `192.168.56.1`):
```bash
ping 192.168.56.1
```
- This sends ICMP requests to the host. To stop the ping process manually, press `Ctrl + C`.
- To limit the number of ping attempts:
```bash
ping -c 5 192.168.56.1
```
# Networking
- To check the IP address of your machine, you can use either `ifconfig` or the more modern `ip` command:
```bash
ifconfig
```

```bash
ip address
# or
ip a
```
- These commands list all network interfaces and their IP addresses.
- When using `ifconfig` on Kali Linux, you may see interfaces such as:
  - `eth0`: the wired (virtual) network interface — used in most VM labs
  - `wlan0`: the wireless network interface (appears if a wireless card is attached)
  - `lo`: the loopback interface (localhost `127.0.0.1`)
  - `docker*`: virtual interfaces created by Docker

## Checking Wireless Interfaces
- To check your wireless interface status (e.g. `wlan0`) and its mode (managed, monitor, etc.), use:
```bash
iwconfig
```
- This command shows wireless-specific info such as:
  - Interface name (e.g. `wlan0`)
  - Mode (`Managed`, `Monitor`, etc.)
  - Frequency
  - Access Point MAC address
  - Signal strength (if connected)
- If `iwconfig` shows `no wireless extensions` for an interface, it means that interface does not support wireless (or it's disabled).
## Checking a Specific Interface (e.g. eth0 or wlan0)
- To show IP details of `eth0`:
```bash
ifconfig eth0
```
```bash
ip a show eth0
```
- To show IP details of `wlan0` (if available):
```bash
ifconfig wlan0
```
```bash
ip a show wlan0
```
## Restarting Interfaces
- If you change a VM's network mode or need to refresh its connection, bring the interface down and up again:
```bash
sudo ifconfig eth0 down
sudo ifconfig eth0 up
```
```bash
sudo ifconfig wlan0 down
sudo ifconfig wlan0 up
```

## Using iw to Manage Wireless Interfaces
The `iw` command is the modern utility for inspecting and configuring wireless interfaces in Linux. It replaces the older iwconfig tool and provides more detailed output and better support for newer drivers.

- View All Wireless Interfaces:
```bash
iw dev
```
- This command lists all wireless interfaces and shows their names, types (managed, monitor), and associated physical devices.

- Get Detailed Information About an Interface: 
```bash
iw lab-wlan info
```
- Displays information such as the interface type, MAC address, channel, and current status.
- To switch to Monitor Mode, you need to enable monitor mode on a wireless interface:
```bash
sudo ip link set lab-wlan down
sudo iw lab-wlan set type monitor
sudo ip link set lab-wlan up
```
- To switch back to managed mode:
```bash
sudo ip link set lab-wlan down
sudo iw lab-wlan set type managed
sudo ip link set lab-wlan up
```
***Note**: You may need to stop interfering services first, using:
```bash
sudo airmon-ng check kill
```
- List Supported Channels: 
```bash
iw list | grep MHz
```
- This shows the channels and frequencies supported by the wireless card. Useful for troubleshooting or custom AP setup.

##  Wireless Interface Modes Explained
Wireless cards can operate in different modes depending on their role in the network. Understanding these modes is essential when working with wireless monitoring, attacks, and AP configuration.

Common Wireless Modes:
| Mode    | Description                                                                                                                          |
| ------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| Managed | Default mode. The card connects to an existing access point as a client.                                                             |
| Monitor | Passive mode. Captures all wireless traffic, including packets not addressed to the interface. Used for reconnaissance and sniffing. |
| Master (AP)  | Also known as AP mode. The card acts as an access point (e.g., when running `hostapd`).                                              |

**Tips for Working with Modes:**
- Use `iwconfig` or `iw dev` to check the current mode.
- Use `ip link set <interface> down` before changing modes.
- After switching, bring the interface back up with `ip link set <interface> up`.


## Connectivity Testing with Ping
- Ping the host machine from the VM (assuming the host-only IP is `192.168.56.1`):

```bash
ping 192.168.56.1
```
- To limit ping attempts:
```bash
ping -c 5 192.168.56.1
```
- Stop continuous ping with `Ctrl + C`.
---


