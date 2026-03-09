#!/bin/bash
set -e

# Instead of modifying the bind-mounted file directly (which modifies the host git repo),
# we cp the default files, run sed on them, and let PHP use the modified copy.
if [ -f "/usr/local/etc/php/conf.d/uploads.ini" ]; then
    cp /usr/local/etc/php/conf.d/uploads.ini /tmp/uploads.ini
    sed -i "s/WORDPRESS_MEMORY_LIMIT_PLACEHOLDER/${WORDPRESS_MEMORY_LIMIT:-256M}/g" /tmp/uploads.ini
    cat /tmp/uploads.ini > /usr/local/etc/php/conf.d/uploads.ini 2>/dev/null || true
fi

if [ -f "/usr/local/etc/php-fpm.d/zz-dokploy.conf" ]; then
    cp /usr/local/etc/php-fpm.d/zz-dokploy.conf /tmp/zz-dokploy.conf
    sed -i "s/FPM_PM_TYPE_PLACEHOLDER/${PHP_FPM_PM:-dynamic}/g" /tmp/zz-dokploy.conf
    sed -i "s/FPM_MAX_CHILDREN_PLACEHOLDER/${PHP_FPM_MAX_CHILDREN:-5}/g" /tmp/zz-dokploy.conf
    sed -i "s/FPM_START_SERVERS_PLACEHOLDER/${PHP_FPM_START_SERVERS:-1}/g" /tmp/zz-dokploy.conf
    sed -i "s/FPM_MIN_SPARE_SERVERS_PLACEHOLDER/${PHP_FPM_MIN_SPARE_SERVERS:-1}/g" /tmp/zz-dokploy.conf
    sed -i "s/FPM_MAX_SPARE_SERVERS_PLACEHOLDER/${PHP_FPM_MAX_SPARE_SERVERS:-2}/g" /tmp/zz-dokploy.conf
    sed -i "s/FPM_IDLE_TIMEOUT_PLACEHOLDER/${PHP_FPM_IDLE_TIMEOUT:-10s}/g" /tmp/zz-dokploy.conf
    
    # We can't overwrite the bind mount without modifying the git repo on the host.
    # So we copy the processed file to a NEW config file in the conf.d directory that PHP-FPM reads, 
    # and we just rely on PHP-FPM reading the latest one alphabetically.
    cp /tmp/zz-dokploy.conf /usr/local/etc/php-fpm.d/zzz-dokploy-dynamic.conf
fi

# 3. Call the original WordPress entrypoint
exec docker-entrypoint.sh "$@"
