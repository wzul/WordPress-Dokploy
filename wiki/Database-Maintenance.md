# Database Maintenance & Upgrades

This project uses an optimized **MariaDB** setup. Because MariaDB requires system table updates when moving between versions, follow this guide for safe upgrades.

## 🔄 How to Upgrade MariaDB

If you want to update to the latest optimized MariaDB version:

1.  **Perform a Backup**:
    - Go to your **MariaDB** service in Dokploy.
    - Navigate to the **Backups** tab and click **Run Backup** to ensure you have a fresh restore point.

2.  **Pull & Deploy**:
    - Go to your **Application/Project** in Dokploy.
    - Click the **Deploy** button.
    - Dokploy will automatically pull the latest pre-built GHCR image and restart the service.

3.  **Auto-Migration**:
    - This project has **MARIADB_AUTO_UPGRADE** enabled by default (`1`). 
    - The container will automatically detect the version change and run the necessary system table updates during start-up.

4.  **Verify via Logs**:
    - Navigate to the **Logs** tab of your MariaDB service in Dokploy.
    - Look for the message: `Running mariadb-upgrade... Success`.
    - Once the log says `ready for connections`, your upgrade is complete.


## ⚙️ Optimization (Small Sites)

The MariaDB configuration in `mariadb/my.cnf` is tuned for small WordPress sites (approx. 16MB buffer pool). If your site grows:
1. Increase `innodb_buffer_pool_size` in `mariadb/my.cnf`.
2. Increase `max_connections` (currently set to 12).
