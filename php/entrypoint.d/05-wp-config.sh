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
            echo "Ensuring WordPress Debugging is enabled..."
            
            # 1.3.1 Handle WP_DEBUG
            if ! grep -q "WP_DEBUG" "$WP_CONFIG"; then
                sed -i "/\* That's all, stop editing!/i define('WP_DEBUG', true);" "$WP_CONFIG"
            else
                sed -i "s/define(\s*['\"]WP_DEBUG['\"]\s*,.*/define('WP_DEBUG', true);/" "$WP_CONFIG"
            fi

            # 1.3.2 Handle WP_DEBUG_LOG
            # Set to false to use system error_log (captured by OLS -> Docker)
            if ! grep -q "WP_DEBUG_LOG" "$WP_CONFIG"; then
                 sed -i "/define(\s*['\"]WP_DEBUG['\"]/a define('WP_DEBUG_LOG', false);" "$WP_CONFIG"
            else
                sed -i "s/define(\s*['\"]WP_DEBUG_LOG['\"]\s*,.*/define('WP_DEBUG_LOG', false);/" "$WP_CONFIG"
            fi

            # 1.3.3 Handle WP_DEBUG_DISPLAY
            if ! grep -q "WP_DEBUG_DISPLAY" "$WP_CONFIG"; then
                sed -i "/define(\s*['\"]WP_DEBUG_LOG['\"]/a define('WP_DEBUG_DISPLAY', false);" "$WP_CONFIG"
            else
                sed -i "s/define(\s*['\"]WP_DEBUG_DISPLAY['\"]\s*,.*/define('WP_DEBUG_DISPLAY', false);/" "$WP_CONFIG"
            fi
            
            # Remove any existing debug.log symlink to avoid confusion
            rm -f /var/www/html/wp-content/debug.log
        else
            echo "Ensuring WordPress Debugging is disabled..."
            sed -i "s/define(\s*['\"]WP_DEBUG['\"]\s*,.*/define('WP_DEBUG', false);/" "$WP_CONFIG" 2>/dev/null || true
            sed -i "s/define(\s*['\"]WP_DEBUG_LOG['\"]\s*,.*/define('WP_DEBUG_LOG', false);/" "$WP_CONFIG" 2>/dev/null || true
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
