#!/bin/bash
# 01-wordpress-lifecycle.sh: WordPress installation and plugin setup

# 0. Check if WordPress installation should be skipped
INSTALL_WORDPRESS=${INSTALL_WORDPRESS:-true}

# 1. Download WordPress core if it doesn't exist
if [ "$INSTALL_WORDPRESS" = "true" ]; then
    if [ ! -d "/var/www/html/wp-includes" ]; then
        echo "WordPress core not found. Downloading..."
        curl -o /tmp/wordpress.tar.gz -fSL "https://wordpress.org/latest.tar.gz"
        tar -xzf /tmp/wordpress.tar.gz -C /tmp/
        cp -rp /tmp/wordpress/* /var/www/html/
        chown -R nobody:nogroup /var/www/html
        rm -rf /tmp/wordpress /tmp/wordpress.tar.gz
    fi
fi

# 2. Install LiteSpeed Cache as a Must-Use plugin
if [ "$INSTALL_WORDPRESS" = "true" ]; then
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

    # Copy the pre-built MU loader for LiteSpeed Cache
    echo "Deploying LiteSpeed Cache MU loader..."
    cp /usr/local/bin/lscache-mu.php "$MU_PLUGINS/lscache-mu.php"

    chown -R nobody:nogroup "$WP_CONTENT"
fi
