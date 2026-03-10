# Advanced Cloudflare Integration

For the highest level of security, you can configure your Dokploy server to **only** allow traffic that originates from Cloudflare. This prevents attackers from bypassing Cloudflare's WAF and DDoS protection by connecting directly to your server's IP address.

> [!IMPORTANT]
> This setup requires SSH access to your server and modification of the global Traefik configuration in Dokploy.

## 1. Dynamic Filter Configuration

> [!TIP]
> **Use Your Hosting Provider's Firewall First!**
> This dynamic Traefik filter is only required if you are using a VPS provider that **does not** support blocking access outside of the VPS (e.g., **Contabo**). 
> 
> If you are using a provider that has a robust external firewall panel (e.g., **AWS EC2 Security Groups**, **IPServerOne**, DigitalOcean Cloud Firewalls), you should use their panel to block non-Cloudflare IPs instead of setting it up inside Traefik. It is more secure and consumes zero server resources!

Since Dokploy does not allow creating new dynamic configuration files from the UI, you must create this file manually via SSH.


### Step-by-Step SSH Instructions:
1. Connect to your server:
   ```bash
   ssh root@your-server-ip
   ```
2. Create the directory (if it doesn't exist):
   ```bash
   mkdir -p /etc/dokploy/traefik/dynamic
   ```
3. Create and edit the filter file:
   ```bash
   nano /etc/dokploy/traefik/dynamic/cloudflare-filter.yml
   ```
4. Paste the following configuration:

```yaml
http:
  middlewares:
    only-cloudflare:
      ipAllowList:
        sourceRange:
          # IPv4
          - 173.245.48.0/20
          - 103.21.244.0/22
          - 103.22.200.0/22
          - 103.31.4.0/22
          - 141.101.64.0/18
          - 108.162.192.0/18
          - 190.93.240.0/20
          - 188.114.96.0/20
          - 197.234.240.0/22
          - 198.41.128.0/17
          - 162.158.0.0/15
          - 104.16.0.0/13
          - 104.24.0.0/14
          - 172.64.0.0/13
          - 131.0.72.0/22
          # IPv6
          - 2400:cb00::/32
          - 2606:4700::/32
          - 2803:f800::/32
          - 2405:b500::/32
          - 2405:8100::/32
          - 2a06:98c0::/29
          - 2c0f:f248::/32
```

5. Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).

---

## 2. Global Traefik Configuration (`traefik.yml`)

Log in to your **Dokploy Dashboard**, navigate to **Settings > Traefik**, and find the **Static Configuration** (`traefik.yml`). Update the `entryPoints` section as follows:

```yaml
entryPoints:
  web:
    address: :80
  websecure:
    forwardedHeaders:
      # Trust all IPs for headers because we will filter at the middleware layer
      trustedIPs:
        - "0.0.0.0/0"
        - "::/0"
    address: :443
    http3:
      advertisedPort: 443
    http:
      middlewares:
        # Apply the Cloudflare filter globally to all HTTPS traffic
        - only-cloudflare@file
      tls:
        certResolver: letsencrypt
```

### Why these settings?
*   **trustedIPs**: We set this to broad ranges because we are offloading the IP filtering to a specialized middleware.
*   **middlewares**: By adding `only-cloudflare@file` to the `websecure` entrypoint, **every** application on your server will automatically benefit from the Cloudflare-only protection.

---

## 3. Apply Changes
After creating the file and updating `traefik.yml`, Dokploy should automatically reload the configuration. If it doesn't, you can restart Traefik from the Dokploy dashboard.

## 4. Real IP Restoration in WordPress

The stack is pre-configured to automatically recognize the Cloudflare real IP. This is handled by a **Must-Use (MU) Plugin** created during container startup (`php/docker-entrypoint-extra.sh`).

The following logic is automatically injected:

```php
/**
 * Handle Cloudflare Real IP
 */
if (isset($_SERVER['HTTP_CF_CONNECTING_IP'])) {
    $_SERVER['REMOTE_ADDR'] = $_SERVER['HTTP_CF_CONNECTING_IP'];
}
```

This ensures that:
*   **Security Plugins** (e.g., Wordfence, Solid Security) see the actual visitor.
*   **WordPress Logs** show the correct IP.
*   **Comment Moderation** works as intended.

---

### 🛡️ What this achieves:
*   **Port 80/443 Lockdown**: Any request that does not come from a verified Cloudflare IP range will be rejected with a `403 Forbidden` error.
*   **WAF Enforcement**: Forces all visitors to go through Cloudflare, ensuring they are scanned by Cloudflare's WAF and Bot protection.
*   **Real IP Consistency**: Ensures WordPress and PHP always report the true visitor IP instead of the proxy IP.
