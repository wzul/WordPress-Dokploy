This project includes **FileBrowser Quantum** (a powerful fork by gtsteffaniak) as an optional service. It offers a modern interface, real-time search, and better thumbnail support.

## 🛠️ How to Enable in Dokploy

Filebrowser is categorized under the `tools` profile.

1.  Log in to your **Dokploy** panel.
2.  Navigate to your **Project -> Environment Variables**.
3.  Add or update the following variable:
    ```env
    COMPOSE_PROFILES=tools
    ```
4.  **Save** and **Deploy** the project.
5.  **Accessing Filebrowser**: 
    - You must add a **Domain** or **Port** to the `filebrowser` service in the Dokploy UI.
    - If testing locally, it is available at `http://localhost:8082`.

## ⚙️ Key Configuration Details

### 1. Quantum Fork Features
We use the `gtstef/filebrowser:stable` image, which includes:
- **Real-time Search**: Search results as you type.
- **Enhanced Thumbnails**: Better support for videos and office documents.
- **Multiple Sources**: You can map multiple different volumes/folders in the settings.

### 2. Permissions
The service is configured with `user: "0:0"` (root) to ensure it has full permission to manage the WordPress files (which are owned by `nobody`).

### 3. Data Persistence
All settings, users, and the database are stored in the `filebrowser_data` volume, which is mounted at `/home/filebrowser/data` inside the container.

## 🔐 Security Recommendations

> [!WARNING]
> Web-based file managers are high-security risks if not protected.

- **Immediate Password Change**: The default login for Filebrowser is `admin` / `admin`. Change this immediately upon first login.
- **HTTPS**: Always use a domain with SSL (HTTPS) when accessing Filebrowser.
- **Disable when not in use**: Set `COMPOSE_PROFILES=` (empty) and redeploy to stop the service when your maintenance task is finished.
- **IP Restriction**: Use Dokploy's advanced settings or a firewall to restrict access to your specific IP address.

## 🔄 Zero-Downtime Permission Healing

If you frequently upload files as `root` (via Filebrowser) and want to ensure they are always converted back to the correct WordPress permissions (`nobody`) without restarting your site, you can set up a **Dokploy Scheduler** task:

1.  Navigate to the **Scheduler** tab in your project.
2.  Add a new task:
    - **Name**: `Daily Permission Healing`
    - **Schedule**: `0 3 * * *` (Every night at 3 AM)
    - **Service**: `wordpress`
    - **Command**: `chown -R nobody:nogroup /var/www/html`
3.  This ensures all files are correctly owned every 24 hours with **zero downtime**.

---
*For more details on optional services, see [Optional Services](Optional-Services.md).*
