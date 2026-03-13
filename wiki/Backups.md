# Backup Strategy (Reference)

Ensuring your WordPress data is safely backed up is critical. For high-performance, S3-compatible object storage, we recommend using **RustFS**.

> [!TIP]
> **RustFS** is a high-performance object storage solution written in Rust, designed for scalability and speed. It is fully S3-compatible, making it an excellent target for WordPress backups.

## 📦 Why RustFS?

- **High Performance**: Written in Rust for minimal overhead and maximum throughput.
- **S3 Compatibility**: Works seamlessly with tools like `rclone`, `rustic`, and standard WordPress backup plugins (e.g., UpdraftPlus).
- **Native Features**: Supports bucket replication, versioning, and object locking (WORM) for immutable backups.
- **Dokploy Native Compatibility**: Recommended for use with Dokploy's built-in backup features, enabling seamless management directly through the Dokploy interface.


## 🛠️ Implementation (Dokploy Native)

The recommended way to back up this stack is using Dokploy's built-in backup engine. This allows you to manage everything from a single interface without installing extra WordPress plugins or manual scripts.

### 1. Configure RustFS as Storage
1. Log in to your **Dokploy** panel.
2. Navigate to **Backup Destinations** (or equivalent settings).
3. Add a new **S3 Compatible** destination with your RustFS details:
    - **Endpoint**: Your RustFS URL (e.g., `http://rustfs-container-name:9000`)
    - **Access Key**: Your RustFS Access Key
    - **Secret Key**: Your RustFS Secret Key
    - **Bucket**: Your desired backup bucket name

### 2. Enable Service Backups
1. Go to your **WordPress Project** in Dokploy.
2. For each service (WordPress and Valkey/Database):
    - Navigate to the **Backups** tab.
    - Select your **RustFS destination**.
    - Set your **Cron Schedule** (e.g., `0 0 * * *` for daily at midnight).
    - Choose the **Retention Policy** (how many backups to keep).
3. Click **Save/Enable**.


## 🔐 Backup Best Practices

- **Off-site Storage**: Always store backups on a different physical server or region than your production Dokploy instance.
- **Automate**: Use the Dokploy Scheduler or a system-level cron job to automate database dumps and file syncing.
- **Verify**: Periodically test your restoration process to ensure your backups are valid and usable.
- **Immutability**: Enable Object Locking in RustFS for critical data to protect against ransomware or accidental deletion.

---
*For more information, visit the [RustFS Website](https://rustfs.com).*
