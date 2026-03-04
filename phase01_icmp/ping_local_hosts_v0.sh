#!/bin/bash

# ---- Validate argument ----
if [ -z "$1" ]; then
    echo "Usage: $0 <CIDR>"
    echo "Example: $0 192.168.1.0/24"
    exit 1
fi

CIDR="$1"

# ---- Basic format check ----
if [[ ! "$CIDR" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/24$ ]]; then
    echo "Error: Only /24 CIDR blocks supported (e.g., 192.168.1.0/24)"
    exit 1
fi

# ---- Extract base IP ----
BASE_IP="${CIDR%/*}"

# Extract first three octets
OCTET1=$(echo "$BASE_IP" | cut -d. -f1)
OCTET2=$(echo "$BASE_IP" | cut -d. -f2)
OCTET3=$(echo "$BASE_IP" | cut -d. -f3)

NETWORK_PREFIX="$OCTET1.$OCTET2.$OCTET3"

echo "Scanning $NETWORK_PREFIX.0/24..."
echo

RESPONSIVE=()

# ---- Loop through host range ----
for HOST in {1..254}; do
    TARGET="$NETWORK_PREFIX.$HOST"

    # -c 1 = send 1 packet
    # -W 1000 = 1000ms timeout (macOS uses milliseconds)
    ping -c 1 -W 1000 "$TARGET" > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "[UP] $TARGET"
        RESPONSIVE+=("$TARGET")
    fi
done

echo
echo "Scan complete."
echo "Responsive hosts: ${#RESPONSIVE[@]}"
