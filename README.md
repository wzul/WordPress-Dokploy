# WordPress Deployment with Dokploy (OpenLiteSpeed)

This repository contains a WordPress setup optimized for deployment via [Dokploy](https://dokploy.com/). It includes pre-configured PHP settings, **OpenLiteSpeed** as the web server, and a built-in SMTP relay sidecar for high-performance email delivery.

> [!TIP]
> **Check out the [Project Wiki](wiki/Home.md) for detailed documentation on architecture, SMTP, and OpenLiteSpeed management.**

## Project Structure

- `Dockerfile`: Custom image that installs `msmtp` for global PHP `mail()` support.
- `docker-compose.yml`: Orchestrates WordPress, OpenLiteSpeed, and the Mail Relay.
- `php/`: Configuration for PHP, Opcache, FPM, and SMTP.
  - `mail.ini` & `msmtprc`: Configures native PHP `mail()` to use the relay.
- `ols/`: OpenLiteSpeed configuration.
  - `vhconf.conf`: Virtual Host config that proxies PHP requests to the WordPress sidecar.

## Deployment Instructions

1.  **Preparation**: Ensure your repository is pushed to a Git provider (GitHub, GitLab, etc.).
2.  **In Dokploy**:
    - Create a new **Compose** project.
    - Connect your Git repository.
    - Dokploy will automatically detect the `docker-compose.yml` file and use the `Dockerfile` to build your specialized WordPress image.
3.  **Environment Variables**:
    - Define the following in the Dokploy **"Environment"** tab for your project:
      - `WORDPRESS_DB_HOST`: Database hostname (defaults to `wp_db`).
      - `WORDPRESS_DB_NAME`: Database name (defaults to `wordpress`).
      - `WORDPRESS_DB_USER`: Database user (defaults to `wordpress`).
      - `WORDPRESS_DB_PASSWORD`: Your database password.
      - `WORDPRESS_MEMORY_LIMIT`: PHP memory limit (defaults to `256M`).
      - `OLS_PASSWORD`: Admin password for OpenLiteSpeed (defaults to `admin123`).
      - `SMTP_SERVER`: Your SMTP provider (e.g., `smtp.mailgun.org`).
      - `SMTP_PORT`: SMTP port (defaults to `587`).
      - `SMTP_USERNAME`, `SMTP_PASSWORD`: Your SMTP credentials.
      - `SERVER_HOSTNAME`: Your site domain (e.g., `example.com`).
      - `SES_TENANT_TAG`: AWS SES tenant tag for tracking (e.g., `my-tenant`).
4.  **Deploy**: Click **Deploy** to start all services.

---

## SMTP & Native mail() Support

This project supports background email queueing for **all** PHP scripts.

### Native PHP Way (`mail()`)
Any PHP script (including WordPress core) using the native `mail()` function will work:
```php
mail('user@example.com', 'Subject', 'Body');
```
The custom Dockerfile installs `msmtp`, which is configured to route all traffic to the `mail-relay` sidecar instantly. This ensures that the PHP process doesn't wait for the external SMTP server to respond.

---

---

## Caching & Performance

### LiteSpeed Cache (LSCache)
This setup automatically installs and enables the **LiteSpeed Cache** plugin as a **Must-Use (MU) plugin**. This ensures it is always active and cannot be accidentally deactivated from the WordPress dashboard.

### Redis Object Cache
> [!IMPORTANT]
> **This setup is zero-config.**
> LiteSpeed Cache is automatically configured to use the included `valkey` service for object caching. Do not install the separate "Redis Object Cache" plugin, as it will conflict with this built-in, pre-configured setup.
>
> You can verify the status under **LiteSpeed Cache > Settings > Object**. You should see that Object Cache is enabled and connected to the `valkey` host.

---

## Why OpenLiteSpeed?
OpenLiteSpeed is a high-performance HTTP server that handles massive concurrency with low memory footprint. It is specifically optimized for WordPress and supports **LSCache** (the LiteSpeed Cache plugin).

---

## Accessing the OLS Admin Panel
You can access the OLS WebAdmin console on port **7080**.
- **User**: `admin`
- **Password**: The `OLS_PASSWORD` you set in Dokploy.

---

## Modifying Configuration in Dokploy

Since Dokploy allows you to modify any file, you can adjust your configuration directly from the dashboard.

### Using Dokploy "Files" Feature
1.  Navigate to your **WordPress Service** (or OLS) in Dokploy.
2.  Go to the **Files** tab.
3.  Edit the desired file (e.g., `/usr/local/etc/php/conf.d/uploads.ini`).
4.  **Save and Redeploy**: Dokploy updates the file and restarts the service.
