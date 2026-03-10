# Welcome to the WordPress-Dokploy Wiki

This repository provides a high-performance, production-ready WordPress stack optimized for **Dokploy**.

## 🏗️ Architecture Overview

The system consists of three primary services orchestrated via Docker Compose:

1.  **WordPress (Unified)**: A high-performance container that bundles **OpenLiteSpeed** and **WordPress (PHP 8.4)** together.
2.  **Mail Relay**: A Postfix sidecar that handles SMTP queueing and background delivery.
3.  **Valkey**: A high-performance object cache (Redis fork) to drastically speed up WordPress.

## 🚀 Quick Links

- [**Deployment Guide**](Deployment.md): Step-by-step instructions for Dokploy.
- [**SMTP & Email Setup**](SMTP-and-Email.md): Learn about the zero-plugin email system and SES tagging.
- [**OpenLiteSpeed Management**](OpenLiteSpeed.md): Accessing the admin panel and tuning OLS.
- [**Customizing PHP**](PHP-Configuration.md): How to adjust memory limits, upload sizes, and more.
- [**Security Hardening**](Security-Hardening.md): Best practices for protecting your site.
- [**Advanced Cloudflare Setup**](Advanced-Cloudflare-Integration.md): Lockdown your server to ONLY allow Cloudflare traffic.
- [**Fail2Ban (IP Blocking)**](Fail2Ban-Setup.md): Prevent brute-force by blocking IPs at the Cloudflare edge.
- [**Cron & Scheduled Tasks**](Cron-Management.md): How WordPress cron is handled by the Dokploy Scheduler.
- [**Performance Testing**](Performance-Testing.md): How to audit your site speed using sitespeed.io.

## 🛠️ Key Features

- **Zero-Plugin SMTP**: Emails just work out of the box.
- **Background Email Queue**: PHP doesn't wait for SMTP handshakes.
- **AWS SES Support**: Automatic tenant tagging via custom headers.
- **Premium Performance**: Powered by OpenLiteSpeed and optimized Opcache.
