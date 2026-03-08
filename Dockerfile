FROM wordpress:fpm

# Install msmtp to handle native PHP mail() function
RUN apt-get update && \
    apt-get install -y msmtp msmtp-mta && \
    rm -rf /var/lib/apt/lists/*
