#!/bin/bash

# ETH_INTERFACE=enp0s31f6
# WIFI_INTERFACE=wlp4s0
EXTERNAL_INTERFACE=enp0s31f6
EXTERNAL_INTERFACE_IP=`ifconfig enp0s31f6 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`

echo "This script will setup NAT and PORTFORWARDING for z/VM VSWITCH via zPDT tun interface for EXTERNAL ACCESS."
echo "Ubuntu ufw needs to be disabled, iptables needs to be ACCEPTING both FORWARD and INPUT processing."
echo "Use domain name when connected to Internet: zos.duckdns.org"
echo "Currently configured IP address:"
ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'
echo "Script assumes external NIC being Ethernet("$EXTERNAL_INTERFACE"), change to Wifi(wlp4s0) if needed."
echo "Also make sure packet forwarding has been enabled in /etc/sysctl.conf"

echo "Flushing nat table."
iptables -t nat -F
# iptables -P FORWARD ACCEPT
# iptables -I INPUT -p tcp --dport 23 -j ACCEPT

# NAT - for outgoing traffic from 10.1.1.*
echo "Installing rules for NAT." 
iptables -t nat -A POSTROUTING -s 10.1.1.0/24 -o $EXTERNAL_INTERFACE -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.2.1.0/24 -o $EXTERNAL_INTERFACE -j MASQUERADE

# PORTFORWARDING - for incoming traffic to z/VM network
echo "Installing rules for PORT FORWARDING."
echo "Access Master Console at external:3270"

echo "Adding external:8023  --> z/OS TCP/IP 3270		: 10.1.1.3:23 "
iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp --dport 8023 -j DNAT --to-destination 10.1.1.3:23 
echo "Adding external:1022  --> z/OS OMVS SSH			: 10.1.1.3:22 "
iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp --dport 1022 -j DNAT --to-destination 10.1.1.3:22
echo "Adding external:4414  --> z/OS Broker WebUI		: 10.1.1.3:4414 "
iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp --dport 4414 -j DNAT --to-destination 10.1.1.3:4414
echo "Adding external:1416  --> z/OS MQ Channel Listener	: 10.1.1.3:1416 "
iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp --dport 1416 -j DNAT --to-destination 10.1.1.3:1416
echo "Adding external:1490  --> CICSTS53 CMCI			: 10.1.1.3:1490 "
iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp --dport 1490 -j DNAT --to-destination 10.1.1.3:1490
echo "Adding external:4035+ --> z/OS IBM Explorer		: 10.1.1.3:4035,6715,18108-18109"
iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp -m multiport --dports 4035,6715,18108:18109 -j DNAT --to-destination 10.1.1.3
echo "Adding external:8021  --> z/OS FTP			: 10.1.1.3:21 (FTP PASV PORTRANGE: 50000:50009) "
iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp --dport 8021 -j DNAT --to-destination 10.1.1.3:21
iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp --dport 50000:50009 -j DNAT --to-destination 10.1.1.3
echo "Adding external:9445  --> z/OS Connect EE JWT		: 10.1.1.3:8445 (NONSHAREDPORT)"
iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp --dport 9445 -j DNAT --to-destination 10.1.1.3:8445
echo "Adding external:9444  --> z/OS Connect EE CLIENT AUTH	: 10.1.1.3:8444 (NONSHAREDPORT)"
iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp --dport 9444 -j DNAT --to-destination 10.1.1.3:8444
echo "Adding external:9443  --> z/OS Connect EE HTTPS		: 10.1.1.3:8443 (SHAREDPORT)"
iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp --dport 9443 -j DNAT --to-destination 10.1.1.3:8443
echo "Adding external:10443 --> z/OS Management Facility	: 10.1.1.3:10443"
iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp --dport 10443 -j DNAT --to-destination 10.1.1.3:10443
echo "------------------------------------------------------------------------------------------------------"
echo "Adding external:8222  --> ICP Master SSH  		: 10.2.1.2:22 "
iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp --dport 8222 -j DNAT --to-destination 10.2.1.2:22
echo "Adding external:8243  --> ICP Master Console		: 10.2.1.2:8443 "
iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp --dport 8243 -j DNAT --to-destination 10.2.1.2:8443

#echo "Adding external:8123  --> z/VM TCP/IP 3270		: 10.1.1.2:23 "
#iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp --dport 8123 -j DNAT --to-destination 10.1.1.2:23
#echo "Adding external:8022  --> Fabric zLinux SSH		: 10.1.1.4:22 "
#iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp --dport 8022 -j DNAT --to-destination 10.1.1.4:22
#echo "Adding external:8122  --> ICP zLinux SSH  		: 10.1.1.5:22 "
#iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -p tcp --dport 8122 -j DNAT --to-destination 10.1.1.5:22

# echo "Updating NAT-PMP for upstream port forwarding."
# upnpc -e "zPDT Port Forwarding" \
#      -r 3270 TCP 8023 TCP 1022 TCP 4414 TCP 1416 TCP 1490 TCP 4035 TCP 6715 TCP 18108 TCP 18109 TCP \
#         8021 TCP 50000 TCP 50001 TCP 50002 TCP 50003 TCP 50004 TCP 50005 TCP 50006 TCP 50007 TCP 50008 TCP 50009 TCP \
#         9444 TCP 9443 TCP 9080 TCP 10443 TCP 8222 TCP 8243 TCP > /dev/null
echo "Completed."
