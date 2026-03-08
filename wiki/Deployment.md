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
4. Go to the **Environment** tab and add the variables listed below.
5. Click **Deploy**.

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
The system uses a named volume `wp_app` for the `/var/www/html` directory. This ensures your plugins, themes, and uploads persist across redeployments.
