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
> [!IMPORTANT]
> **This setup is pre-configured.**
>
> LiteSpeed Cache is automatically configured to use our `valkey` service. You do **NOT** need to perform any manual setup or install any other Redis plugins.
>
> **Forced Settings:**
> - **Method:** Redis
> - **Host:** `valkey`
> - **Port:** `6379`
>
> These settings are injected via a Must-Use plugin and will override any changes made in the WordPress dashboard, ensuring the site always stays connected to the fastest available cache backend.

## 🔧 Architecture
In this **unified setup**, OpenLiteSpeed and PHP are in the same container.
- **Static Files**: OLS serves CSS, JS, and images directly from `/var/www/html/`.
- **PHP Handling**: OLS uses the built-in **LSAPI (Litespeed SAPI)** to process PHP 8.4 files natively. This is significantly more efficient than traditional FastCGI networking.

## 📜 Logs
OpenLiteSpeed logs are stored within the container at `/usr/local/lsws/logs/`. You can view them directly in the Dokploy dashboard under the **`wordpress`** service logs.
