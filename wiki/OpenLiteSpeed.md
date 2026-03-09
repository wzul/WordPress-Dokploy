# OpenLiteSpeed Management

This stack uses **OpenLiteSpeed (OLS)**, the open-source version of LiteSpeed Enterprise.

## 🖥️ WebAdmin Console
OpenLiteSpeed comes with a powerful web-based administration panel.

- **Internal Port**: `7080`
- **Internal Port**: `7080`
- **Dokploy Setup**: Add a domain mapping in Dokploy to the **`wordpress`** service on port **7080**.
- **User**: `admin`
- **Password**: The value of `OLS_PASSWORD` in your Dokploy settings.

## 🚀 LSCache
The **LiteSpeed Cache** plugin is automatically installed as a **Must-Use (MU) plugin**. This ensures it is always active and cannot be deactivated via the WordPress dashboard.

### 🛑 Important: Object Caching
> [!WARNING]
> **Do NOT use the "Redis Object Cache" plugin.**
>
> LiteSpeed Cache replaces the need for any other Redis/Object Cache plugins. It includes its own highly optimized Object Cache module that is fully compatible with our `valkey` (Redis) service.
>
> **Configuration:**
> - **Method:** Redis
> - **Host:** `valkey`
> - **Port:** `6379`

## 🔧 Architecture
In this **unified setup**, OpenLiteSpeed and PHP are in the same container.
- **Static Files**: OLS serves CSS, JS, and images directly from `/var/www/html/`.
- **PHP Handling**: OLS uses the built-in **LSAPI (Litespeed SAPI)** to process PHP 8.4 files natively. This is significantly more efficient than traditional FastCGI networking.

## 📜 Logs
OpenLiteSpeed logs are stored within the container at `/usr/local/lsws/logs/`. You can view them directly in the Dokploy dashboard under the **`wordpress`** service logs.
