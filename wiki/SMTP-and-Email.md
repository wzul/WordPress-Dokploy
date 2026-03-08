# SMTP and Email Configuration

The email system in this stack is designed for **maximum reliability** and **zero configuration** within the WordPress dashboard.

## 🌉 The Relay Strategy
We use a **Sidecar Pattern**. 
1. The **WordPress** container handles the PHP logic.
2. The **Mail-Relay** container (Postfix) handles the networking and queuing.

### Benefits:
- **No Blocking**: When PHP sends an email, it hands it off to the relay container over the internal Docker network. This takes milliseconds.
- **Retries**: If your SMTP provider (like AWS SES) is temporarily down, Postfix will keep the email in its local queue and retry automatically.

## 🏷️ AWS SES Tenant Tagging
The stack is pre-configured to support **AWS SES Tenant Tagging**. 
By setting the `SES_TENANT_TAG` environment variable in Dokploy, every email will automatically include the following header:
`X-SES-TENANT: your-value`

This allows you to track email usage per customer or environment within the AWS SES console.

## ⚙️ Zero-Plugin Setup
You do **not** need to install plugins like WP Mail SMTP. 
- Standalone PHP scripts using `mail()` use the container's internal `msmtp` client.
- WordPress uses the internal Docker network to talk directly to `mail-relay:25`.

## 🛠️ Testing
To test if email is working, you can shell into the wordpress container and run:
```bash
echo "Test message" | mail -s "Test Subject" recipient@example.com
```
Check the `mail-relay` logs in Dokploy to see the delivery status.
