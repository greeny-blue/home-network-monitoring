# homemap

`homemap` is a small experimental network discovery tool designed for **learning, exploration and home network visibility**.

The goal of the project is to gradually build a lightweight tool that performs some of the core functions of tools such as **Nmap**, while remaining simple enough to understand at a systems level.

Rather than immediately building a complex scanner, Homemap is being developed **iteratively**, with each phase introducing a small number of new capabilities and documenting the reasoning behind them.

The focus is on understanding:

- how devices appear on a network
- how discovery techniques work
- how operating systems handle networking tools
- how scanners balance accuracy, speed and reliability

The tool is intended for **benign use on networks you own or have permission to test**, such as a home network.

---

## Current Capabilities

The first phase of Homemap implements a simple **ICMP-based host discovery scanner**.

It can:

- Accept a CIDR network range
- Enumerate potential host IP addresses
- Send ICMP echo requests (ping)
- Identify responsive hosts
- Run scans in parallel for improved speed
- Operate consistently on **macOS and Linux**

This provides a baseline method of identifying which devices are reachable on a network.

However, ICMP discovery has limitations:

- Some hosts disable ping responses
- Firewalls may block ICMP
- A device may exist even if it does not respond

Later phases address these limitations.

---

## Design Philosophy

`homemap` is intentionally built in **small steps**.

Each phase:

- adds a small number of features
- documents design decisions
- keeps the implementation understandable

The aim is not to compete with mature tools like Nmap, but to understand **how such tools work internally**.

A design journal in this repository records the reasoning behind each development step.

---

## Roadmap

The project is structured into clear development phases.

### [Phase 1 — ICMP Host Discovery](https://github.com/greeny-blue/home-network-monitoring/tree/main/homemap/phase01_icmp)
Baseline network scanner.

Features:
- CIDR-based host enumeration
- ICMP echo probing
- configurable timeout
- controlled parallelisation
- cross-platform behaviour (macOS / Linux)

Purpose:
- establish basic host discovery
- validate scanning workflow
- identify portability issues

---

### Phase 2 — ARP-Based Local Discovery
Improve host detection on local networks.

Planned additions:
- ARP request scanning
- MAC address collection
- vendor lookup (OUI)

Why:
ARP operates at the data-link layer and typically provides **more reliable host discovery within a local subnet**.

---

### Phase 3 — Port Scanning
Identify exposed services on discovered hosts.

Planned additions:
- TCP SYN scanning
- common port enumeration
- service availability detection

Purpose:
Determine **what services devices on the network are exposing**.

---

### Phase 4 — Service Identification
Understand what software is running.

Planned additions:
- service fingerprinting
- version detection
- banner grabbing

Purpose:
Provide context for discovered services.

---

### Phase 5 — Vulnerability Context
Provide security insight.

Planned additions:
- mapping detected services to known vulnerabilities
- optional CVE lookups

Purpose:
Highlight **potential security issues on the network**.

---

### Phase 6 — Network Behaviour Observation
Explore network activity patterns.

Possible additions:
- passive packet observation
- traffic summaries
- anomaly detection experiments

Purpose:
Better understand **normal behaviour on a home network**.

---

## Project Structure
homemap/
│
├─ phase01_icmp/
│ ├─ ping_local_hosts_v0.sh
│ ├─ ping_local_hosts_v1.sh
│ ├─ ping_local_hosts_v2.sh
│ ├─ ping_local_hosts_v3.sh
│ ├─ DESIGN_EVOLUTION.md
│ └─ DESIGN_EVOLUTION_SUMMARY.md
│
├─ phase02_arp/
│ ├─ COMING SOON!
│
├─ DESIGN_JOURNAL.md COMING SOON!
│
└─ README.md

---

## Disclaimer

`homemap` is intended for **educational and defensive use**.

Only run network scanning tools on:

- networks you own, or
- networks where you have explicit permission to do so.

Scanning networks without permission may violate local laws or policies.

---

## Motivation

Understanding network discovery tools is valuable for:

- cybersecurity learning
- home network visibility
- troubleshooting
- understanding how attackers enumerate networks

By building a scanner incrementally, Homemap aims to make these concepts transparent and approachable.
