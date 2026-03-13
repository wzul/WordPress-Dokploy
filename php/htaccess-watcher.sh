#!/bin/bash
# htaccess-watcher.sh: Watches for .htaccess changes and restarts OLS

HTACCESS_PATH="/var/www/html/.htaccess"

echo "Started .htaccess watcher for $HTACCESS_PATH"

# Ensure the file exists so inotifywait doesn't fail
touch "$HTACCESS_PATH"

while true; do
  # Wait for a 'modify' or 'create' event on the .htaccess file
  # Using -e modify,create,delete,move
  inotifywait -e modify,create,delete,move "$HTACCESS_PATH"
  
  echo "[$(date)] .htaccess changed. Triggering OpenLiteSpeed graceful restart..."
  
  # Trigger OLS graceful restart
  /usr/local/lsws/bin/lswsctrl restart
  
  # Small delay to prevent restart loops if multiple changes happen quickly
  sleep 2
done
