# Deployment Guide

This setup is designed specifically for **Dokploy** using the "Compose" service type.

## 1. Prerequisites
- A Dokploy instance installed.
- Your project files pushed to a Git repository.

## 2. Deployment Steps

### In your Git Provider:
1. Ensure your `.env` is NOT committed (use `.env.example` as a template).

### In Dokploy:
1. Create a new **Project**.
2. Click **Add Service** -> **Compose**.
3. Point to your Git repository URL.
18: 4. **General Configuration**:
19:    - Set **Compose Path** to `docker-compose.yml`.
20:    - > [!IMPORTANT]
21:    - > **Enable "Isolated Deployment"**: It is highly recommended to toggle this **ON**. This ensures your stack runs in its own isolated Docker network, preventing IP conflicts and increasing security between different Dokploy projects.
22: 
5. **Environment Configuration**:
   - Go to the **Environment** tab of your service.
   - Add your configuration variables as simple Key/Value pairs (e.g., Key: `OLS_PASSWORD`, Value: `admin123`).
   - Dokploy automatically generates a `.env` file from these pairs, and our `docker-compose.yml` consumes it automatically!
6. **Domain Mapping**:
   - Go to the **Domains** tab.
   - **Main Site**: Add your domain (e.g., `mysite.com`) and point it to service **`wordpress`** on port **80**.
   - **OLS Admin (Optional)**: Add a subdomain (e.g., `ols.mysite.com`) and point it to service **`wordpress`** on port **7080**.
7. **Deploy**: Click the **Deploy** button.

## 💻 Local Testing
To test the stack on your local machine before deploying:
1. Copy `.env.example` to `.env` in this directory.
2. Run `docker-compose -f docker-compose.local.yml up -d`.
3. Open `http://localhost:8080` for the WordPress site.
4. Open `http://localhost:7080` for the OpenLiteSpeed Admin console. (Port 7080 uses HTTP by default in OLS).

## 🔑 Environment Variables

| Variable | Description | Default |
| :--- | :--- | :--- |
| `OLS_PASSWORD` | Admin password for OpenLiteSpeed | `admin123` |
| `INSTALL_WORDPRESS` | Set to `false` to skip auto-downloading WP | `true` |
| `COMPOSE_PROFILES` | Enable optional tools like `tools` (phpMyAdmin) | `(None)` |
| `SMTP_SERVER` | SMTP Relay Host (e.g. Amazon SES) | `(None)` |
| `SMTP_USERNAME` | SMTP Auth Username | `(None)` |
| `SMTP_PASSWORD` | SMTP Auth Password | `(None)` |
| `OVERWRITE_FROM`| Soft Email Overwrite Address | `(None)` |
| `SERVER_HOSTNAME` | Your site domain (for Postfix EHLO) | `example.com` |
| `SES_TENANT_TAG` | AWS SES Tenant ID for tagging | `default` |
| `VALKEY_HOST` | Object Cache Host | `valkey` |
| `VALKEY_PORT` | Object Cache Port | `6379` |
| `VALKEY_MAX_MEMORY` | Valkey Max Memory Limit | `64mb` |
| `LITESPEED_CACHE_OBJECT_CONF`| Forced LSCache Object Config | `true` |
| `LITESPEED_CACHE_OBJECT_ENABLE`| Forced Object Cache Enable | `true` |
| `WORDPRESS_DB_HOST` | Database host | `mariadb:3306` |
| `WORDPRESS_DB_NAME` | Database name | `wordpress` |
| `WORDPRESS_DB_USER` | Database username | `wordpress` |
| `WORDPRESS_DB_PASSWORD` | Database password | `(Required)` |
| `MYSQL_ROOT_PASSWORD`| MariaDB Root Password | `(Required)` |
| `MARIADB_AUTO_UPGRADE`| Auto-migrate DB system tables | `1` |
| `PHP_MAX_CONNS` | Max concurrent PHP processes | `35` |
| `WORDPRESS_MEMORY_LIMIT`| PHP Memory Limit | `256M` |
| `WORDPRESS_UPLOAD_LIMIT`| Max upload size | `64M` |
| `WORDPRESS_MAX_EXECUTION_TIME`| PHP script timeout | `300` |
| `WORDPRESS_MAX_INPUT_VARS`| Max post variables | `3000` |
| `OPCACHE_ENABLE`| Enable Opcache | `1` |
| `OPCACHE_MEMORY_CONSUMPTION`| Opcache RAM usage (MB) | `256` |
| `OPCACHE_MAX_ACCELERATED_FILES`| Max cached files | `15000` |
| `OPCACHE_REVALIDATE_FREQ`| Cache TTL in seconds | `300` |
| `OPCACHE_FAST_SHUTDOWN`| Enable fast shutdown | `1` |

## 📁 Managing Volumes
The system uses named volumes to ensure your data persists across redeployments:
- `wp_app`: Persistent WordPress files (`/var/www/html`).
