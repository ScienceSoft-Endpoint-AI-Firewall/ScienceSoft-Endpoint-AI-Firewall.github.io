#!/bin/bash
#
# Writes the enrolment file that the AI Firewall package reads when it is installed.
# Run it BEFORE the package, as root.
#
# NOT YET TESTED ON A PILOT MAC. Try it on one Mac before you deploy it widely.
#
# Usage:
#   sudo ./seed-enrollment.sh <fleet-url> <enrolment-key>
#
# In Jamf Pro, give the two values as script parameters 4 and 5.
#
# The file is readable by root only. It holds the key.

set -euo pipefail

FLEET_URL="${4:-${1:-}}"
ENROLL_KEY="${5:-${2:-}}"
DIR="/Library/Application Support/ai-firewall"
FILE="$DIR/enrollment.json"

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this script as root." >&2
  exit 1
fi

if [ -z "$FLEET_URL" ] || [ -z "$ENROLL_KEY" ]; then
  echo "Usage: seed-enrollment.sh <fleet-url> <enrolment-key>" >&2
  exit 1
fi

case "$FLEET_URL" in
  https://*) ;;
  *) echo "The server address must start with https://" >&2; exit 1 ;;
esac

# Plain text only: no spaces, quotes or backslashes, so the value cannot break the JSON.
case "$FLEET_URL$ENROLL_KEY" in
  *[[:space:]\"\\]*) echo "The address and the key must not contain spaces, quotes or backslashes." >&2; exit 1 ;;
esac

# The package ignores an address or key that it considers invalid, and the Mac is then not enrolled.
# Use the same rules here: printable ASCII only, limited length, and no ? # @ .. in the address.
case "$FLEET_URL" in
  *\?*|*\#*|*@*|*..*) echo "The server address must not contain ?, #, @ or .." >&2; exit 1 ;;
esac
if [ "${#FLEET_URL}" -gt 2048 ] || [ "${#ENROLL_KEY}" -gt 4096 ]; then
  echo "The address is limited to 2048 characters and the key to 4096." >&2; exit 1
fi
if printf '%s%s' "$FLEET_URL" "$ENROLL_KEY" | LC_ALL=C grep -q '[^ -~]'; then
  echo "The address and the key must use printable ASCII characters only." >&2; exit 1
fi

mkdir -p "$DIR"
chown root:wheel "$DIR"
chmod 0755 "$DIR"

# Write to a temporary file, then move it into place, so a half-written file is never read.
umask 077
TMP="$(mktemp "$DIR/.enrollment.XXXXXX")"
printf '{"fleetUrl":"%s","token":"%s"}\n' "$FLEET_URL" "$ENROLL_KEY" > "$TMP"
chown root:wheel "$TMP"
chmod 0600 "$TMP"
mv -f "$TMP" "$FILE"

echo "Enrolment file written to $FILE"
