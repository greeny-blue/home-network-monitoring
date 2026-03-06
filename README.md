# Home Network Monitoring

A small collection of tools for exploring and understanding activity on a local network.

This repository contains experimental utilities built while learning more about networking, cybersecurity and systems programming. The aim is to create simple, transparent tools that help reveal what is happening on a typical home network.

The focus is on **understanding network behaviour**, **identifying connected devices** and **observing traffic patterns** in an increasingly complex environment of personal computers, mobile devices and IoT hardware.

---

## Projects

### [homemap](https://github.com/greeny-blue/home-network-monitoring/tree/main/homemap)

`homemap` is a lightweight local network enumeration tool inspired by the basic functionality of tools such as Nmap.

The project charts the development of my understanding of networking and tool-building abilities, resulting in a simple implementation that demonstrates how host discovery and port scanning work under the hood.

Planned capabilities include:

- Local subnet host discovery
- ARP-based device identification
- Basic TCP port scanning
- MAC address collection
- Vendor lookup via OUI
- Simple reporting of discovered hosts and services

The project is being built iteratively, starting from simple ICMP and bash-based discovery tools and gradually expanding toward a more complete Python-based scanner.

The emphasis is on **clarity of implementation and learning**, rather than speed or stealth.

---

### (Planned) Network Traffic Observation Tool

A second tool is planned that will focus on **observing traffic on a home network**.

Modern homes increasingly contain dozens of connected devices — smart TVs, cameras, speakers, appliances and other IoT devices — many of which communicate frequently with external services.

The aim of this tool is to explore whether lightweight monitoring of local network traffic can provide insights such as:

- Which devices are communicating
- Where traffic is being sent
- Approximate traffic volumes
- When devices are most active

This may provide a perspective somewhat similar to what a router can observe, helping users better understand the behaviour of devices connected to their network.

The implementation details and capabilities are still evolving.

---

## Motivation

Home networks are becoming increasingly complex and opaque.

Most users have little visibility into:

- what devices are connected
- what services they expose
- what external systems they communicate with
- how frequently they transmit data

This repository explores ways to **make network behaviour more visible using simple, transparent tooling**.

---

## Disclaimer

These tools are intended **for educational purposes and for monitoring networks you own or are authorised to test**.

Do not use them to scan or monitor networks without permission.

---

## Status

This project is under active development and will evolve as new networking and security concepts are explored.
