#!/bin/sh
set -e

# Capture runtime UID/GID from environment variables, defaulting to 1000
PUID=${USER_UID:-1000}
PGID=${USER_GID:-1000}

# Adjust the node user's UID/GID if they differ from the runtime request
if [ "$(id -u node)" -ne "$PUID" ]; then
    echo "Updating node UID to $PUID"
    usermod -o -u "$PUID" node
fi

if [ "$(id -g node)" -ne "$PGID" ]; then
    echo "Updating node GID to $PGID"
    groupmod -o -g "$PGID" node
    usermod -g "$PGID" node
fi

# Create TMPDIR inside the persistent volume if it doesn't exist
mkdir -p /paperclip/tmp

# --- Development Environment Setup ---
# Clone Vectora if it doesn't exist in the persistent volume
if [ ! -d "/paperclip/Vectora" ]; then
    echo "Cloning Vectora repository for development..."
    git clone https://github.com/Kaffyn/Vectora /paperclip/Vectora
fi

# Always ensure the data volume is owned by node.
chown -R node:node /paperclip

# Fix generic permissions for the volume
chmod -R 755 /paperclip

# STRICT REQUIREMENT: Postgres data directory MUST be 0700
find /paperclip -type d -name "db" -exec chmod 700 {} +

exec gosu node "$@"
