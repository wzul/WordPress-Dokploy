FROM litespeedtech/openlitespeed:1.8.5-lsphp84

# Install dependencies and msmtp
RUN apt-get update && \
    apt-get install -y msmtp msmtp-mta curl unzip wget less && \
    rm -rf /var/lib/apt/lists/*

# Install WP-CLI and create a wrapper to run it as the "nobody" user automatically
# This prevents permission issues when users run 'wp' commands via docker exec
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp-cli.phar && \
    echo '#!/bin/bash\nsu -s /bin/bash nobody -c "php /usr/local/bin/wp-cli.phar $*"' > /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

# Default PHP/WordPress Performance
ENV WORDPRESS_MEMORY_LIMIT=256M
ENV DISABLE_WP_CRON=true

# Default Admin Setup for OpenLiteSpeed
ENV OLS_PASSWORD=admin123

# Custom entrypoint for dynamic configuration injection
COPY php/docker-entrypoint-extra.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint-extra.sh

ENTRYPOINT ["docker-entrypoint-extra.sh"]
