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

# 2. Inject environment variables for LiteSpeed PHP settings into LSAPI
PHP_MODS_DIR="/usr/local/lsws/lsphp84/etc/php/8.4/mods-available"

# Apply PHP configurations from safe mounted directory
if [ -f "/tmp/php/uploads.ini" ]; then
    cp /tmp/php/uploads.ini "$PHP_MODS_DIR/99-uploads-dynamic.ini"
    sed -i "s/WORDPRESS_MEMORY_LIMIT_PLACEHOLDER/${WORDPRESS_MEMORY_LIMIT:-256M}/g" "$PHP_MODS_DIR/99-uploads-dynamic.ini"
fi

[ -f "/tmp/php/opcache.ini" ] && cp -p /tmp/php/opcache.ini "$PHP_MODS_DIR/99-opcache.ini" 2>/dev/null || true
[ -f "/tmp/php/mail.ini" ] && cp -p /tmp/php/mail.ini "$PHP_MODS_DIR/99-mail.ini" 2>/dev/null || true
[ -f "/tmp/php/msmtprc" ] && cp -p /tmp/php/msmtprc /etc/msmtprc 2>/dev/null || true
[ -f "/tmp/php/adminer-auth.php" ] && cp -p /tmp/php/adminer-auth.php /var/www/html/adminer-auth.php 2>/dev/null || true

# 3. Handle OpenLiteSpeed configuration
FM_PATH=${FILE_MANAGER_PATH:-/file-manager-secret}
DB_PATH=${DB_MANAGER_PATH:-/wp-db-admin}
FM_PATH_SLASH=${FM_PATH%/}/
FM_PATH_NO_SLASH=${FM_PATH%/}

if [ -f "/tmp/ols/vhosts/localhost/vhconf.conf" ]; then
    mkdir -p /usr/local/lsws/conf/vhosts/localhost/
    cp /tmp/ols/vhosts/localhost/vhconf.conf /usr/local/lsws/conf/vhosts/localhost/vhconf.conf
    sed -i "s|FILE_MANAGER_PATH_PLACEHOLDER|$FM_PATH_SLASH|g" /usr/local/lsws/conf/vhosts/localhost/vhconf.conf
    sed -i "s|FILE_MANAGER_PATH_STRIPPED|$FM_PATH_NO_SLASH|g" /usr/local/lsws/conf/vhosts/localhost/vhconf.conf
    sed -i "s|DB_MANAGER_PATH_PLACEHOLDER|$DB_PATH|g" /usr/local/lsws/conf/vhosts/localhost/vhconf.conf
fi

if [ -f "/tmp/ols/templates/docker.conf" ]; then
    mkdir -p /usr/local/lsws/conf/templates/
    cp /tmp/ols/templates/docker.conf /usr/local/lsws/conf/templates/docker.conf
fi

echo "Initialization complete. Starting OpenLiteSpeed..."
exec /entrypoint.sh "$@"
