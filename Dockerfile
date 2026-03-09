FROM litespeedtech/openlitespeed:1.8.5-lsphp84

# Install dependencies and msmtp
RUN apt-get update && \
    apt-get install -y msmtp msmtp-mta curl unzip wget && \
    rm -rf /var/lib/apt/lists/*

# Custom entrypoint for dynamic configuration injection
COPY php/docker-entrypoint-extra.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint-extra.sh

ENTRYPOINT ["docker-entrypoint-extra.sh"]
