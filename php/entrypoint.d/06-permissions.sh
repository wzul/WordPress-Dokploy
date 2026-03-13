#!/bin/bash
# 06-permissions.sh: Final permissions and handover

# Ensure everything is owned by nobody:nogroup
chown -R nobody:nogroup /var/www/html

echo "Initialization complete. Starting OpenLiteSpeed..."
