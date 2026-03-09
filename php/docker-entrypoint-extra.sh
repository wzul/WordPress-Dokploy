#!/bin/bash
set -e

echo "Starting LiteSpeed + WordPress Initialization..."

# 1. Download WordPress core if it doesn't exist
if [ ! -d "/var/www/html/wp-includes" ]; then
    echo "WordPress core not found. Downloading..."
    curl -o /tmp/wordpress.tar.gz -fSL "https://wordpress.org/latest.tar.gz"
    tar -xzf /tmp/wordpress.tar.gz -C /tmp/
    cp -rp /tmp/wordpress/* /var/www/html/
    chown -R nobody:nogroup /var/www/html
    rm -rf /tmp/wordpress /tmp/wordpress.tar.gz
fi

# 4. Install LiteSpeed Cache as a Must-Use plugin
WP_CONTENT="/var/www/html/wp-content"
MU_PLUGINS="$WP_CONTENT/mu-plugins"
LSC_DIR="$WP_CONTENT/plugins/litespeed-cache"

if [ ! -d "$LSC_DIR" ]; then
    echo "LiteSpeed Cache plugin not found. Installing..."
    mkdir -p "$WP_CONTENT/plugins"
    curl -o /tmp/lscache.zip -fSL "https://downloads.wordpress.org/plugin/litespeed-cache.latest-stable.zip"
    unzip -q /tmp/lscache.zip -d "$WP_CONTENT/plugins/"
    rm /tmp/lscache.zip
fi

if [ ! -d "$MU_PLUGINS" ]; then
    mkdir -p "$MU_PLUGINS"
fi

# Create the MU loader for LiteSpeed Cache
echo "Creating LiteSpeed Cache MU loader..."
cat <<EOF > "$MU_PLUGINS/lscache-mu.php"
<?php
/*
Plugin Name: LiteSpeed Cache (MU)
Description: LiteSpeed Cache forced as a Must-Use plugin.
Version: 1.0
Author: Dokploy Integration
*/

if (defined('WP_PLUGIN_DIR') && file_exists(WP_PLUGIN_DIR . '/litespeed-cache/litespeed-cache.php')) {
    require_once WP_PLUGIN_DIR . '/litespeed-cache/litespeed-cache.php';
}
EOF

# 2. Inject environment variables for LiteSpeed PHP settings into LSAPI
PHP_MODS_DIR="/usr/local/lsws/lsphp84/etc/php/8.4/mods-available"

# Ensure Opcache File Cache directory exists and is writable
mkdir -p /tmp/opcache_file_cache
chown -R nobody:nogroup /tmp/opcache_file_cache

# Apply PHP configurations from safe mounted directory
[ -f "/tmp/php/uploads.ini" ] && cp -p /tmp/php/uploads.ini "$PHP_MODS_DIR/99-uploads-dynamic.ini" 2>/dev/null || true
[ -f "/tmp/php/opcache.ini" ] && cp -p /tmp/php/opcache.ini "$PHP_MODS_DIR/99-opcache.ini" 2>/dev/null || true
[ -f "/tmp/php/mail.ini" ] && cp -p /tmp/php/mail.ini "$PHP_MODS_DIR/99-mail.ini" 2>/dev/null || true
[ -f "/tmp/php/msmtprc" ] && cp -p /tmp/php/msmtprc /etc/msmtprc 2>/dev/null || true

# 3. Handle OpenLiteSpeed configuration
if [ -f "/tmp/ols/vhosts/localhost/vhconf.conf" ]; then
    mkdir -p /usr/local/lsws/conf/vhosts/localhost/
    cp /tmp/ols/vhosts/localhost/vhconf.conf /usr/local/lsws/conf/vhosts/localhost/vhconf.conf
    
    echo "--- Final OpenLiteSpeed VHost Config ---"
    cat /usr/local/lsws/conf/vhosts/localhost/vhconf.conf
    echo "----------------------------------------"
fi

if [ -f "/tmp/ols/templates/docker.conf" ]; then
    mkdir -p /usr/local/lsws/conf/templates/
    cp /tmp/ols/templates/docker.conf /usr/local/lsws/conf/templates/docker.conf
fi

# Ensure everything is owned by nobody:nogroup
chown -R nobody:nogroup /var/www/html

echo "Initialization complete. Starting OpenLiteSpeed..."
exec /entrypoint.sh "$@"
