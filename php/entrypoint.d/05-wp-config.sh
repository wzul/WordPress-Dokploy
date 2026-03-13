#!/bin/bash
# 05-wp-config.sh: Automated wp-config.php hardening

INSTALL_WORDPRESS=${INSTALL_WORDPRESS:-true}

# 1. Configure WordPress (wp-config.php)
if [ "$INSTALL_WORDPRESS" = "true" ]; then
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
        if ! grep -q "HTTP_CF_CONNECTING_IP" "$WP_CONFIG"; then
            echo "Injecting Cloudflare Real IP handling into wp-config.php..."
            sed -i "/<?php/a \\
/**\\
 * Handle Cloudflare Real IP\\
 */\\
if (isset(\$_SERVER['HTTP_CF_CONNECTING_IP'])) {\\
    \$_SERVER['REMOTE_ADDR'] = \$_SERVER['HTTP_CF_CONNECTING_IP'];\\
}" "$WP_CONFIG"
        fi

        # 1.2 Handle WordPress Cron
        if [ "$DISABLE_WP_CRON" = "true" ]; then
            if ! grep -q "DISABLE_WP_CRON" "$WP_CONFIG"; then
                echo "Disabling internal WordPress cron in wp-config.php..."
                sed -i "/\* That's all, stop editing!/i define('DISABLE_WP_CRON', true);" "$WP_CONFIG"
            else
                echo "Ensuring internal WP Cron is disabled..."
                sed -i "s/define( 'DISABLE_WP_CRON', .*/define( 'DISABLE_WP_CRON', true );/" "$WP_CONFIG"
            fi
        else
            if grep -q "DISABLE_WP_CRON" "$WP_CONFIG"; then
                echo "Enabling internal WordPress cron..."
                sed -i "s/define( 'DISABLE_WP_CRON', .*/define( 'DISABLE_WP_CRON', false );/" "$WP_CONFIG"
            fi
        fi

        # 1.3 Handle WordPress Debugging
        if [ "$WORDPRESS_DEBUG" = "true" ]; then
            if ! grep -q "WP_DEBUG" "$WP_CONFIG"; then
                echo "Enabling WordPress Debugging mode..."
                sed -i "/\* That's all, stop editing!/i \
define('WP_DEBUG', true); \\
define('WP_DEBUG_LOG', true); \\
define('WP_DEBUG_DISPLAY', false);" "$WP_CONFIG"
            else
                echo "Ensuring WP_DEBUG is set to true..."
                sed -i "s/define( 'WP_DEBUG', .*/define( 'WP_DEBUG', true );/" "$WP_CONFIG"
                sed -i "s/define( 'WP_DEBUG_LOG', .*/define( 'WP_DEBUG_LOG', true );/" "$WP_CONFIG"
            fi
            
            # Ensure debug.log symlink exists for Dozzle
            mkdir -p /var/www/html/wp-content
            [ ! -L "/var/www/html/wp-content/debug.log" ] && ln -sf /proc/self/fd/2 /var/www/html/wp-content/debug.log
        else
            if grep -q "WP_DEBUG" "$WP_CONFIG"; then
                echo "Disabling WordPress Debugging mode..."
                sed -i "s/define( 'WP_DEBUG', .*/define( 'WP_DEBUG', false );/" "$WP_CONFIG"
                sed -i "s/define( 'WP_DEBUG_LOG', .*/define( 'WP_DEBUG_LOG', false );/" "$WP_CONFIG"
            fi
        fi
    fi

    # 2. Synchronize Database credentials (Auto-update wp-config.php)
    if [ -f "$WP_CONFIG" ]; then
        echo "Synchronizing database credentials in wp-config.php..."
        [ -n "$WORDPRESS_DB_HOST" ] && sed -i "s/define( 'DB_HOST', .*/define( 'DB_HOST', '$WORDPRESS_DB_HOST' );/" "$WP_CONFIG"
        [ -n "$WORDPRESS_DB_NAME" ] && sed -i "s/define( 'DB_NAME', .*/define( 'DB_NAME', '$WORDPRESS_DB_NAME' );/" "$WP_CONFIG"
        [ -n "$WORDPRESS_DB_USER" ] && sed -i "s/define( 'DB_USER', .*/define( 'DB_USER', '$WORDPRESS_DB_USER' );/" "$WP_CONFIG"
        [ -n "$WORDPRESS_DB_PASSWORD" ] && sed -i "s/define( 'DB_PASSWORD', .*/define( 'DB_PASSWORD', '$WORDPRESS_DB_PASSWORD' );/" "$WP_CONFIG"
    fi

    # Set ownership for created/modified WordPress files
    chown nobody:nogroup "$WP_CONFIG" 2>/dev/null || true
fi
