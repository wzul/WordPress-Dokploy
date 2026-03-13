# WordPress Deployment with Dokploy (OpenLiteSpeed)

This repository contains a WordPress setup optimized for deployment via [Dokploy](https://dokploy.com/). It includes pre-configured PHP settings, **OpenLiteSpeed** as the web server, and a built-in SMTP relay sidecar for high-performance email delivery.

> [!TIP]
> **Check out the [Project Wiki](wiki/Home.md) for detailed documentation on architecture, SMTP, and OpenLiteSpeed management.**

## Project Structure

- `docker-compose.yml`: The primary production/distribution entry point! Optimized to pull pre-built images for instant deployment.
- `docker-compose.local.yml`: The local development playground! Built-in port 8080/7080 mapping and uses `build: .` to test your local code changes immediately.
- `php/docker-entrypoint-extra.sh`: The brains of the operation! Dynamically configures OpenLiteSpeed, PHP limits, Opcache, and Mail routing entirely from your Environment Variables on startup.

## 🚀 Deployment Instructions

> [!NOTE]
> For a more detailed step-by-step guide, see our **[Deployment Guide Wiki](wiki/Deployment.md)**.

### 1. Git Repository Deployment (Recommended)
This is the most professional way to deploy, as it allows for easy updates and version control directly in Dokploy.

1.  **In Dokploy**: Navigate to your Project and select **Add Service > Compose**.
2.  **Source**: Select the **"Git"** input type.
3.  **Repository**: Paste `https://github.com/wzul/WordPress-Dokploy`.
4.  **Configuration**:
    *   **Branch**: `main`
    *   **Compose Path**: `./docker-compose.yml`
5.  **Environment**: Add your environment variables in the **Environment** tab. You can find all available options and defaults in the [**.env.example**](.env.example) file.
6.  **Deploy**: Hit the **Deploy** button!

---

### 2. Manual "Raw YAML" Deployment
If you prefer to copy-paste the configuration manually into Dokploy:

1.  Open the [**docker-compose.yml**](docker-compose.yml) file in this repository.
2.  **Copy** the entire contents of that file.
3.  **In Dokploy**: Select **Add Service > Compose**.
4.  **Setup**: Select the **"Raw"** input type and paste the contents.
5.  **Environment**: Add your variables from the [**.env.example**](.env.example) file in the **Environment** tab.
6.  **Deploy**: Click **Deploy**!
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

### Automated WP-Cron
This project offloads WordPress cron tasks to the **Dokploy Scheduler**. 
- The internal WP-Cron is automatically disabled in `wp-config.php` when `DISABLE_WP_CRON=true` is set in your environment.
- This prevents performance issues caused by cron tasks running during visitor page loads.
- See the [Cron Management Wiki](wiki/Cron-Management.md) for setup instructions.

---

## Why OpenLiteSpeed?
OpenLiteSpeed is a high-performance HTTP server that handles massive concurrency with low memory footprint. It is specifically optimized for WordPress and supports **LSCache** (the LiteSpeed Cache plugin).

---

## ⚡ Performance Auditing
You can test your site's speed using **sitespeed.io** via Docker. This will provide you with a comprehensive report on PageSpeed, Core Web Vitals, and more.

```bash
docker run --rm -v "$(pwd):/sitespeed.io" sitespeedio/sitespeed.io:39.4.2 https://your-domain.com/
```
- See the [**Performance Testing Wiki**](wiki/Performance-Testing.md) for more details.

---

## Accessing the OLS Admin Panel
You can access the OLS WebAdmin console on port **7080**.

- **User**: `admin`
- **Password**: The `OLS_PASSWORD` you set in Dokploy.

---
---

## 🏗️ Usage as a General PHP Image

While this image is optimized for WordPress, it can be used for any PHP application by disabling the WordPress-specific initialization steps.

Set the following environment variable to `false`:
- `INSTALL_WORDPRESS=false`

This will:
- Skip downloading WordPress core.
- Skip installing LiteSpeed Cache (MU) plugins.
- Skip generating or modifying `wp-config.php`.

The basic front controller rewrite rules (directing non-existent files/dirs to `index.php`) remain active to support modern PHP frameworks like Laravel or custom apps.

You can then mount your own PHP application code to `/var/www/html`.

---
---

## 🌍 Environment-Driven Configuration (12-Factor App)

This stack eliminates messy file mounts and hardcoded templates. **Everything** is configured via simple Environment Variables inside Dokploy's "Environment" tab:

- **PHP Tuning**: `WORDPRESS_UPLOAD_LIMIT=128M`, `WORDPRESS_MEMORY_LIMIT=512M`
- **Opcache**: `OPCACHE_REVALIDATE_FREQ=300`
- **Security**: `OLS_PASSWORD=MySecureAdminPass`

Simply add the key to Dokploy, and upon clicking deploy, the entrypoint script rebuilds your server architecture perfectly! No more SSHing to touch `php.ini`.

---

## 📜 License

This project is licensed under the **GPL-3.0 License**. See the [LICENSE](LICENSE) file for the full text. This ensures compatibility with the core technologies utilized in this stack, including OpenLiteSpeed, WordPress, and LiteSpeed Cache.
