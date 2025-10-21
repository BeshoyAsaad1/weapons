# Self-Signed HTTPS Setup Guide

## Quick Setup on EC2

Follow these simple steps to get HTTPS working with self-signed certificates:

### Step 1: Pull Latest Code

```bash
cd /home/ec2-user/weapon-backend
git pull
```

### Step 2: Stop Everything

```bash
sudo docker-compose -f docker-compose.prod.yml down
sudo rm -rf certbot/
```

### Step 3: Generate Self-Signed Certificate

```bash
sudo mkdir -p nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/nginx-selfsigned.key \
  -out nginx/ssl/nginx-selfsigned.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=3.74.228.219"
```

### Step 4: Start Containers

```bash
sudo docker-compose -f docker-compose.prod.yml up -d
```

### Step 5: Check Status

```bash
sudo docker ps
```

All containers should show "Up" status.

### Step 6: Access Your Site

Open in browser:
```
https://3.74.228.219/admin/
```

## Expected Browser Behavior

You'll see a security warning because it's a self-signed certificate. This is normal!

**To proceed:**
1. Click "Advanced"
2. Click "Proceed to 3.74.228.219 (unsafe)" or "Accept the Risk and Continue"
3. You'll see the Django admin login page

## Why Self-Signed?

- ✅ Works immediately with IP addresses
- ✅ No domain name needed
- ✅ No external dependencies (DuckDNS, Let's Encrypt)
- ✅ Perfect for testing and development
- ⚠️ Browser will show security warning (expected)

## For Production

For a production site without browser warnings, you need:
1. A real domain name (not an IP address)
2. SSL certificate from a trusted authority (Let's Encrypt, Cloudflare, etc.)

But for testing, self-signed HTTPS works perfectly!

---

## All Commands in One Block

```bash
cd /home/ec2-user/weapon-backend
git pull
sudo docker-compose -f docker-compose.prod.yml down
sudo rm -rf certbot/
sudo mkdir -p nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/nginx-selfsigned.key \
  -out nginx/ssl/nginx-selfsigned.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=3.74.228.219"
sudo docker-compose -f docker-compose.prod.yml up -d
```

Wait 30 seconds, then visit: `https://3.74.228.219/admin/`

**Done!** 🎉

