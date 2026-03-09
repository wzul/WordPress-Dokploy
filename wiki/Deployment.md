# Deployment Guide

This setup is designed specifically for **Dokploy** using the "Compose" service type.

## 1. Prerequisites
- A Dokploy instance installed.
- Your project files pushed to a Git repository.

## 2. Deployment Steps

### In your Git Provider:
1. Ensure your `env` is NOT committed (use `env.example` as a template).

### In Dokploy:
1. Create a new **Project**.
2. Click **Add Service** -> **Compose**.
3. Point to your Git repository URL.
4. **Environment Configuration (CRITICAL)**:
   > [!IMPORTANT]
   > Dokploy current cannot successfully inject host-level environment variables for the "Compose" service type. To manage your secrets:
   - Go to the **Files** tab of your service.
   - Create a new file manually named exactly **`env`** (without the dot).
   - Paste your configuration variables (e.g., `WORDPRESS_DB_PASSWORD=...`) into this file.
   - The `docker-compose.yml` is configured to read from this file natively.
5. **Domain Mapping**:
   - Go to the **Domains** tab.
   - **Main Site**: Add your domain (e.g., `mysite.com`) and point it to service **`wordpress`** on port **80**.
   - **OLS Admin (Optional)**: Add a subdomain (e.g., `ols.mysite.com`) and point it to service **`wordpress`** on port **7080**.
6. **Deploy**: Click the **Deploy** button.

## 🔑 Environment Variables

| Variable | Description | Default |
| :--- | :--- | :--- |
| `WORDPRESS_DB_HOST` | Hostname of your database | `wp_db` |
| `WORDPRESS_DB_NAME` | Name of your database | `wordpress` |
| `WORDPRESS_DB_USER` | Database user | `wordpress` |
| `WORDPRESS_DB_PASSWORD` | Database password | (Required) |
| `WORDPRESS_MEMORY_LIMIT`| PHP Memory Limit | `256M` |
| `OLS_PASSWORD` | Admin password for OpenLiteSpeed | `admin123` |
| `SMTP_SERVER` | SMTP Relay Host (e.g. Amazon SES) | (Required) |
| `SMTP_USERNAME` | SMTP Auth Username | (Required) |
| `SMTP_PASSWORD` | SMTP Auth Password | (Required) |
| `SERVER_HOSTNAME` | Your site domain (for Postfix EHLO) | `localhost` |
| `SES_TENANT_TAG` | AWS SES Tenant ID for tagging | `default` |

## 📁 Managing Volumes
The system uses named volumes to ensure your data persists across redeployments:
- `wp_app`: Persistent WordPress files (`/var/www/html`).
