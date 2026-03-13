FROM mariadb:11.8

# Copy custom configuration
COPY my.cnf /etc/mysql/conf.d/my.cnf

# Ensure correct permissions
RUN chmod 644 /etc/mysql/conf.d/my.cnf
