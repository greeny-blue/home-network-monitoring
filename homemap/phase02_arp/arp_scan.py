# Meant to mimic `sudo nmap -sn <CIDR>` (without vendor identification)

# IMPORTANT
# Do not run on a network that you do not own
# Run as administrator (because these are ARP requests): sudo python3 arp_scan.py
# Disable VPN, if running

# arp_scan parameters
# timeout=3 is very conservative to allow for slower-responding devices
# retries=2 gives devices 3 chances to respond (arp_scan(retries) = srp(inter))
# delay=0.02 introduces a short interval between requests (arp_scan(delay) = srp(inter))

# Recognised that this is simple and professional tools might have to negotiate:
# VPN adapters, Docker bridges, VMs, loopbank and/or multiple NICs
# Consider cleaner exits if there are errors


# --- Get local subnet

import socket
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.connect(("8.8.8.8", 80))
local_ip = s.getsockname()[0]
s.close()

# --- Scan interfaces and retrieve subnet mask for local_ip

import netifaces
def get_interface_from_ip(local_ip):
    for interface in netifaces.interfaces():
        addrs = netifaces.ifaddresses(interface)

        if netifaces.AF_INET in addrs:
            for addr in addrs[netifaces.AF_INET]:
                if addr.get("addr") == local_ip:
                    return interface, addr["netmask"]

    return None, None

# --- Define network as CIDR

import ipaddress
interface, mask = get_interface_from_ip(local_ip)

import sys
if mask == "255.255.255.255":
    print("[!] Error: /32 network detected (likely a VPN). homemap requires a local LAN.")
    sys.exit(1)

subnet = ipaddress.IPv4Network(f"{local_ip}/{mask}", strict=False)

# --- Generate list of hosts

potential_host_list = list(subnet.hosts())

# --- Send ARP packets to potential hosts and print responses

from scapy.all import ARP, Ether, srp
"""
ARP	    builds an ARP protocol packet
Ether   builds an Ethernet frame
srp	    sends packets at Layer 2 and receives responses ([s]end/[r]eceive [p]ackets)
"""

def arp_scan(hosts, timeout=3, delay=0.02, retries=2, return_hosts_only = True):
    """
    Perform an ARP scan against a list of hosts.

    Parameters
    ----------
    hosts : list
        List of IP addresses (strings or IPv4Address objects)
    timeout : int
        Time to wait for replies
    delay : float [=srp(inter)]
        Delay between packets (seconds)
    retries : int [=srp(retry)]
        Number of extra rquests sent to host

    Returns
    -------
    list of dict
        [{"ip": "...", "mac": "..."}]
    """

    hosts = [str(ip) for ip in hosts]

    arp = ARP(pdst=hosts)
    ether = Ether(dst="ff:ff:ff:ff:ff:ff")
    packet = ether / arp

    ans, _ = srp(packet, timeout=timeout, verbose=False, inter=delay, retry=retries)

    discovered = []

    for sent, received in ans:
        discovered.append({
            "ip": received.psrc,
            "mac": received.hwsrc
        })

    return discovered

active_hosts = arp_scan(potential_host_list)

for host in active_hosts:
    print(f'{host["ip"]:<15} {host["mac"]}')