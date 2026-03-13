#!/bin/bash
# 02-php-tuning.sh: Dynamic PHP and Opcache configuration

PHP_MODS_DIR="/usr/local/lsws/lsphp84/etc/php/8.4/mods-available"

# Ensure Opcache File Cache directory exists and is writable
mkdir -p /tmp/opcache_file_cache
chown -R nobody:nogroup /tmp/opcache_file_cache

# Generate PHP limits configuration from ENV variables
echo "Generating dynamic PHP and Opcache configurations..."
cat <<EOF > "$PHP_MODS_DIR/99-uploads-dynamic.ini"
upload_max_filesize = ${WORDPRESS_UPLOAD_LIMIT}
post_max_size = ${WORDPRESS_UPLOAD_LIMIT}
memory_limit = ${WORDPRESS_MEMORY_LIMIT}
max_execution_time = ${WORDPRESS_MAX_EXECUTION_TIME}
max_input_vars = ${WORDPRESS_MAX_INPUT_VARS}
EOF

# Generate Opcache configuration from ENV variables
cat <<EOF > "$PHP_MODS_DIR/99-opcache.ini"
opcache.enable=${OPCACHE_ENABLE}
opcache.memory_consumption=${OPCACHE_MEMORY_CONSUMPTION}
opcache.interned_strings_buffer=${OPCACHE_INTERNED_STRINGS_BUFFER}
opcache.max_accelerated_files=${OPCACHE_MAX_ACCELERATED_FILES}
opcache.revalidate_freq=${OPCACHE_REVALIDATE_FREQ}
opcache.fast_shutdown=${OPCACHE_FAST_SHUTDOWN}

; --- Stabilization: Commented out to prevent 503 Crashes ---
; opcache.jit=tracing
; opcache.jit_buffer_size=128M
; opcache.file_cache=/tmp/opcache_file_cache
EOF
