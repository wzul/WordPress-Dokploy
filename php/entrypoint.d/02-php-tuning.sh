#!/bin/bash
# 02-php-tuning.sh: Dynamic PHP and Opcache configuration

PHP_MODS_DIR="/usr/local/lsws/lsphp84/etc/php/8.4/mods-available"

# Ensure Opcache File Cache directory exists and is writable
mkdir -p /tmp/opcache_file_cache
chown -R nobody:nogroup /tmp/opcache_file_cache

# Generate PHP limits configuration from ENV variables
echo "Generating dynamic PHP and Opcache configurations..."
cat <<EOF > "$PHP_MODS_DIR/99-uploads-dynamic.ini"
upload_max_filesize = ${WORDPRESS_UPLOAD_LIMIT:-64M}
post_max_size = ${WORDPRESS_UPLOAD_LIMIT:-64M}
memory_limit = ${WORDPRESS_MEMORY_LIMIT:-256M}
max_execution_time = ${WORDPRESS_MAX_EXECUTION_TIME:-300}
max_input_vars = ${WORDPRESS_MAX_INPUT_VARS:-3000}
EOF

# Generate Opcache configuration from ENV variables
cat <<EOF > "$PHP_MODS_DIR/99-opcache.ini"
opcache.enable=${OPCACHE_ENABLE:-1}
opcache.memory_consumption=${OPCACHE_MEMORY_CONSUMPTION:-256}
opcache.interned_strings_buffer=${OPCACHE_INTERNED_STRINGS_BUFFER:-8}
opcache.max_accelerated_files=${OPCACHE_MAX_ACCELERATED_FILES:-15000}
opcache.revalidate_freq=${OPCACHE_REVALIDATE_FREQ:-300}
opcache.fast_shutdown=${OPCACHE_FAST_SHUTDOWN:-1}

; --- Stabilization: Commented out to prevent 503 Crashes ---
; opcache.jit=tracing
; opcache.jit_buffer_size=128M
; opcache.file_cache=/tmp/opcache_file_cache
EOF
