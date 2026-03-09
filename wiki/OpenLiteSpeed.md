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
To get the most out of OLS, we recommend installing the **LiteSpeed Cache** plugin in WordPress. It communicates directly with the OLS server to handle page caching, image optimization, and more.

## 🔧 Architecture
In this **unified setup**, OpenLiteSpeed and PHP are in the same container.
- **Static Files**: OLS serves CSS, JS, and images directly from `/var/www/html/`.
- **PHP Handling**: OLS uses the built-in **LSAPI (Litespeed SAPI)** to process PHP 8.4 files natively. This is significantly more efficient than traditional FastCGI networking.

## 📜 Logs
OpenLiteSpeed logs are stored within the container at `/usr/local/lsws/logs/`. You can view them directly in the Dokploy dashboard under the **`wordpress`** service logs.
