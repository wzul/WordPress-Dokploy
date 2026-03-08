# Dokploy Deployment Template

To turn this repository into a reusable Dokploy Template, you need to create a `template.toml` file. This tells Dokploy how to handle variables and domains when someone clicks "Deploy".

## 1. Create `template.toml`

Create this file in your root directory. It defines the UI for Dokploy when setting up the project.

```toml
[variables]
# These variables will appear in the Dokploy UI
WORDPRESS_MEMORY_LIMIT = "256M"
DB_NAME = "wordpress"
DB_USER = "wordpress"
# Generated random password
DB_PASSWORD = "${email}" 

[[config.domains]]
name = "wordpress"
port = 9000
# host = "${domain}" # Dokploy helper

[[config.env]]
serviceName = "wordpress"
name = "WORDPRESS_MEMORY_LIMIT"
value = "${WORDPRESS_MEMORY_LIMIT}"

[[config.env]]
serviceName = "wordpress"
name = "DB_NAME"
value = "${DB_NAME}"

[[config.env]]
serviceName = "wordpress"
name = "DB_USER"
value = "${DB_USER}"

[[config.env]]
serviceName = "wordpress"
name = "DB_PASSWORD"
value = "${DB_PASSWORD}"

[[config.mounts]]
serviceName = "wordpress"
source = "./php/uploads.ini"
content = "/usr/local/etc/php/conf.d/uploads.ini"

[[config.mounts]]
serviceName = "wordpress"
source = "./php/opcache.ini"
content = "/usr/local/etc/php/conf.d/opcache.ini"

[[config.mounts]]
serviceName = "wordpress"
source = "./php/z-dokploy-overrides.ini"
content = "/usr/local/etc/php/conf.d/z-dokploy-overrides.ini"

[[config.mounts]]
serviceName = "wordpress"
source = "./php/fpm-pool.conf"
content = "/usr/local/etc/php-fpm.d/zz-dokploy.conf"
```

## 2. Updated `docker-compose.yml` for Templates

When using a template, Dokploy manages the network and volumes. Your `docker-compose.yml` should stay clean:

1.  **Environment Variables**: Keep them as `${VARIABLE_NAME}`. Dokploy will inject them from the `template.toml` or the project settings.
2.  **No `container_name`**: Let Dokploy handle naming.
3.  **Ports**: Usually omitted as Dokploy uses its internal proxy.

## 3. Deployment Flow

1.  **Push to Git**: Ensure `docker-compose.yml`, `template.toml`, and the `php/` folder are committed.
2.  **In Dokploy Dashboard**:
    - Go to **Templates** -> **Custom Templates**.
    - Click **Create Template**.
    - Provide the Git URL of this repository.
    - Dokploy will read `template.toml` and prompt you for the variables (Memory limit, DB name, etc.).
3.  **Launch**: Once confirmed, Dokploy orchestrates the volumes and services automatically.
