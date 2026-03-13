# Optional Services & Tools

This project includes optional services that are disabled by default to save server resources (RAM/CPU). You can enable them as needed using **Docker Compose Profiles**.

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

## 🚀 Future Options
If this project adds more tools (e.g., File Managers or Redis GUIs), they will also be assigned to profiles. You can enable multiple tools by separating them with a comma:

```env
COMPOSE_PROFILES=tools,debug,monitoring
```
