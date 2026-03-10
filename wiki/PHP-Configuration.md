# PHP Configuration

We have exposed several configuration points to make PHP tuning easy.

## 🌍 Environment-Driven Configuration
To keep the application highly scalable and maintainable, this stack uses a **12-Factor App approach**. You do not need to edit or mount any `.ini` files. 

All PHP and Opcache settings are dynamically injected at container startup using Environment Variables.

### 1. PHP Limits
Add the following keys to your Dokploy **Environment** tab to adjust typical limits:
- `WORDPRESS_MEMORY_LIMIT` (Default: `256M`)
- `WORDPRESS_UPLOAD_LIMIT` (Default: `64M`) - Controls both `upload_max_filesize` and `post_max_size`
- `WORDPRESS_MAX_EXECUTION_TIME` (Default: `300`)
- `WORDPRESS_MAX_INPUT_VARS` (Default: `3000`)

### 2. Opcache (Performance)
The stack comes pre-configured with highly tuned settings for WordPress production. You can override these via the exact same method:
- `OPCACHE_MEMORY_CONSUMPTION` (Default: `256`)
- `OPCACHE_MAX_ACCELERATED_FILES` (Default: `15000`)
- `OPCACHE_REVALIDATE_FREQ` (Default: `300`)

> [!TIP]
> **Production vs Development**: These values are optimized for production where code rarely changes (`revalidate_freq=300` means PHP only checks for modified files every 5 minutes). For active development, you may want to set `OPCACHE_REVALIDATE_FREQ` to `2`.

### 3. Native LSAPI Process Management
Since this stack uses **OpenLiteSpeed + LSAPI**, you no longer need to manage complex PHP-FPM pools. 

LiteSpeed handles process spawning and scaling natively:
- **High Efficiency**: Processes communicate via lightning-fast local SAPIs rather than network-based FastCGI.
- **Auto-Scaling**: LiteSpeed automatically adjusts the number of PHP workers based on incoming traffic.
- **Resource Management**: In-built protection ensures that a spike in traffic won't crash your server by overloading individual PHP pools.

### 4. Direct Configuration
If you need to adjust specific LiteSpeed PHP external processor settings (like `maxConns`), these can be modified in the **WebAdmin Console** (Port 7080) or via the global `httpd_config.conf` within the container.

## 🛠️ Modifying Settings via Dokploy
You don't need to push a new commit or SSH into the server to change these settings:
1. Go to the **WordPress service** in Dokploy.
2. Navigate to the **Environment** tab.
3. Add a new variable (e.g., Key: `WORDPRESS_UPLOAD_LIMIT`, Value: `128M`).
4. Click **Deploy**.

Upon restart, the entrypoint script will instantly rebuild your PHP configurations perfectly.
