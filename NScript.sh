#!/bin/bash

echo "###########################################"
echo "#                                         #"
echo "#             NScript                     #"
echo "#      Nmap Script Scanning Tool          #"
echo "#                                         #"
echo "###########################################"


echo "This tool is used for Nmap Scans on your network."
echo "Choose an option to proceed:"
echo "[1] LAN Scanning (Scan your local network)"
echo "[2] Custom IP Scanning (Enter your own IP address)"
read -p "Choose an option (1/2): " scan_option

if [ "$scan_option" -eq "1" ]; then
    echo "Scanning your LAN using arp-scan..."
    sudo arp-scan -l
    read -p "Your LAN has been scanned. Please choose an IP address for further scanning: " Ip
elif [ "$scan_option" -eq "2" ]; then
    read -p "Enter a custom IP address for scanning: " Ip
else
    echo "Invalid option. Exiting."
    exit 1
fi

echo "[1] TCP Scan"
echo "[2] SYN Scan"
echo "[3] FAST Scan"
echo "[4] No Ping Scan"
read -p "Choose an option (1/2/3/4): " No

echo "Installing Nmap if not already installed..."
sudo apt install -y nmap

pri() {
    echo "Scan successful! Output stored in $PWD/scan_results.txt"
}

pri1() {
    xsltproc output.xml -o output.html
    echo "Scan successful HTML file stored in $PWD/output.html"
    sudo rm -rf output.xml
    firefox output.html
}

tcpS() {
    echo "Performing TCP Scan on $Ip..."
    sudo nmap -sT -p- -sV $Ip > scan_results.txt
    pri
}

synS() {
    echo "Performing SYN Scan on $Ip..."
    sudo nmap -sS -p- -sV $Ip > scan_results.txt
    pri
}

fastS() {
    echo "Performing FAST Scan on $Ip..."
    sudo nmap -sS -F -sV $Ip > scan_results.txt
    pri
}

noPingS() {
    echo "Performing No Ping Scan on $Ip..."
    sudo nmap -Pn -p- -sV $Ip > scan_results.txt
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
else
    echo "Invalid option. Please choose 1, 2, 3, or 4."
    exit 1
fi

enumerateport() {
    echo "Extracting open ports from scan results..."
    openports=$(grep "open" scan_results.txt | cut -d '/' -f 1 | sort -u)
    echo "Open Ports:"
    echo "$openports"

    if [ -z "$openports" ]; then
        echo "No open ports found. Exiting."
        exit 1
    else
        read -p "Choose a port for enumeration from the list above: " port
        echo "Enumerating port $port with service and software detection..."

        service=$(grep "$port/tcp" scan_results.txt | awk '{print $3}')
        software=$(grep "$port/tcp" scan_results.txt | awk -F' ' '{for(i=4; i<=NF; i++) printf $i " "; print ""}' | sed 's/ $//')

        service=${service:-"unknown"}
        software=${software:-"unknown"}

        echo "Service: $service"
        echo "Software: $software"
        echo "Port: $port"
        echo "IP: $Ip"

        service_scripts=$(ls /usr/share/nmap/scripts | grep -i "$service" | wc -l)
        software_scripts=$(ls /usr/share/nmap/scripts | grep -i "$software" | wc -l)

        echo "Number of service-related scripts found: $service_scripts"
        echo "Number of software-related scripts found: $software_scripts"

        if [ "$service_scripts" -gt "$software_scripts" ]; then
            echo "Service scripts are greater. Running service-related scripts."
            scripts=$(ls /usr/share/nmap/scripts | grep -i "$service" | tr '\n' ',' | sed 's/,$//')
            echo "Running service scripts: $scripts"
            sudo nmap -sV -vv -p $port --script="$scripts" -oX output.xml $Ip
            pri1
        elif [ "$software_scripts" -gt "$service_scripts" ]; then
            echo "Software scripts are greater. Running software-related scripts."
            scripts=$(ls /usr/share/nmap/scripts | grep -i "$software" | tr '\n' ',' | sed 's/,$//')
            echo "Running software scripts: $scripts"
            sudo nmap -sV -vv -p $port --script="$scripts" -oX output.xml $Ip
            pri1
        else
            echo "Both service and software scripts are equal or none found. Running default scripts."
            sudo nmap -sC -vv -sV -p $port -oX output.xml $Ip
            pri1
        fi
    fi
}

enumerateport
