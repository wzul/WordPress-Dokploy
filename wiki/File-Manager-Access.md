# File Manager Access

This project includes **Filebrowser** as an optional service to interact with your WordPress persistent volumes directly through a web interface.

## 🛠️ How to Enable in Dokploy

Filebrowser is categorized under the `tools` profile, the same as phpMyAdmin.

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

### 1. Permissions
The service is configured to run as `user: "65534:65534"` (nobody:nogroup). This matches the permissions used by OpenLiteSpeed, ensuring you can edit WordPress files without permission conflicts.

### 2. Root Directory
The WordPress application volume is mounted at the root `/srv` directory within Filebrowser.

## 🔐 Security Recommendations

> [!WARNING]
> Web-based file managers are high-security risks if not protected.

- **Immediate Password Change**: The default login for Filebrowser is `admin` / `admin`. Change this immediately upon first login.
- **HTTPS**: Always use a domain with SSL (HTTPS) when accessing Filebrowser.
- **Disable when not in use**: Set `COMPOSE_PROFILES=` (empty) and redeploy to stop the service when your maintenance task is finished.
- **IP Restriction**: Use Dokploy's advanced settings or a firewall to restrict access to your specific IP address.

---
*For more details on optional services, see [Optional Services](Optional-Services.md).*
