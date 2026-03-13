# OpenLiteSpeed Management

This stack uses **OpenLiteSpeed (OLS)**, the open-source version of LiteSpeed Enterprise.

## 🖥️ WebAdmin Console
OpenLiteSpeed comes with a powerful web-based administration panel.

- **Internal Port**: `7080`
- **Dokploy Setup**: Add a domain mapping in Dokploy to the **`wordpress`** service on port **7080**.
- **User**: `admin`
- **Password**: The value of `OLS_PASSWORD` in your Dokploy settings.

## 🚀 LSCache
The **LiteSpeed Cache** plugin is automatically installed as a **Must-Use (MU) plugin**. This ensures it is always active and cannot be deactivated via the WordPress dashboard.

### 🛑 Zero-Config Object Caching
This setup is pre-configured to use our `valkey` service automatically.

**Default Forced Settings:**
- **Method:** Redis
- **Host:** `valkey` (Configurable via `VALKEY_HOST`)
- **Port:** `6379` (Configurable via `VALKEY_PORT`)

**Advanced Control:**
You can toggle the forced configuration via:
- `LITESPEED_CACHE_OBJECT_CONF` (Default: `true`)
- `LITESPEED_CACHE_OBJECT_ENABLE` (Default: `true`)

These settings are injected via a Must-Use plugin and will override manual changes in the WordPress dashboard. For a full list of available variables, see the [Deployment Guide](Deployment.md#🔑-environment-variables).

## 🔧 Architecture
In this **unified setup**, OpenLiteSpeed and PHP are in the same container.
- **Static Files**: OLS serves CSS, JS, and images directly from `/var/www/html/`.
- **PHP Handling**: OLS uses the built-in **LSAPI (Litespeed SAPI)** to process PHP 8.4 files natively. This is significantly more efficient than traditional FastCGI networking.

## ⚡ Performance & Compression
This stack is pre-configured with industry-standard compression to ensure your pages load at maximum speed.

- **Gzip Compression**: Enabled by default (`GZIP_ENABLE=1`). Compresses static and dynamic content for broad browser compatibility.
- **Brotli Compression**: Enabled by default (`BROTLI_ENABLE=1`). Provides superior compression ratios compared to Gzip for modern browsers.

These can be toggled via environment variables in Dokploy.

## 📜 Logs
OpenLiteSpeed logs are stored within the container at `/usr/local/lsws/logs/`. You can view them directly in the Dokploy dashboard under the **`wordpress`** service logs.
