# WordPress Deployment with Dokploy

This repository contains a WordPress setup optimized for deployment via [Dokploy](https://dokploy.com/). It includes pre-configured PHP settings, Nginx, and a built-in SMTP relay sidecar that supports both WordPress and native PHP `mail()` functions.

## Project Structure

- `Dockerfile`: Custom image that installs `msmtp` for global PHP mail support.
- `docker-compose.yml`: Orchestrates WordPress, Nginx, and the Mail Relay.
- `php/`: Configuration for PHP, Opcache, FPM, and SMTP.
  - `mail.ini` & `msmtprc`: Configures the native PHP `mail()` function to use the relay.
  - `smtp.php`: A "Must-Use" plugin for optimized WordPress SMTP routing.
- `nginx/`: Nginx configuration.

## Deployment Instructions

1.  **Preparation**: Ensure your repository is pushed to a Git provider.
2.  **In Dokploy**:
    - Create a new **Compose** project.
    - Connect your Git repository.
    - Dokploy will detect the `docker-compose.yml` and use the `Dockerfile` to build your specialized WordPress image.
3.  **Environment Variables**:
    - Define variables in the Dokploy **"Environment"** tab for your project (see lists below).
4.  **Deploy**: Click **Deploy** to start all services.

---

## SMTP & Native mail() Support

This project supports background email queueing for **all** PHP scripts.

### 1. The WordPress Way (Optimized)
WordPress is automatically configured via a "Must-Use" plugin (`php/smtp.php`) to talk to the `mail-relay` service directly. No dashboard configuration is needed.

### 2. The Native PHP Way (`mail()`)
Any standalone PHP script using the native `mail()` function will also work:
```php
mail('user@example.com', 'Subject', 'Body');
```
The custom Dockerfile installs `msmtp`, which we have configured to route all traffic to the `mail-relay` sidecar instantly.

### Required Environment Variables:
- `SMTP_SERVER`: Your SMTP provider (e.g., `smtp.mailgun.org`).
- `SMTP_PORT`: SMTP port (defaults to `587`).
- `SMTP_USERNAME`: SMTP user.
- `SMTP_PASSWORD`: SMTP password.
- `SERVER_HOSTNAME`: Your site domain (e.g., `example.com`).

---

## Modifying Configuration in Dokploy

Since Dokploy allows you to modify any file, you can adjust your configuration directly from the dashboard.

### Using Dokploy "Files" Feature
1.  Navigate to your **WordPress Service** in Dokploy.
2.  Go to the **Files** tab.
3.  Edit files like `/usr/local/etc/php/conf.d/uploads.ini` or `/etc/msmtprc`.
4.  **Save and Redeploy**.
