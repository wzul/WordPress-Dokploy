# WordPress Fail2Ban (Cloudflare-Aware)

A traditional Fail2Ban installation on the server often fails to block attackers correctly when behind Cloudflare. Instead, we use a "Cloudflare-Native" approach that blocks attackers at the **Cloudflare Edge** using the official API.

## 1. Prerequisites
*   **Cloudflare Account**: You must be using Cloudflare for your DNS/Proxy.
*   **Real IP Restored**: Ensure you have implemented the "Real IP Restoration" in our [Advanced Cloudflare Integration](Advanced-Cloudflare-Integration.md) guide.

## 2. Installation
1.  Log in to your WordPress Dashboard.
2.  Install the plugin: **Limit Login Attempts Reloaded**.
3.  Activate it.

## 3. Connecting to Cloudflare (The "Fail2Ban" Logic)
This is the most important part. It allows WordPress to "tell" Cloudflare to block an attacker.

### Step 3.1: Get Cloudflare API Key
1.  Go to your [Cloudflare Profile > API Tokens](https://dash.cloudflare.com/profile/api-tokens).
2.  Click **Create Token**.
3.  Use the **"Edit Zone DNS"** template OR create a custom token with:
    *   **Zone - Firewall Services - Edit**
    *   **Zone - Zone - Read**
4.  Copy your generated Token.

### Step 3.2: Configure the Plugin
1.  In WordPress, go to **Settings > Limit Login Attempts**.
2.  Go to the **Cloudflare** tab.
3.  Enter your **Cloudflare Email** and your **API Token**.
4.  Enter your **Zone ID** (found on your Cloudflare Domain Overview page).
5.  Check **"Synchronize with Cloudflare"**.

## 4. How it works
*   **The Trigger**: A bot tries to guess your password 5 times.
*   **The Detection**: The plugin detects the failures.
*   **The "Ban"**: Instead of just blocking them in PHP, the plugin calls the Cloudflare API.
*   **The Result**: Cloudflare adds the attacker's IP to its **WAF Block List**. The attacker is now blocked from your entire server, and their requests never even reach your Dokploy instance!

## 5. Security Settings Recommendation
Inside the plugin settings, we recommend:
*   **Lockout**: 5 retries.
*   **Lockout duration**: 24 hours (86400 seconds).
*   **Increase lockout**: 4 lockouts = 1 week ban.

---

### 🛡️ Why not use Fail2Ban on the host?
If you use Fail2Ban on the server host:
1.  It would block the IP in your local `iptables`.
2.  But the attacker is still hitting Cloudflare.
3.  Cloudflare will keep tryting to connect to your server, which is technically "noise" on your network.
4.  **Application-level Fail2Ban + Cloudflare API** is the professional way to handle this on modern PaaS like Dokploy.
