# Optional Services & Tools

This project includes optional services that are disabled by default to save server resources (RAM/CPU). You can enable them as needed using **Docker Compose Profiles**.

## 🧭 Port Mapping Cheat Sheet (Dokploy)

When adding a **Domain** or **Port** mapping in the Dokploy UI, use these **Internal Ports**:

| Service | Profile | Internal Port | Local URL |
| :--- | :--- | :--- | :--- |
| **WordPress** | (Always On) | `80` | `localhost:8080` |
| **OLS Admin** | (Always On) | `7080` | `localhost:7080` |
| **phpMyAdmin** | `tools` | `80` | `localhost:8081` |
| **Filebrowser** | `tools` | `80` | `localhost:8082` |
| **Dozzle** | `debug` | `8080` | `localhost:8083` |
| **Mailpit** | `mailpit` | `8025` | `localhost:8025` |

---

## 🛠️ phpMyAdmin

**phpMyAdmin** is a web-based database management tool. It is currently configured under the `tools` profile.

### How to Enable in Dokploy

1.  Log in to your **Dokploy** panel.
2.  Navigate to your **Project -> Environment Variables**.
3.  Add or update the following variable:
    ```env
    COMPOSE_PROFILES=tools
    ```
4.  **Save** and **Deploy** the project.
5.  **Accessing phpMyAdmin**: 
    - You must add a **Domain** or **Port** to the `phpmyadmin` service in the Dokploy UI to access it via your browser.
    - If testing locally, it is available at `http://localhost:8081`.

### Security Note
> [!WARNING]
> Web-based database tools are common targets for hackers.
> - **Disable when not in use**: Set `COMPOSE_PROFILES=` (empty) and redeploy to stop the service.
> - **Use Strong Passwords**: Ensure your `MYSQL_ROOT_PASSWORD` is complex.
> - **IP Whitelisting**: If possible, restrict access to `phpmyadmin` via your firewall or proxy.

## 📂 Filebrowser

**Filebrowser** is a web-based file management tool. It is also configured under the `tools` profile.

### How to Enable in Dokploy

1.  Follow the same steps as above for `COMPOSE_PROFILES=tools`.
2.  **Accessing Filebrowser**:
    - Add a **Domain** or **Port** to the `filebrowser` service in Dokploy.
    - If testing locally, it is available at `http://localhost:8082`.
    - **Default Login**: `admin` / `admin` (Change immediately!)

### Security Note
> [!WARNING]
> Web-based file managers provide full access to your application code.
> - **Disable immediately** after use.
> - Use a long, complex password.
> - **IP Restricted**: Best used behind a VPN or IP-restricted access.

## 🔍 Dozzle (Log Viewer)

**Dozzle** provides a real-time web interface for viewing container logs. It is configured under the `debug` profile.

### How to Enable in Dokploy

1.  Set `COMPOSE_PROFILES=debug` (or `tools,debug`).
2.  **Accessing Dozzle**:
    - Add a **Domain** or **Port** to the `dozzle` service in Dokploy.
    - If testing locally, it is available at `http://localhost:8083`.

## 📧 Mailpit (Email Catcher)

**Mailpit** catches outgoing emails for testing purposes. It is configured under the `mailpit` profile and is **enabled by default**.

### How to Manage in Dokploy

1.  **Enabled by default**: `COMPOSE_PROFILES=mailpit` is set in the base configuration.
2.  **Accessing Mailpit**:
    - Add a **Domain** or **Port** to the `mailpit` service in Dokploy.
    - If testing locally, it is available at `http://localhost:8025`.

## 🚀 Active Profiles

You can enable multiple categories by separating them with a comma:

```env
# Example: Enable Mailpit + Tools
COMPOSE_PROFILES=mailpit,tools

# Example: Enable everything
COMPOSE_PROFILES=mailpit,tools,debug
```
