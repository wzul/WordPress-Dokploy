# Deployment Guide

This setup is designed specifically for **Dokploy** using the "Compose" service type.

## 1. Prerequisites
- A Dokploy instance installed.
- Your project files pushed to a Git repository.

## 2. Deployment Steps

### In your Git Provider:
1. Ensure your `env` is NOT committed (use `env.example` as a template).

### In Dokploy:
1. Create a new **Project**.
2. Click **Add Service** -> **Compose**.
3. Point to your Git repository URL.
4. **General Configuration**:
   - Set **Compose Path** to `docker-compose.dokploy.yml`.
5. **Environment Configuration (CRITICAL)**:
   > [!IMPORTANT]
   > Dokploy current cannot successfully inject host-level environment variables for the "Compose" service type. To manage your secrets:
   - Go to the **Patches** tab of your service.
   - Click "Add Patch" or create a new entry manually named exactly **`env`** (without the dot).
   - Paste your configuration variables (e.g., `OLS_PASSWORD=...`) into this file/patch.
   - The `docker-compose.dokploy.yml` is configured to read from this file natively.
6. **Domain Mapping**:
   - Go to the **Domains** tab.
   - **Main Site**: Add your domain (e.g., `mysite.com`) and point it to service **`wordpress`** on port **80**.
   - **OLS Admin (Optional)**: Add a subdomain (e.g., `ols.mysite.com`) and point it to service **`wordpress`** on port **7080**.
7. **Deploy**: Click the **Deploy** button.

## 💻 Local Testing
To test the stack on your local machine before deploying:
1. Copy `env.patch` provided in this repo.
2. Run `docker-compose up -d`.
3. Open `http://localhost:8080` for the WordPress site.
4. Open `https://localhost:7080` for the OpenLiteSpeed Admin console.

## 🔑 Environment Variables

| Variable | Description | Default |
| :--- | :--- | :--- |
| `OLS_PASSWORD` | Admin password for OpenLiteSpeed | `admin123` |
| `SMTP_SERVER` | SMTP Relay Host (e.g. Amazon SES) | (Required) |
| `SMTP_USERNAME` | SMTP Auth Username | (Required) |
| `SMTP_PASSWORD` | SMTP Auth Password | (Required) |
| `OVERWRITE_FROM`| Soft Email Overwrite (Required) | `(None)` |
| `SERVER_HOSTNAME` | Your site domain (for Postfix EHLO) | `localhost` |
| `SES_TENANT_TAG` | AWS SES Tenant ID for tagging | `default` |

## 📁 Managing Volumes
The system uses named volumes to ensure your data persists across redeployments:
- `wp_app`: Persistent WordPress files (`/var/www/html`).
