# PHP Configuration

We have exposed several configuration points to make PHP tuning easy.

## 📁 Configuration Directory (`php/`)
Files in the `php/` directory are mounted into the WordPress container at startup.

### 1. `uploads.ini` (Limits)
Adjust this file to change:
- `upload_max_filesize`
- `post_max_size`
- `max_execution_time`

> [!TIP]
> **Synchronized Memory Limit**: You don't need to edit `uploads.ini` to change the RAM limit. Simply set the `WORDPRESS_MEMORY_LIMIT` environment variable in Dokploy. The system will automatically update both your **PHP `memory_limit`** and the **WordPress `WP_MEMORY_LIMIT`** to match that value!

### 2. `opcache.ini` (Performance)
Pre-configured with optimized settings for WordPress, including:
- `opcache.memory_consumption=128`
- `opcache.max_accelerated_files=4000`

### 3. `fpm-pool.conf` (Process Management)
Controls how many PHP processes are spawned. If you have a high-traffic site, you may want to increase `pm.max_children`.

## 🛠️ Modifying Settings via Dokploy
You don't need to push a new commit to change these settings:
1. Go to the **WordPress service** in Dokploy.
2. Navigate to the **Files** tab.
3. Edit the file (e.g., `/usr/local/etc/php/conf.d/uploads.ini`).
4. Click **Save and Redeploy**.
