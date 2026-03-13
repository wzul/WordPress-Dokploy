#!/bin/bash
# 03-email-routing.sh: Native email routing via msmtp

PHP_MODS_DIR="/usr/local/lsws/lsphp84/etc/php/8.4/mods-available"

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
host           ${MAIL_RELAY_HOST:-mail-relay}
port           ${MAIL_RELAY_PORT:-25}
from           ${OVERWRITE_FROM:-wordpress@localhost}
EOF
