# NScript - Nmap Script Scanning Tool

NScript is a powerful and easy-to-use tool for performing network scanning and enumeration using Nmap. It provides a streamlined approach for scanning networks, identifying open ports, and running relevant Nmap scripts based on the discovered services and software.

## Features

- **LAN Scanning:** Scan your local network using `arp-scan`.
- **Custom IP Scanning:** Perform scans on any custom IP address.
- **Multiple Scan Types:** Choose from TCP Scan, SYN Scan, Fast Scan, or No Ping Scan.
- **Port Enumeration:** Automatically extracts open ports and provides detailed enumeration using service or software detection.
- **Script Automation:** Runs relevant Nmap scripts based on detected services and software.

## Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/NScript.git
cd NScript
```
2.Make the script executable:

   ```bash
   chmod +x NScript.sh
   ```
## Usage <br>
Run the script:
   ```bash
  ./nscript.sh
```
## Example
```bash
###########################################
#                                         #
#             NScript                     #
#      Nmap Script Scanning Tool          #
#                                         #
###########################################

This tool is used for Nmap Scans on your network.
Choose an option to proceed:
[1] LAN Scanning (Scan your local network)
[2] Custom IP Scanning (Enter your own IP address)
Choose an option (1/2): 1
Scanning your LAN using arp-scan...
Choose an IP address for further scanning: 192.168.1.10
[1] TCP Scan
[2] SYN Scan
[3] FAST Scan
[4] No Ping Scan
Choose an option (1/2/3/4): 1
Performing TCP Scan on 192.168.1.10...
Scan successful! Output stored in /home/user/NScript/scan_results.txt
```
## Contributing
Feel free to contribute by submitting issues or pull requests. If you find any bugs or have feature suggestions, please open an issue.
