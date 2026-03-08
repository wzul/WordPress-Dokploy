# OpenLiteSpeed Management

This stack uses **OpenLiteSpeed (OLS)**, the open-source version of LiteSpeed Enterprise.

## 🖥️ WebAdmin Console
OpenLiteSpeed comes with a powerful web-based administration panel.

- **Internal Port**: `7080`
- **Dokploy Setup**: Add a domain in Dokploy and point it to service `ols` on port **7080**.
- **User**: `admin`
- **Password**: The value of `OLS_PASSWORD` in your Dokploy settings.

## 🚀 LSCache
To get the most out of OLS, we recommend installing the **LiteSpeed Cache** plugin in WordPress. It communicates directly with the OLS server to handle page caching, image optimization, and more.

## 🔧 Configuration
The Virtual Host configuration is stored in `ols/vhconf.conf`. 
In this setup, OLS is configured to:
- Serve static files (CSS, JS, Images) directly from the `wp_app` volume.
- Forward all `.php` requests to the `wordpress` service on port `9000` via FastCGI.

## 📜 Logs
OpenLiteSpeed logs are stored within the container at `/usr/local/lsws/logs/`. You can view them directly in the Dokploy dashboard under the `ols` service logs.
