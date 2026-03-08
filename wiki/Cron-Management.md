# Cron & Scheduled Tasks (Dokploy Scheduler)

By default, WordPress runs its scheduled tasks (cron) only when a visitor visits your site. For better performance and reliability, we offload this to **Dokploy's built-in scheduler**.

## 🛡️ How it works

1.  **Internal Cron Disabled**: The internal WordPress cron is disabled in `wp-config.php` via the `DISABLE_WP_CRON` environment variable.
2.  **Dokploy Scheduler**: Dokploy triggers the WordPress cron on a fixed schedule.
3.  **Direct Execution**: Dokploy runs the `php wp-cron.php` command directly inside the `wordpress` container.

## 🛠️ Configuration in Dokploy

Instead of adding another container (like Ofelia), you can use the native Dokploy UI:

1.  **Open your Compose Project** in the Dokploy Dashboard.
2.  Navigate to the **Scheduler** tab.
3.  Click **Add Cron Job**.
4.  **Configuration**:
    - **Name**: `WordPress Cron`
    - **Schedule**: `*/5 * * * *` (Every 5 minutes)
    - **Service**: Select `wordpress`.
    - **Command**: `php wp-cron.php`
5.  Click **Save**.

## 🚀 Monitoring

You can see the execution history and logs of your cron jobs directly in the Dokploy **Scheduler** tab. This makes it very easy to verify if tasks are running correctly.

## 💡 Why this is better
- **Zero Overhead**: No extra container listening to the Docker socket.
- **Native UI**: Monitor and manage your cron jobs alongside your deployment.
- **Reliability**: Uses the underlying host's system cron via Dokploy.
