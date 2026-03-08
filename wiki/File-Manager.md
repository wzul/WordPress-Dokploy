# File Manager Guide

This stack includes **FileBrowser**, a lightweight web-based file manager that allows you to manage your WordPress files directly from your browser.

## 📁 Accessing the File Manager

- **URL**: `https://your-domain.com/<FILE_MANAGER_PATH>` (See [Security Hardening](Security-Hardening.md) for details).
- **Username**: Defined by `FILE_MANAGER_USER` (defaults to `admin`)
- **Password**: Defined by `FILE_MANAGER_PASSWORD` (defaults to `admin123`)

> [!NOTE]
> You can set these credentials directly in the **Dokploy Environment** tab. If you change them there, you will need to delete the `filebrowser_db` volume to reset the database and apply the new credentials, or change them manually inside the UI.

## 🛠️ Key Features

- **Direct Editing**: Edit themes, plugins, and CSS files directly in the browser with syntax highlighting.
- **Upload/Download**: Easily move files between your computer and the server.
- **Archive Management**: Create and extract `.zip` or `.tar.gz` files.
- **User Management**: Create additional users with restricted access to specific folders.

## 🔒 Security and Permissions

### User Identity
The File Manager is configured to run as user `www-data` (UID 33). This is the same user that runs WordPress and OpenLiteSpeed.
- Any file you upload will automatically have the correct permissions for WordPress to read/write.
- You won't run into "Permission Denied" errors when updating plugins or uploading media.

### Path Mapping
The File Manager is mapped to the root of your WordPress installation (`/var/www/html`).
- You can access `wp-content`, `wp-config.php`, `.htaccess`, and all other core files.

## 🚀 Troubleshooting

### "Page Not Found" on /file-manager/
Ensure that you included the trailing slash in the URL: `your-domain.com/file-manager/`. OpenLiteSpeed relies on this slash to match the proxy context.

### Cannot Upload Large Files
If you encounter errors when uploading large files, you may need to increase the `client_max_body_size` equivalent in OpenLiteSpeed (though OLS treats this differently, it's usually handled by the `Max Request Body Size` setting in the Server configuration).
