# Phase 1 — ICMP Baseline Scanner

## v1 — Sequential Prototype
- /24 only
- No concurrency
- Basic CIDR handling
- ICMP only

## v2 — Configurable Timeout
- Introduced timeout parameter
- Highlighted OS-specific flag behaviour

## v3 — Controlled Parallelisation
- Background jobs
- Concurrency cap
- Performance trade-off discussion

## v4 — Cross-Platform Normalisation
- OS detection via uname
- Timeout unit conversion (ms → s on Linux)
- Explicit environment reporting

## Lessons Learned
- ICMP ≠ host existence
- Cross-platform CLI flags are not uniform
- Concurrency must be bounded