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
Pre-configured with optimized settings for WordPress. You can easily "patch" or override these settings directly from the Dokploy dashboard by editing the file in the `php/` directory.

Key settings include:
- `opcache.memory_consumption=128`
- `opcache.max_accelerated_files=10000`
- `opcache.revalidate_freq=2`

> [!TIP]
> **Production vs Development**: For a production site where code rarely changes, you can increase `opcache.revalidate_freq` to `60` or more to gain extra performance.

### 3. Native LSAPI Process Management
Since this stack uses **OpenLiteSpeed + LSAPI**, you no longer need to manage complex PHP-FPM pools. 

LiteSpeed handles process spawning and scaling natively:
- **High Efficiency**: Processes communicate via lightning-fast local SAPIs rather than network-based FastCGI.
- **Auto-Scaling**: LiteSpeed automatically adjusts the number of PHP workers based on incoming traffic.
- **Resource Management**: In-built protection ensures that a spike in traffic won't crash your server by overloading individual PHP pools.

### 4. Direct Configuration
If you need to adjust specific LiteSpeed PHP external processor settings (like `maxConns`), these can be modified in the **WebAdmin Console** (Port 7080) or via the global `httpd_config.conf` within the container.

## 🛠️ Modifying Settings via Dokploy
You don't need to push a new commit to change these settings:
1. Go to the **WordPress service** in Dokploy.
2. Navigate to the **Files** tab.
3. Edit the file (e.g., `/usr/local/etc/php/conf.d/uploads.ini`).
4. Click **Save and Redeploy**.
