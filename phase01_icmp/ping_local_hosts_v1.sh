#!/usr/bin/env bash

set -u

# ---- Graceful Ctrl+C handling ----
trap 'echo; echo "Scan interrupted."; exit 1' INT

# ---- Validate argument ----
if [ $# -lt 1 ]; then
  echo "Usage: $0 <CIDR>"
  echo "Example: $0 192.168.1.0/24"
  exit 1
fi

CIDR="$1"

# ---- Validate CIDR using Python ----
if ! python3 - <<EOF >/dev/null 2>&1
import ipaddress
ipaddress.ip_network("$CIDR", strict=False)
EOF
then
  echo "Error: Invalid CIDR format: $CIDR"
  exit 1
fi

echo "Scanning $CIDR..." >&2
echo "Listing hosts that are up (if any):" >&2
echo >&2

COUNT=0

while IFS= read -r TARGET; do
  if ping -c 1 -W 1000 "$TARGET" >/dev/null 2>&1; then
    echo "$TARGET"
    COUNT=$((COUNT + 1))
  fi
done < <(python3 - <<EOF
import ipaddress
net = ipaddress.ip_network("$CIDR", strict=False)
for host in net.hosts():
    print(host)
EOF
)

echo >&2
echo "Scan complete. Responsive hosts: $COUNT" >&2
