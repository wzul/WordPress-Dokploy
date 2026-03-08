# WordPress Deployment with Dokploy

This repository contains a WordPress setup optimized for deployment via [Dokploy](https://dokploy.com/). It includes pre-configured PHP settings for file uploads, Opcache, and Nginx.

## Project Structure

- `docker-compose.yml`: Main configuration to orchestrate WordPress and Nginx.
- `php/`: Directory containing PHP configuration overrides.
  - `uploads.ini`: Sets common limits like `upload_max_filesize` (64M) and `memory_limit` (256M).
  - `opcache.ini`: Enables and optimizes Opcache for better performance.
  - `fpm-pool.conf`: Custom PHP-FPM process manager settings.
- `nginx/`: Directory containing Nginx configuration.
  - `default.conf`: Configures Nginx to proxy PHP requests to the WordPress FPM service.

## Deployment Instructions

1.  **Preparation**: Ensure your repository is pushed to a Git provider (GitHub, GitLab, etc.).
2.  **In Dokploy**:
    - Create a new **Compose** project.
    - Connect your Git repository.
    - Dokploy will automatically detect the `docker-compose.yml` file.
3.  **Environment Variables**:
    - Define the following environment variables in the Dokploy **"Environment"** tab for your project:
      - `WORDPRESS_DB_HOST`: The hostname of your database (defaults to `wp_db`).
      - `WORDPRESS_DB_NAME`: The name of your database (defaults to `wordpress`).
      - `WORDPRESS_DB_USER`: Your database user (defaults to `wordpress`).
      - `WORDPRESS_DB_PASSWORD`: Your database password.
      - `WORDPRESS_MEMORY_LIMIT`: PHP memory limit (defaults to `256M`).
4.  **Deploy**: Click **Deploy** to start the WordPress and Nginx containers.

---

## Modifying PHP Configuration in Dokploy

Since Dokploy allows you to modify any file, you can easily adjust your PHP settings directly from the dashboard.

### Using Dokploy "Files" Feature
To modify a configuration file:
1.  Navigate to your **WordPress Service** in Dokploy.
2.  Go to the **Files** tab.
3.  Choose the file you want to edit (e.g., `/usr/local/etc/php/conf.d/uploads.ini`).
4.  **Save and Redeploy**: Dokploy will update the file content and restart the service with the new settings.
