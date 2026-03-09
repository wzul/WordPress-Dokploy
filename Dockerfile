FROM wordpress:fpm

# Install dependencies and msmtp
RUN apt-get update && \
    apt-get install -y msmtp msmtp-mta curl && \
    rm -rf /var/lib/apt/lists/*

# Download Adminer to a secure internal location (Version 5.4.2)
RUN mkdir -p /usr/local/src/adminer && \
    curl -L https://www.adminer.org/static/download/5.4.2/adminer-5.4.2.php -o /usr/local/src/adminer/adminer.php

# Custom entrypoint for dynamic configuration injection
COPY php/docker-entrypoint-extra.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint-extra.sh

ENTRYPOINT ["docker-entrypoint-extra.sh"]
CMD ["php-fpm"]
