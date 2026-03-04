#!/usr/bin/env bash

set -u

trap 'echo; echo "Scan interrupted."; exit 1' INT

# ---- Validate argument ----
if [ $# -lt 1 ]; then
  echo "Usage: $0 <CIDR> [timeout_ms=500] [max_jobs=10]" >&2
  echo "Ensure timeout_ms is an integer (milliseconds)" >&2
  exit 1
fi

CIDR="$1"
TIMEOUT="${2:-500}"
MAX_JOBS="${3:-10}"

# ---- Validate numeric inputs ----
if ! [[ "$TIMEOUT" =~ ^[0-9]+$ ]]; then
  echo "Error: timeout_ms must be an integer (milliseconds)." >&2
  exit 1
fi

if ! [[ "$MAX_JOBS" =~ ^[0-9]+$ ]]; then
  echo "Error: max_jobs must be an integer." >&2
  exit 1
fi

# ---- Detect OS ----
OS="$(uname)"

if [ "$OS" = "Darwin" ]; then
    OS_NAME="macOS"
    # macOS expects milliseconds
    PING_TIMEOUT="$TIMEOUT"

elif [ "$OS" = "Linux" ]; then
    OS_NAME="Linux"
    # Linux ping -W expects seconds (can be fractional)
    PING_TIMEOUT=$(awk "BEGIN {printf \"%.3f\", $TIMEOUT/1000}")

else
    echo "Unsupported OS: $OS" >&2
    exit 1
fi

echo "Detected OS: $OS_NAME" >&2

# ---- Validate CIDR ----
if ! python3 - <<EOF >/dev/null 2>&1
import ipaddress
ipaddress.ip_network("$CIDR", strict=False)
EOF
then
  echo "Error: Invalid CIDR format: $CIDR" >&2
  exit 1
fi

echo "Scanning $CIDR..." >&2
echo "Timeout: ${TIMEOUT}ms | Max parallel jobs: $MAX_JOBS" >&2
echo >&2

COUNT=0

scan_host() {
  local TARGET="$1"
  if ping -c 1 -W "$TIMEOUT" "$TARGET" >/dev/null 2>&1; then
    echo "$TARGET"
  fi
}

# ---- Iterate over hosts ----
while IFS= read -r TARGET; do
  scan_host "$TARGET" &

  # ---- Concurrency control ----
  while [ "$(jobs -r | wc -l)" -ge "$MAX_JOBS" ]; do
    sleep 0.05
  done

done < <(python3 - <<EOF
import ipaddress
net = ipaddress.ip_network("$CIDR", strict=False)
for host in net.hosts():
    print(host)
EOF
)

wait

# Count responsive hosts from stdout pipe-safe way
COUNT=$(jobs | wc -l)

echo >&2
echo "Scan complete." >&2
