# WordPress Deployment with Dokploy

This repository contains a WordPress setup optimized for deployment via [Dokploy](https://dokploy.com/). It includes pre-configured PHP settings for file uploads, Opcache, Nginx, and a built-in SMTP relay sidecar for queued email delivery.

## Project Structure

- `docker-compose.yml`: Main configuration to orchestrate WordPress, Nginx, and the Mail Relay.
- `php/`: Directory containing PHP configuration overrides.
  - `smtp.php`: A "Must-Use" plugin that automatically configures WordPress to use the SMTP relay sidecar.
- `nginx/`: Directory containing Nginx configuration.

## Deployment Instructions

1.  **Preparation**: Ensure your repository is pushed to a Git provider (GitHub, GitLab, etc.).
2.  **In Dokploy**:
    - Create a new **Compose** project.
    - Connect your Git repository.
    - Dokploy will automatically detect the `docker-compose.yml` file.
3.  **Environment Variables**:
    - Define the following in the Dokploy **"Environment"** tab:
    - **WordPress Variables**:
      - `WORDPRESS_DB_HOST`: Database hostname (defaults to `wp_db`).
      - `WORDPRESS_DB_PASSWORD`: Database password.
      - `WORDPRESS_MEMORY_LIMIT`: PHP memory limit (defaults to `256M`).
    - **SMTP Relay Variables**:
      - `SMTP_SERVER`: Your SMTP provider (e.g., `smtp.mailgun.org`).
      - `SMTP_PORT`: SMTP port (defaults to `587`).
      - `SMTP_USERNAME`: SMTP user.
      - `SMTP_PASSWORD`: SMTP password.
      - `SERVER_HOSTNAME`: Your site domain (e.g., `example.com`).
4.  **Deploy**: Click **Deploy** to start all services.

---

## SMTP Setup (Zero-Plugin / Automatic)

This project uses a **Must-Use (MU) Plugin** strategy. We have mounted `php/smtp.php` directly into WordPress's `mu-plugins` folder.

**Benefits:**
- **No Configuration Required**: You don't need to install or configure any SMTP plugin in the WordPress dashboard.
- **Background Queueing**: The `mail-relay` service handles emails in the background so your site stays fast.
- **Port 25 Internal**: WordPress connects to the sidecar on port 25 without any authentication or encryption, which is safe inside the internal Docker network.

---

## Modifying Configuration in Dokploy

Since Dokploy allows you to modify any file, you can adjust your PHP or Nginx settings directly from the dashboard.

### Using Dokploy "Files" Feature
1.  Navigate to your **WordPress Service** (or Nginx) in Dokploy.
2.  Go to the **Files** tab.
3.  Edit the desired file (e.g., `/usr/local/etc/php/conf.d/uploads.ini`).
4.  **Save and Redeploy**: Dokploy updates the file and restarts the service.
