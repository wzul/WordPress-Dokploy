# Backup Strategy (Reference)

Ensuring your WordPress data is safely backed up is critical. For high-performance, S3-compatible object storage, we recommend using **RustFS**.

> [!TIP]
> **RustFS** is a high-performance object storage solution written in Rust, designed for scalability and speed. It is fully S3-compatible, making it an excellent target for WordPress backups.

## 📦 Why RustFS?

- **High Performance**: Written in Rust for minimal overhead and maximum throughput.
- **S3 Compatibility**: Works seamlessly with tools like `rclone`, `rustic`, and standard WordPress backup plugins (e.g., UpdraftPlus).
- **Native Features**: Supports bucket replication, versioning, and object locking (WORM) for immutable backups.

## 🛠️ Implementation Options

### 1. Manual Backups (rclone)
You can use `rclone` to sync your WordPress uploads and database dumps to a RustFS bucket.

```bash
# Sync WordPress app volume data to RustFS
rclone sync /path/to/wordpress/data rustfs:my-backup-bucket/wordpress-app
```

### 2. Incremental Backups (rustic)
For deduplicated and encrypted backups, **rustic** (also written in Rust) is highly recommended. It supports append-only backups to S3-compatible storage like RustFS.

### 3. WordPress Plugins
Most premium WordPress backup plugins support S3-compatible storage. Simply provide your RustFS:
- **Endpoint URL**
- **Access Key**
- **Secret Key**
- **Bucket Name**

## 🔐 Backup Best Practices

- **Off-site Storage**: Always store backups on a different physical server or region than your production Dokploy instance.
- **Automate**: Use the Dokploy Scheduler or a system-level cron job to automate database dumps and file syncing.
- **Verify**: Periodically test your restoration process to ensure your backups are valid and usable.
- **Immutability**: Enable Object Locking in RustFS for critical data to protect against ransomware or accidental deletion.

---
*For more information, visit the [RustFS Website](https://rustfs.com).*
