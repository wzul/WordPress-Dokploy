#!/bin/bash
# 04-ols-orchestration.sh: OpenLiteSpeed VHost and Template configuration

# 1. Dynamic OpenLiteSpeed configuration
mkdir -p /usr/local/lsws/conf/templates/
mkdir -p /usr/local/lsws/conf/vhosts/localhost/

echo "Generating OpenLiteSpeed VHost configuration..."
cat <<'EOF' > /usr/local/lsws/conf/vhosts/localhost/vhconf.conf
docRoot                   /var/www/html
index  {
  useServer               0
  indexFiles              index.php, index.html, index.htm
}

# 1. Real IP Detection (Trust Dokploy/Proxy Headers)
accessControl  {
  allow                   *
}

# 2. Per-Client Throttling (High-Performance Fail2Ban)
# Blocks IPs that spam requests (Brute force protection)
perClientConnLimit  {
  staticReqLimit          100
  dynamicReqLimit         5
  outBandwidth            0
  inBandwidth             0
  softLimit               1000
  hardLimit               1500
  gracePeriod             15
  banPeriod               300
}

scripthttpConfig  {
  libPath                 modules/lsapi.so
  maxConn                 100
  env                     LSAPI_MAX_REQS=500
  env                     LSAPI_MAX_IDLE=60
}
EOF

# 2. URL Rewriting (Front Controller pattern for WP/Laravel/etc)
cat <<EOF >> /usr/local/lsws/conf/vhosts/localhost/vhconf.conf
rewrite  {
  enable                  1
  autoLoadHtaccess        1
  rules                   <<<END_rules
# Basic Front Controller Rewrites
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
  END_rules
}
EOF

echo "Generating OpenLiteSpeed Template configuration..."
cat <<'EOF' > /usr/local/lsws/conf/templates/docker.conf
allowSymbolLink           1
enableScript              1
restrained                0
setUIDMode                2
vhRoot                    /var/www/html/
configFile                $SERVER_ROOT/conf/vhosts/$VH_NAME/vhconf.conf

virtualHostConfig  {
  docRoot                 /var/www/html/
  enableGzip              1

  errorlog  {
    useServer             1
  }

  accesslog $SERVER_ROOT/logs/$VH_NAME.access.log {
    useServer             0
    rollingSize           10M
    keepDays              7
    compressArchive       1
  }

  index  {
    useServer             0
    indexFiles            index.html, index.htm, index.php
    autoIndex             0
    autoIndexURI          /_autoindex/default.php
  }

  expires  {
    enableExpires         1
  }

  accessControl  {
    allow                 *
  }

  context / {
    location              $DOC_ROOT/
    allowBrowse           1

    rewrite  {
RewriteFile .htaccess
    }
  }

  rewrite  {
    enable                1
    autoLoadHtaccess      1    
    logLevel              0
  }

  vhssl  {
    keyFile               /root/.acme.sh/certs/$VH_NAME_ecc/$VH_NAME.key
    certFile              /root/.acme.sh/certs/$VH_NAME_ecc/fullchain.cer
    certChain             1
  }

  module lscache {
    lsapi_cache_enabled   1
  }
}

# 3. Global Compression Settings (Server Level placeholder if needed)
# OpenLiteSpeed enables compression by default, but we ensure it here at VHost level.
EOF

# Update vhconf.conf with compression blocks
cat <<EOF >> /usr/local/lsws/conf/vhosts/localhost/vhconf.conf

# Compression Settings
gzip  {
  enable                  ${GZIP_ENABLE:-1}
  compressibleTypes       default
}

brotli  {
  enable                  ${BROTLI_ENABLE:-1}
}
EOF

# Update docker.conf template with compression blocks
sed -i "/enableGzip/d" /usr/local/lsws/conf/templates/docker.conf
sed -i "/docRoot/a \  enableGzip              ${GZIP_ENABLE:-1}\n  enableBrotli            ${BROTLI_ENABLE:-1}" /usr/local/lsws/conf/templates/docker.conf
