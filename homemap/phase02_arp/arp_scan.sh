#!/usr/bin/env python3

# Meant to mimic `sudo nmap -sn <CIDR>` but without vendor lookup (this will come separately)

# IMPORTANT
# Do not run on a network that you do not own
# Run as administrator (because these are ARP requests): sudo ./homemap
# Disable VPN if running

import socket
import netifaces
import ipaddress
import sys
import argparse
from scapy.all import ARP, Ether, srp


# ----------------------------
# CLI arguments
# ----------------------------

parser = argparse.ArgumentParser(
    description="Simple ARP network scanner (similar to `nmap -sn` for local LAN)"
)

parser.add_argument(
    "-t", "--timeout",
    type=int,
    default=3,
    help="Time to wait for replies (default: 3)"
)

parser.add_argument(
    "-d", "--delay",
    type=float,
    default=0.02,
    help="Delay between packets (default: 0.02)"
)

parser.add_argument(
    "-r", "--retries",
    type=int,
    default=2,
    help="Number of retries (default: 2)"
)

parser.add_argument(
    "-v", "--verbose",
    action="store_true",
    help="Enable descriptive output"
)

args = parser.parse_args()


# ----------------------------
# Get local IP
# ----------------------------

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.connect(("8.8.8.8", 80))
local_ip = s.getsockname()[0]
s.close()


# ----------------------------
# Find interface + subnet mask
# ----------------------------

def get_interface_from_ip(local_ip):

    for interface in netifaces.interfaces():

        addrs = netifaces.ifaddresses(interface)

        if netifaces.AF_INET in addrs:

            for addr in addrs[netifaces.AF_INET]:

                if addr.get("addr") == local_ip:

                    return interface, addr["netmask"]

    return None, None


interface, mask = get_interface_from_ip(local_ip)


# ----------------------------
# Exit if VPN /32 network
# ----------------------------

if mask == "255.255.255.255":

    print("[!] Error: /32 network detected (likely a VPN). homemap requires a local LAN.")
    sys.exit(1)


# ----------------------------
# Define subnet
# ----------------------------

subnet = ipaddress.IPv4Network(f"{local_ip}/{mask}", strict=False)

# ----------------------------
# Generate host list
# ----------------------------

potential_host_list = list(subnet.hosts())

if args.verbose:
    print(f"[+] LAN subnet detected: {subnet}")
    print(f"[+] Potential hosts to scan for: {len(potential_host_list)}")
    print(f"[+] timeout={args.timeout} delay={args.delay} retries={args.retries}")


# ----------------------------
# ARP scanning function
# ----------------------------

def arp_scan(hosts, timeout=3, delay=0.02, retries=2):

    """
    Perform an ARP scan against a list of hosts.

    Parameters
    ----------
    hosts : list
        List of IP addresses
    timeout : int
        Time to wait for replies
    delay : float
        Delay between packets
    retries : int
        Number of extra requests

    Returns
    -------
    list of dict
        [{"ip": "...", "mac": "..."}]
    """

    hosts = [str(ip) for ip in hosts]

    arp = ARP(pdst=hosts)

    ether = Ether(dst="ff:ff:ff:ff:ff:ff")

    packet = ether / arp

    ans, _ = srp(
        packet,
        timeout=timeout,
        verbose=False,
        inter=delay,
        retry=retries
    )

    discovered = []

    for sent, received in ans:

        discovered.append({
            "ip": received.psrc,
            "mac": received.hwsrc
        })

    return discovered


# ----------------------------
# Run scan
# ----------------------------

active_hosts = arp_scan(
    potential_host_list,
    timeout=args.timeout,
    delay=args.delay,
    retries=args.retries
)


# ----------------------------
# Print results
# ----------------------------

for host in sorted(active_hosts, key=lambda x: ipaddress.IPv4Address(x["ip"])):

    print(f'{host["ip"]:<15} {host["mac"]}')
