# Database Management (Adminer + WP Auth)

This stack includes **Adminer**, a lightweight and secure database management tool. To protect your data, it is tightly integrated with WordPress authentication.

## 🔐 Security: WordPress Integration

Unlike standard database managers, this Adminer setup is **wrapped in WordPress security**:

1.  **WP Session Check**: You **must** be logged into your WordPress site as an **Administrator** to even see the login page.
2.  **Auto-Redirect**: If you are not logged in, the system will automatically redirect you to the WordPress login page (`/wp-login.php`).
3.  **Forbidden for Non-Admins**: Even if a regular user (like a Subscriber or Editor) finds the URL, they will receive an "Access Denied" error.

## 📁 Accessing Adminer

- **URL**: `https://your-domain.com/<DB_MANAGER_PATH>`
- **Default Path**: `/wp-db-admin`
- **Auto-Login**: Enabled. You no longer need to enter database credentials manually. The system uses your WordPress configuration automatically.

> [!IMPORTANT]
> Because of auto-login, it is **essential** that you maintain a strong password for your WordPress administrator account and use the secret `DB_MANAGER_PATH` for added security.

> [!TIP]
> **Security by Obscurity**: You can change the `DB_MANAGER_PATH` environment variable in Dokploy to something unique (e.g., `/db-secret-555`) to make it even harder for bots to find.

## 🚀 Why Adminer?

Adminer is a single-file PHP script that provides all the essential features of phpMyAdmin but with a much smaller footprint:
- **Memory Usage**: ~10MB - 15MB (compared to 80MB+ for phpMyAdmin).
- **Speed**: It loads much faster and is optimized for modern PHP.
- **Features**: Supports all standard operations like Export/Import, SQL commands, and User management.

## 🧪 Testing the Auth
1. Try to visit your database URL in an **Incognito** window. You should be redirected to the login page.
2. Log in as a regular **Subscriber**. Try to visit the database URL. You should see "Access Denied."
3. Log in as an **Admin**. Try to visit the URL. You should see the Adminer login screen.
