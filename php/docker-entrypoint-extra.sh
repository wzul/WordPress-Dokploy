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
cat <<'EOF' > "$MU_PLUGINS/lscache-mu.php"
<?php
/*
Plugin Name: LiteSpeed Cache (MU)
Description: LiteSpeed Cache forced as a Must-Use plugin and auto-configured for Valkey.
Version: 1.1
Author: Dokploy Integration
*/

/**
 * Handle Cloudflare Real IP
 * This ensures WordPress sees the actual visitor IP in $_SERVER['REMOTE_ADDR']
 */
if (isset($_SERVER['HTTP_CF_CONNECTING_IP'])) {
    $_SERVER['REMOTE_ADDR'] = $_SERVER['HTTP_CF_CONNECTING_IP'];
}

/**
 * Auto-configure LiteSpeed Cache for Valkey (Redis)
 * These constants override any settings in the database.
 */
if ( ! defined( 'LITESPEED_CONF__OBJECT' ) ) {
    define( 'LITESPEED_CONF__OBJECT', true );
}
if ( ! defined( 'LITESPEED_CONF__OBJECT__KIND' ) ) {
    define( 'LITESPEED_CONF__OBJECT__KIND', 1 ); // 1 = Redis
}
if ( ! defined( 'LITESPEED_CONF__OBJECT__HOST' ) ) {
    define( 'LITESPEED_CONF__OBJECT__HOST', 'valkey' );
}
if ( ! defined( 'LITESPEED_CONF__OBJECT__PORT' ) ) {
    define( 'LITESPEED_CONF__OBJECT__PORT', 6379 );
}

if (defined('WP_PLUGIN_DIR') && file_exists(WP_PLUGIN_DIR . '/litespeed-cache/litespeed-cache.php')) {
    require_once WP_PLUGIN_DIR . '/litespeed-cache/litespeed-cache.php';
}
EOF

# 2. Inject environment variables for LiteSpeed PHP settings into LSAPI
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

# Generate Mail configuration for native PHP mail()
echo "Generating mail configuration for msmtp..."
cat <<EOF > "$PHP_MODS_DIR/99-mail.ini"
; Configure PHP to use msmtp for the native mail() function
sendmail_path = "/usr/bin/msmtp -t"
EOF

# Generate msmtprc configuration
cat <<EOF > /etc/msmtprc
# msmtp configuration for routing native PHP mail() through the relay sidecar
defaults
auth           off
tls            off
logfile        /tmp/msmtp.log
account        default
host           mail-relay
port           25
from           wordpress@localhost
EOF

# 3. Dynamic OpenLiteSpeed configuration
mkdir -p /usr/local/lsws/conf/templates/
mkdir -p /usr/local/lsws/conf/vhosts/localhost/

echo "Generating OpenLiteSpeed VHost configuration..."
cat <<'EOF' > /usr/local/lsws/conf/vhosts/localhost/vhconf.conf
docRoot                   /var/www/html
index  {
  useServer               0
  indexFiles              index.php, index.html
}

# 1. Real IP Detection (Trust Dokploy/Proxy Headers)
accessControl  {
  allow                   *
}

# 2. Per-Client Throttling (High-Performance Fail2Ban)
# Blocks IPs that spam requests (Brute force protection)
perClientConnLimit  {
  staticReqLimit          100
  dynamicReqLimit         5
  outBandwidth            0
  inBandwidth             0
  softLimit               1000
  hardLimit               1500
  gracePeriod             15
  banPeriod               300
}

scripthttpConfig  {
  libPath                 modules/lsapi.so
  maxConn                 100
  env                     LSAPI_MAX_REQS=500
  env                     LSAPI_MAX_IDLE=60
}

rewrite  {
  enable                  1
  autoLoadHtaccess        1
  rules                   <<<END_rules
# WordPress Basic Rewrites
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
  END_rules
}
EOF

echo "Generating OpenLiteSpeed Template configuration..."
cat <<'EOF' > /usr/local/lsws/conf/templates/docker.conf
allowSymbolLink           1
enableScript              1
restrained                0
setUIDMode                2
vhRoot                    /var/www/html/
configFile                $SERVER_ROOT/conf/vhosts/$VH_NAME/vhconf.conf

virtualHostConfig  {
  docRoot                 /var/www/html/
  enableGzip              1

  errorlog  {
    useServer             1
  }

  accesslog $SERVER_ROOT/logs/$VH_NAME.access.log {
    useServer             0
    rollingSize           10M
    keepDays              7
    compressArchive       1
  }

  index  {
    useServer             0
    indexFiles            index.html, index.php
    autoIndex             0
    autoIndexURI          /_autoindex/default.php
  }

  expires  {
    enableExpires         1
  }

  accessControl  {
    allow                 *
  }

  context / {
    location              $DOC_ROOT/
    allowBrowse           1

    rewrite  {
RewriteFile .htaccess
    }
  }

  rewrite  {
    enable                1
    autoLoadHtaccess      1    
    logLevel              0
  }

  vhssl  {
    keyFile               /root/.acme.sh/certs/$VH_NAME_ecc/$VH_NAME.key
    certFile              /root/.acme.sh/certs/$VH_NAME_ecc/fullchain.cer
    certChain             1
  }
}
EOF

# 5. Configure WordPress (wp-config.php)
WP_CONFIG="/var/www/html/wp-config.php"

# Generate wp-config.php from sample if it does not exist
if [ ! -f "$WP_CONFIG" ] && [ -f "/var/www/html/wp-config-sample.php" ]; then
    echo "wp-config.php not found. Creating from wp-config-sample.php..."
    cp /var/www/html/wp-config-sample.php "$WP_CONFIG"
    
    # Fetch unique security salts from WordPress.org API
    echo "Fetching fresh security salts..."
    SALTS=$(curl -s "https://api.wordpress.org/secret-key/1.1/salt/")
    if [ -n "$SALTS" ]; then
        # Remove the dummy salts and append the real ones
        awk -v salts="$SALTS" '/AUTH_KEY/{if (!done) {print salts; done=1}; next} /SECURE_AUTH_KEY|LOGGED_IN_KEY|NONCE_KEY|AUTH_SALT|SECURE_AUTH_SALT|LOGGED_IN_SALT|NONCE_SALT/{next} {print}' "$WP_CONFIG" > "${WP_CONFIG}.tmp" && mv "${WP_CONFIG}.tmp" "$WP_CONFIG"
    fi
fi

if [ -f "$WP_CONFIG" ]; then
    if [ "$DISABLE_WP_CRON" = "true" ]; then
        if ! grep -q "DISABLE_WP_CRON" "$WP_CONFIG"; then
            echo "Disabling internal WordPress cron in wp-config.php..."
            # Insert before the "stop editing" line
            sed -i "/\* That's all, stop editing!/i define('DISABLE_WP_CRON', true);" "$WP_CONFIG"
        fi
    fi
fi

# 6. Synchronize Database credentials (Auto-update wp-config.php)
if [ -f "$WP_CONFIG" ]; then
    echo "Synchronizing database credentials in wp-config.php..."
    [ -n "$WORDPRESS_DB_HOST" ] && sed -i "s/define( 'DB_HOST', .*/define( 'DB_HOST', '$WORDPRESS_DB_HOST' );/" "$WP_CONFIG"
    [ -n "$WORDPRESS_DB_NAME" ] && sed -i "s/define( 'DB_NAME', .*/define( 'DB_NAME', '$WORDPRESS_DB_NAME' );/" "$WP_CONFIG"
    [ -n "$WORDPRESS_DB_USER" ] && sed -i "s/define( 'DB_USER', .*/define( 'DB_USER', '$WORDPRESS_DB_USER' );/" "$WP_CONFIG"
    [ -n "$WORDPRESS_DB_PASSWORD" ] && sed -i "s/define( 'DB_PASSWORD', .*/define( 'DB_PASSWORD', '$WORDPRESS_DB_PASSWORD' );/" "$WP_CONFIG"
fi

# Ensure everything is owned by nobody:nogroup
chown -R nobody:nogroup /var/www/html

echo "Initialization complete. Starting OpenLiteSpeed..."
exec /entrypoint.sh "$@"
