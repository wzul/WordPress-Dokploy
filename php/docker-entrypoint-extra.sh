#!/bin/bash
set -e

echo "Starting LiteSpeed + WordPress Initialization..."

# Load all entrypoint scripts from the entrypoint.d directory
# They are executed in alphabetical order
for f in /usr/local/bin/entrypoint.d/*.sh; do
    if [ -x "$f" ]; then
        echo "Running $f..."
        source "$f"
    else
        echo "Warning: $f is not executable or not a file"
    fi
done

# Handover to the official LiteSpeed entrypoint
exec /entrypoint.sh "$@"
