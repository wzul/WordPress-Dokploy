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
If you just want to copy-paste the configuration without linking a repository:

1.  **In Dokploy**: Select **Add Service > Compose**.
2.  **Setup**: Select the **"Raw"** input type.
3.  **Paste**: Copy and paste the following block into the editor:
4.  **Environment**: Don't forget to add your variables from the [**.env.example**](.env.example) file in the **Environment** tab.

```yaml
services:
  wordpress:
    image: ghcr.io/wzul/wordpress-dokploy:latest
    volumes:
      - wp_app:/var/www/html
    init: true
    env_file: ".env"
    restart: unless-stopped

  mail-relay:
    image: ghcr.io/wzul/wordpress-dokploy-mail-relay:latest
    env_file: ".env"
    restart: unless-stopped

  valkey:
    image: valkey/valkey:latest
    command: valkey-server --protected-mode no
    restart: unless-stopped

volumes:
  wp_app:
```

4. **Environment Variables**: Go to the service's **Environment** tab. Add your settings (e.g., `WORDPRESS_DB_PASSWORD`, `SMTP_PASSWORD`). Review the `.env.example` file in this repository for a list of all tunable settings!
5. **Deploy**: Click **Deploy**! Dokploy will instantly pull the pre-compiled images and launch your site.
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

## Accessing the OLS Admin Panel
You can access the OLS WebAdmin console on port **7080**.
- **User**: `admin`
- **Password**: The `OLS_PASSWORD` you set in Dokploy.

---

## 🌍 Environment-Driven Configuration (12-Factor App)

This stack eliminates messy file mounts and hardcoded templates. **Everything** is configured via simple Environment Variables inside Dokploy's "Environment" tab:

- **PHP Tuning**: `WORDPRESS_UPLOAD_LIMIT=128M`, `WORDPRESS_MEMORY_LIMIT=512M`
- **Opcache**: `OPCACHE_REVALIDATE_FREQ=300`
- **Security**: `OLS_PASSWORD=MySecureAdminPass`

Simply add the key to Dokploy, and upon clicking deploy, the entrypoint script rebuilds your server architecture perfectly! No more SSHing to touch `php.ini`.
