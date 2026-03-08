# WordPress Deployment with Dokploy

This repository contains a WordPress setup optimized for deployment via [Dokploy](https://dokploy.com/). It includes pre-configured PHP settings for file uploads, Opcache, and a mechanism for easy overrides within Dokploy.

## Project Structure

- `docker-compose.yml`: Main configuration to orchestrate WordPress and its database.
- `php/`: Directory containing PHP configuration overrides.
  - `uploads.ini`: Sets common limits like `upload_max_filesize` (64M) and `memory_limit` (256M).
  - `opcache.ini`: Enables and optimizes Opcache for better performance.
  - `z-dokploy-overrides.ini`: A placeholder file meant for final overrides.

## Deployment Instructions

1.  **Preparation**: Ensure your repository is pushed to a Git provider (GitHub, GitLab, etc.).
2.  **In Dokploy**:
    - Create a new **Compose** project.
    - Connect your Git repository.
    - Dokploy will automatically detect the `docker-compose.yml` file.
3.  **Environment Variables**:
    - Define `$DB_NAME` and `$DB_PASSWORD` in the Dokploy "Environment" tab for your project.
4.  **Deploy**: Click **Deploy** to start the WordPress and Database containers.

---

## Overriding PHP Configuration with Dokploy

One of the key features of this setup is the ability to override PHP settings directly from the Dokploy dashboard without modifying the code in your repository.

### How it works
PHP loads `.ini` files from `/usr/local/etc/php/conf.d/` in alphabetical order. We have mounted a file named `z-dokploy-overrides.ini` which will always be loaded **last**, allowing it to override any settings defined in `uploads.ini` or `opcache.ini`.

### Using Dokploy "Files" Feature
To apply a patch or override:
1.  Navigate to your **WordPress Service** in Dokploy.
2.  Go to the **Files** tab.
3.  Create a new file with the following details:
    - **Path**: `/usr/local/etc/php/conf.d/z-dokploy-overrides.ini`
    - **Content**: Enter any PHP settings you wish to change. For example:
      ```ini
      memory_limit = 512M
      upload_max_filesize = 128M
      ```
4.  **Save and Redeploy**: Dokploy will now mount your dashboard-managed file over the one in the repository, giving you full control over the PHP environment from the UI.
