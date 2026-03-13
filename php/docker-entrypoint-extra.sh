#!/bin/bash
set -e

echo "Starting LiteSpeed + WordPress Initialization..."

# Start background log streaming to container output
echo "Starting background log streaming..."
touch /usr/local/lsws/logs/error.log /usr/local/lsws/logs/stderr.log /usr/local/lsws/logs/access.log /usr/local/lsws/logs/localhost.access.log
chown nobody:nogroup /usr/local/lsws/logs/*.log
tail -F /usr/local/lsws/logs/error.log >&2 &
tail -F /usr/local/lsws/logs/stderr.log >&2 &
tail -F /usr/local/lsws/logs/access.log >&1 &
tail -F /usr/local/lsws/logs/localhost.access.log >&1 &
/usr/local/bin/htaccess-watcher.sh &

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
