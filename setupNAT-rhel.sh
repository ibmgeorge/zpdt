#!/bin/bash

# ETH_INTERFACE=enp0s31f6
# WIFI_INTERFACE=wlp4s0
EXTERNAL_INTERFACE=enp0s31f6
EXTERNAL_INTERFACE_IP=`ifconfig enp0s31f6 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`

echo "This script will setup NAT and PORTFORWARDING for zPDT tun interface for EXTERNAL ACCESS."
echo "Tested on Redhat Enterprise Linux using firewalld"
echo "Use domain name when connected to Internet: zos.duckdns.org"
echo "Currently configured IP address:"
ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'
echo "Script assumes external NIC being Ethernet("$EXTERNAL_INTERFACE"), change to Wifi(wlp4s0) if needed."
echo "Also make sure packet forwarding has been enabled in /etc/sysctl.conf"

echo "Enabling masquerade for outgoing traffics." 
sudo firewall-cmd --add-masquerade

echo "Adding port forwarding for incoming traffics."
echo "Services available: "
echo "------------------------------------------------------------------------------"
echo "IP:3270  --> z/PDT Master Console"
echo "IP:8023  --> z/OS TCP/IP 3270	        : 10.1.1.2:23"
echo "IP:1022  --> z/OS OMVS SSH			: 10.1.1.2:22"
echo "IP:4414  --> z/OS Broker WebUI		: 10.1.1.2:4414"
echo "IP:1414  --> z/OS MQ Channel Listener	: 10.1.1.2:1414"
echo "IP:1490  --> CICSTS53 CMCI			: 10.1.1.2:1490"
echo "IP:4035+ --> z/OS IBM Explorer		: 10.1.1.2:4035,6715,18108-18109"
echo "IP:8021+ --> z/OS FTP			        : 10.1.1.2:21 (PASV PORTS: 50000-50009)"
echo "IP:9445  --> zCEE JWT         		: 10.1.1.2:8445 (NONSHAREDPORT)"
echo "IP:9444  --> zCEE CLIENT AUTH	        : 10.1.1.2:8444 (NONSHAREDPORT)"
echo "IP:9443  --> zCEE HTTPS SHARED PORT   : 10.1.1.2:8443 (SHAREDPORT)"
echo "IP:10443 --> z/OS Management Facility	: 10.1.1.2:10443"

sudo firewall-cmd --add-forward-port=port=8023:proto=tcp:toport=23:toaddr=10.1.1.2
sudo firewall-cmd --add-forward-port=port=1022:proto=tcp:toport=22:toaddr=10.1.1.2
sudo firewall-cmd --add-forward-port=port=4414:proto=tcp:toport=4414:toaddr=10.1.1.2
sudo firewall-cmd --add-forward-port=port=1414:proto=tcp:toport=1414:toaddr=10.1.1.2
sudo firewall-cmd --add-forward-port=port=1490:proto=tcp:toport=1490:toaddr=10.1.1.2
sudo firewall-cmd --add-forward-port=port=1234:proto=tcp:toport=1234:toaddr=10.1.1.2
sudo firewall-cmd --add-forward-port=port=11234:proto=tcp:toport=11234:toaddr=10.1.1.2
sudo firewall-cmd --add-forward-port=port=4035:proto=tcp:toport=4035:toaddr=10.1.1.2
sudo firewall-cmd --add-forward-port=port=6715:proto=tcp:toport=6715:toaddr=10.1.1.2
sudo firewall-cmd --add-forward-port=port=18108:proto=tcp:toport=18108:toaddr=10.1.1.2
sudo firewall-cmd --add-forward-port=port=18109:proto=tcp:toport=18109:toaddr=10.1.1.2

sudo firewall-cmd --add-forward-port=port=8021:proto=tcp:toport=21:toaddr=10.1.1.2
sudo firewall-cmd --add-forward-port=port=50000-50009:proto=tcp:toport=50000-50009:toaddr=10.1.1.2

sudo firewall-cmd --add-forward-port=port=9445:proto=tcp:toport=8445:toaddr=10.1.1.2
sudo firewall-cmd --add-forward-port=port=9444:proto=tcp:toport=8444:toaddr=10.1.1.2
sudo firewall-cmd --add-forward-port=port=9443:proto=tcp:toport=8443:toaddr=10.1.1.2

sudo firewall-cmd --add-forward-port=port=10443:proto=tcp:toport=10443:toaddr=10.1.1.2

echo "RHEL Setup Completed."
