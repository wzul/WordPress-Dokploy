#!/bin/bash
set -e

# 1. Inject Memory Limit
sed -i "s/WORDPRESS_MEMORY_LIMIT_PLACEHOLDER/${WORDPRESS_MEMORY_LIMIT:-256M}/g" /usr/local/etc/php/conf.d/uploads.ini

# 2. Inject PHP-FPM Pool Settings
sed -i "s/FPM_PM_TYPE_PLACEHOLDER/${PHP_FPM_PM:-dynamic}/g" /usr/local/etc/php-fpm.d/zz-dokploy.conf
sed -i "s/FPM_MAX_CHILDREN_PLACEHOLDER/${PHP_FPM_MAX_CHILDREN:-5}/g" /usr/local/etc/php-fpm.d/zz-dokploy.conf
sed -i "s/FPM_START_SERVERS_PLACEHOLDER/${PHP_FPM_START_SERVERS:-1}/g" /usr/local/etc/php-fpm.d/zz-dokploy.conf
sed -i "s/FPM_MIN_SPARE_SERVERS_PLACEHOLDER/${PHP_FPM_MIN_SPARE_SERVERS:-1}/g" /usr/local/etc/php-fpm.d/zz-dokploy.conf
sed -i "s/FPM_MAX_SPARE_SERVERS_PLACEHOLDER/${PHP_FPM_MAX_SPARE_SERVERS:-2}/g" /usr/local/etc/php-fpm.d/zz-dokploy.conf
sed -i "s/FPM_IDLE_TIMEOUT_PLACEHOLDER/${PHP_FPM_IDLE_TIMEOUT:-10s}/g" /usr/local/etc/php-fpm.d/zz-dokploy.conf

# 3. Call the original WordPress entrypoint
exec docker-entrypoint.sh "$@"
