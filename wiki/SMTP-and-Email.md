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

## 🔄 Soft Email Override
The `OVERWRITE_FROM` environment variable in the `mail-relay` service is configured with a **"Soft Override"** logic:
- **Fallback**: If an email is sent from a local address (e.g., `wordpress@localhost` or `nobody@localhost`), it will be automatically replaced with the `OVERWRITE_FROM` value to ensure it's accepted by your SMTP provider.
- **Flexibility**: If a WordPress plugin sets a valid, external `From` address (e.g., `support@yourdomain.com`), the relay will **not** overwrite it. This allows you to use different sender addresses for different site functions.

## ⚙️ Zero-Plugin Setup
You do **not** need to install plugins like WP Mail SMTP. 
- Standalone PHP scripts using `mail()` use the container's internal `msmtp` client.
- WordPress uses the internal Docker network to talk directly to `mail-relay:25`.

## 🛠️ Testing
To test if email is working, you can shell into the wordpress container and run:
```bash
echo "Test message" | mail -s "Test Subject" recipient@example.com
```

## 🔍 Monitoring & Troubleshooting via CLI

While you can see logs in the Dokploy dashboard, you can also use the CLI for more detailed inspection:

### 1. View Real-time Delivery Logs
Use `docker logs` to see every handoff and SMTP response:
```bash
# Replace with your actual container name/ID
docker logs -f wordpress-dokploy-mail-relay-1
```
**What to look for:**
- `status=sent`: The email was successfully accepted by your SMTP relay.
- `status=deferred`: The relay is retrying (common during SES rate-limiting).
- `status=bounced`: The recipient address is invalid or the relay rejected it.

### 2. Inspect the Mail Queue
If emails aren't arriving, check if they are stuck in the local queue:
```bash
docker exec wordpress-dokploy-mail-relay-1 postqueue -p
```
*If this returns "Mail queue is empty", it means the email was already handed off or failed completely.*

### 3. Flush the Queue
To force a manual retry of all pending emails:
```bash
docker exec wordpress-dokploy-mail-relay-1 postqueue -f
```

### 4. Clear the Queue (Emergency)
To delete all pending emails from the queue:
```bash
docker exec wordpress-dokploy-mail-relay-1 postsuper -d ALL
```
