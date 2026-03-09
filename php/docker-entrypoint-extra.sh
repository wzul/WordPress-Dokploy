#!/bin/bash
set -e

# Parse templates and generate the active configuration files cleanly.
# This prevents Docker from overwriting the host repository files and safely handles the placeholders.

if [ -f "/tmp/php/uploads.ini" ]; then
    cp /tmp/php/uploads.ini /usr/local/etc/php/conf.d/uploads-dynamic.ini
    sed -i "s/WORDPRESS_MEMORY_LIMIT_PLACEHOLDER/${WORDPRESS_MEMORY_LIMIT:-256M}/g" /usr/local/etc/php/conf.d/uploads-dynamic.ini
fi

if [ -f "/tmp/php/fpm-pool.conf" ]; then
    cp /tmp/php/fpm-pool.conf /usr/local/etc/php-fpm.d/zz-dokploy-dynamic.conf
    sed -i "s/FPM_PM_TYPE_PLACEHOLDER/${PHP_FPM_PM:-dynamic}/g" /usr/local/etc/php-fpm.d/zz-dokploy-dynamic.conf
    sed -i "s/FPM_MAX_CHILDREN_PLACEHOLDER/${PHP_FPM_MAX_CHILDREN:-5}/g" /usr/local/etc/php-fpm.d/zz-dokploy-dynamic.conf
    sed -i "s/FPM_START_SERVERS_PLACEHOLDER/${PHP_FPM_START_SERVERS:-1}/g" /usr/local/etc/php-fpm.d/zz-dokploy-dynamic.conf
    sed -i "s/FPM_MIN_SPARE_SERVERS_PLACEHOLDER/${PHP_FPM_MIN_SPARE_SERVERS:-1}/g" /usr/local/etc/php-fpm.d/zz-dokploy-dynamic.conf
    sed -i "s/FPM_MAX_SPARE_SERVERS_PLACEHOLDER/${PHP_FPM_MAX_SPARE_SERVERS:-2}/g" /usr/local/etc/php-fpm.d/zz-dokploy-dynamic.conf
    sed -i "s/FPM_IDLE_TIMEOUT_PLACEHOLDER/${PHP_FPM_IDLE_TIMEOUT:-10s}/g" /usr/local/etc/php-fpm.d/zz-dokploy-dynamic.conf
    
    # Ensure clear_env is disabled so Docker environment variables are passed to PHP worker processes
    if ! grep -q "clear_env = no" /usr/local/etc/php-fpm.d/zz-dokploy-dynamic.conf; then
        echo "" >> /usr/local/etc/php-fpm.d/zz-dokploy-dynamic.conf
        echo "; Make sure environment variables are passed to PHP" >> /usr/local/etc/php-fpm.d/zz-dokploy-dynamic.conf
        echo "clear_env = no" >> /usr/local/etc/php-fpm.d/zz-dokploy-dynamic.conf
    fi
fi

# Copy other static configurations from the safe mounted directory
cp -p /tmp/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini 2>/dev/null || true
cp -p /tmp/php/mail.ini /usr/local/etc/php/conf.d/mail.ini 2>/dev/null || true
cp -p /tmp/php/msmtprc /etc/msmtprc 2>/dev/null || true
cp -p /tmp/php/adminer-auth.php /var/www/html/adminer-auth.php 2>/dev/null || true

# 3. Call the original WordPress entrypoint
exec docker-entrypoint.sh "$@"
