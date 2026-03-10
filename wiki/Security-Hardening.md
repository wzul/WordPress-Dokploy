# Security Hardening Guide

Protecting your server and your WordPress site is a top priority. This stack includes several built-in security features.

## 🛡️ File Manager Protection

To prevent brute-force attacks on your file manager, we use a **Secret URL Path** strategy.

### 1. Secret Path
Instead of the default `/file-manager/`, you can set a secret path that only you know.
- **Variable**: `FILE_MANAGER_PATH` in Dokploy.
- **Example**: `/manage-wp-hidden-789/`
- **Result**: Bots trying to find a login page at `/file-manager/` will get a `404 Not Found`.

## 🔒 OpenLiteSpeed Admin Protection
The OLS Admin panel (port `7080`) is not exposed to the internet by default in our `docker-compose.yml`.
- **Recommendation**: Map it to a hidden subdomain (e.g., `ols-admin.yourdomain.com`) inside the Dokploy Domains tab.
- **Brute Force**: OLS has built-in protection that bans IPs after multiple failed logins.

## 🗃️ Database Security
- **No Public Port**: The MySQL/MariaDB database is NOT exposed to the internet. It only listens on the internal Docker network.
- **Credential Isolation**: Each project uses its own database user and password, isolated from other projects on the same server.

## ✉️ SMTP Security
The **Mail Relay** sidecar only allows connections from within the internal Docker network (`mynetworks` is restricted). It is not possible for an external attacker to use your server as an open relay to send spam.

## 🚀 Recommended External Security
If you want the highest level of protection, we highly recommend using **Cloudflare** as your DNS provider:
- **WAF (Web Application Firewall)**: Blocks known bot signatures.
- **Bot Fight Mode**: Challenges suspicious automated traffic.
- **Edge Protection**: See our [Advanced Cloudflare Integration](Advanced-Cloudflare-Integration.md) guide to lockdown your server so it ONLY accepts traffic from Cloudflare IPs.
