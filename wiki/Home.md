# Welcome to the WordPress-Dokploy Wiki

This repository provides a high-performance, production-ready WordPress stack optimized for **Dokploy**.

## 🏗️ Architecture Overview

The system consists of four primary services orchestrated via Docker Compose:

1.  **WordPress (FPM)**: A specialized PHP-FPM container with `msmtp` installed for global mail support.
2.  **OpenLiteSpeed (OLS)**: A high-performance web server acting as the ingress and PHP handler.
3.  **Mail Relay**: A Postfix sidecar that handles SMTP queueing and background delivery.
4.  **Database**: (External or linked service) The MySQL/MariaDB backend.

## 🚀 Quick Links

- [**Deployment Guide**](Deployment.md): Step-by-step instructions for Dokploy.
- [**SMTP & Email Setup**](SMTP-and-Email.md): Learn about the zero-plugin email system and SES tagging.
- [**OpenLiteSpeed Management**](OpenLiteSpeed.md): Accessing the admin panel and tuning OLS.
- [**Customizing PHP**](PHP-Configuration.md): How to adjust memory limits, upload sizes, and more.
- [**File Manager**](File-Manager.md): Managing your files via the web interface.
- [**Database Management**](Database-Management.md): Securely managing your MySQL/MariaDB with Adminer + WP Auth.
- [**Security Hardening**](Security-Hardening.md): Best practices for protecting your site.

## 🛠️ Key Features

- **Zero-Plugin SMTP**: Emails just work out of the box.
- **Background Email Queue**: PHP doesn't wait for SMTP handshakes.
- **AWS SES Support**: Automatic tenant tagging via custom headers.
- **Premium Performance**: Powered by OpenLiteSpeed and optimized Opcache.
