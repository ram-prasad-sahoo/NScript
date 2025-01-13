#!/bin/bash


RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"  

echo -e "${CYAN}###########################################"
echo -e "#                                         #"
echo -e "#             ${MAGENTA}NScript${CYAN}                     #"
echo -e "#      ${MAGENTA}Nmap Script Scanning Tool${CYAN}          #"
echo -e "#                                         #"
echo -e "###########################################${RESET}"

echo -e "${BLUE}This tool is used for Nmap Scans on your network.${RESET}"
echo -e "${GREEN}Choose an option to proceed:${RESET}"
echo -e "[1] LAN Scanning (Scan your local network)"
echo -e "[2] Custom IP Scanning (Enter your own IP address)"
read -p "Choose an option (1/2): " scan_option

if [ "$scan_option" -eq "1" ]; then
    echo -e "${YELLOW}Scanning your LAN using arp-scan...${RESET}"
    sudo arp-scan -l
    read -p "Your LAN has been scanned. Please choose an IP address for further scanning: " Ip
elif [ "$scan_option" -eq "2" ]; then
    read -p "Enter a custom IP address for scanning: " Ip
else
    echo -e "${RED}Invalid option. Exiting.${RESET}"
    exit 1
fi

echo -e "${GREEN}[1] TCP Scan${RESET}"
echo -e "${GREEN}[2] SYN Scan${RESET}"
echo -e "${GREEN}[3] FAST Scan${RESET}"
echo -e "${GREEN}[4] No Ping Scan${RESET}"
echo -e "${GREEN}[5] Aggressive Scan${RESET}"
read -p "Choose an option (1/2/3/4/5): " No

echo -e "${YELLOW}Installing Nmap if not already installed...${RESET}"
sudo apt install -y nmap

pri() {
    echo -e "${CYAN}Scan successful! Output stored in $PWD/scan_results.txt${RESET}"
}

pri1() {
    xsltproc output.xml -o output.html
    echo -e "${CYAN}Scan successful HTML file stored in $PWD/output.html${RESET}"
    sudo rm -rf output.xml
    firefox output.html
}

tcpS() {
    echo -e "${YELLOW}Performing TCP Scan on $Ip...${RESET}"
    sudo nmap -sT -p- -sV $Ip > scan_results.txt
    pri
}

synS() {
    echo -e "${YELLOW}Performing SYN Scan on $Ip...${RESET}"
    sudo nmap -sS -p- -sV $Ip > scan_results.txt
    pri
}

fastS() {
    echo -e "${YELLOW}Performing FAST Scan on $Ip...${RESET}"
    sudo nmap -sS -F -sV $Ip > scan_results.txt
    pri
}

noPingS() {
    echo -e "${YELLOW}Performing No Ping Scan on $Ip...${RESET}"
    sudo nmap -Pn -p- -sV $Ip > scan_results.txt
    pri
}

aggressiveS() {
    echo -e "${YELLOW}Performing Aggressive Scan on $Ip...${RESET}"
    sudo nmap -A $Ip > scan_results.txt
    pri
}

if [ "$No" -eq "1" ]; then
    tcpS
elif [ "$No" -eq "2" ]; then
    synS
elif [ "$No" -eq "3" ]; then
    fastS
elif [ "$No" -eq "4" ]; then
    noPingS
elif [ "$No" -eq "5" ]; then
    aggressiveS
else
    echo -e "${RED}Invalid option. Please choose 1, 2, 3, 4, or 5.${RESET}"
    exit 1
fi

enumerateport() {
    echo -e "${CYAN}Extracting open ports, services, and versions from scan results...${RESET}"
    echo -e "${GREEN}Open Ports | Service | Version${RESET}"
    echo -e "--------------------------------------------"
    grep "open" scan_results.txt | awk '{printf "%s | %s | %s\n", $1, $3, $4}' | column -t -s '|'

    openports=$(grep "open" scan_results.txt | cut -d '/' -f 1 | sort -u)
    
    if [ -z "$openports" ]; then
        echo -e "${RED}No open ports found. Exiting.${RESET}"
        exit 1
    else
        read -p "Choose a port for enumeration from the list above: " port
        echo -e "${CYAN}Enumerating port $port with service and software detection...${RESET}"

        service=$(grep "$port/tcp" scan_results.txt | awk '{print $3}')
        software=$(grep "$port/tcp" scan_results.txt | awk -F' ' '{for(i=4; i<=NF; i++) printf $i " "; print ""}' | sed 's/ $//')

        service=${service:-"unknown"}
        software=${software:-"unknown"}

        echo -e "${MAGENTA}Service: $service${RESET}"
        echo -e "${MAGENTA}Software: $software${RESET}"
        echo -e "${MAGENTA}Port: $port${RESET}"
        echo -e "${MAGENTA}IP: $Ip${RESET}"

        service_scripts=$(ls /usr/share/nmap/scripts | grep -i "$service" | wc -l)
        software_scripts=$(ls /usr/share/nmap/scripts | grep -i "$software" | wc -l)

        echo -e "${CYAN}Number of service-related scripts found: $service_scripts${RESET}"
        echo -e "${CYAN}Number of software-related scripts found: $software_scripts${RESET}"

        if [ "$service_scripts" -gt "$software_scripts" ]; then
            echo -e "${GREEN}Service scripts are greater. Running service-related scripts.${RESET}"
            scripts=$(ls /usr/share/nmap/scripts | grep -i "$service" | tr '\n' ',' | sed 's/,$//')
            echo -e "${CYAN}Running service scripts: $scripts${RESET}"
            sudo nmap -sV -vv -p $port --script="$scripts" -oX output.xml $Ip
            pri1
        elif [ "$software_scripts" -gt "$service_scripts" ]; then
            echo -e "${GREEN}Software scripts are greater. Running software-related scripts.${RESET}"
            scripts=$(ls /usr/share/nmap/scripts | grep -i "$software" | tr '\n' ',' | sed 's/,$//')
            echo -e "${CYAN}Running software scripts: $scripts${RESET}"
            sudo nmap -sV -vv -p $port --script="$scripts" -oX output.xml $Ip
            pri1
        else
            echo -e "${YELLOW}Both service and software scripts are equal or none found. Running default scripts.${RESET}"
            sudo nmap -sC -vv -sV -p $port -oX output.xml $Ip
            pri1
        fi
    fi
}

enumerateport
