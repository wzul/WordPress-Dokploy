FROM litespeedtech/openlitespeed:1.8.5-lsphp84

# Install dependencies and msmtp
RUN apt-get update && \
    apt-get install -y msmtp msmtp-mta curl unzip wget less inotify-tools && \
    rm -rf /var/lib/apt/lists/*

# Install WP-CLI and create a wrapper to run it as the "nobody" user automatically
# This prevents permission issues when users run 'wp' commands via docker exec
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp-cli.phar && \
    echo '#!/bin/bash\nphp /usr/local/bin/wp-cli.phar "$@" --allow-root' > /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

# Default PHP Performance & Limits
ENV WORDPRESS_MEMORY_LIMIT=256M
ENV WORDPRESS_UPLOAD_LIMIT=64M
ENV WORDPRESS_MAX_EXECUTION_TIME=300
ENV WORDPRESS_MAX_INPUT_VARS=3000

# Default Opcache Settings
ENV OPCACHE_ENABLE=1
ENV OPCACHE_MEMORY_CONSUMPTION=256
ENV OPCACHE_INTERNED_STRINGS_BUFFER=8
ENV OPCACHE_MAX_ACCELERATED_FILES=15000
ENV OPCACHE_REVALIDATE_FREQ=300
ENV OPCACHE_FAST_SHUTDOWN=1

ENV DISABLE_WP_CRON=true

# Default Admin Setup for OpenLiteSpeed
# (Removed OLS_PASSWORD default for security - set via ENV at runtime)

# Custom entrypoint for dynamic configuration injection
COPY php/docker-entrypoint-extra.sh php/htaccess-watcher.sh php/lscache-mu.php /usr/local/bin/
COPY php/entrypoint.d/ /usr/local/bin/entrypoint.d/
RUN chmod +x /usr/local/bin/docker-entrypoint-extra.sh /usr/local/bin/htaccess-watcher.sh /usr/local/bin/entrypoint.d/*.sh

ENTRYPOINT ["docker-entrypoint-extra.sh"]
