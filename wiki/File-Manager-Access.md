# File Manager Access (Reference)

For advanced file management beyond standard SFTP/SSH, you can deploy a **Filebrowser** container to interact with your WordPress persistent volumes directly through a web interface.

> [!IMPORTANT]
> This documentation is for **reference purposes only**. Implementing a web-based file manager introduces security considerations. Ensure you use strong credentials and, ideally, place it behind a VPN or IP-restricted firewall.

## 🏗️ Configuration Template

The following `docker-compose.yml` snippet can be used as a starting point to deploy Filebrowser alongside your Dokploy services.

```yaml
services:
  filebrowser:
    image: hurlenko/filebrowser:latest
    container_name: filebrowser
    environment:
      - FB_BASEURL=/filebrowser
      - PUID=33  # Run as www-data to match WordPress permissions
      - PGID=33
    ports:
      - "8080:80"
    volumes:
      # 1. Internal Filebrowser data (users, settings, etc.)
      - filebrowser-data:/data/main 
      
      # 2. Filebrowser Configuration
      - filebrowser-config:/config 
      
      # 3. WordPress Application Volume (Mounted as a sub-folder)
      # Replace <wordpress_volume_name> with your actual Docker volume name
      - <wordpress_volume_name>:/data/wordpress
    restart: unless-stopped

volumes:
  filebrowser-data:
  filebrowser-config:
  # Reference existing WordPress volumes
  <wordpress_volume_name>:
    external: true
```

## ⚙️ Key Configuration Details

### 1. Permissions (`PUID`/`PGID`)
The `PUID=33` and `PGID=33` environment variables ensure that Filebrowser operates as the `www-data` user. This is critical for maintaining compatibility with WordPress file permissions, allowing you to upload and modify files without causing "Permission Denied" errors in the WordPress dashboard.

### 2. Base URL & Port
- **`FB_BASEURL=/filebrowser`**: This hosts Filebrowser on the `/filebrowser` sub-path.
- **Port 8080**: The container is mapped to port `8080`. You should point your domain or reverse proxy to this port.

### 3. External Volumes
By setting `external: true` for your WordPress volume, you tell Docker to use the existing volume created by your WordPress service rather than creating a new one.

To find your actual volume name, you can run:
```bash
docker volume ls | grep wp_app
```

## 🔐 Security Recommendations

- **Authentication**: Filebrowser has built-in authentication. Change the default password immediately after the first login.
- **Reverse Proxy**: Use a reverse proxy (like Nginx or Traefik) to enable HTTPS.
- **IP Restriction**: If possible, restrict access to the Filebrowser port/URL to known IP addresses only.
