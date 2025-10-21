# Quick Reference Guide - Next Steps

## ✅ You've completed: chmod +x init-letsencrypt.sh

## 🎯 What to do next:

### Option A: Automated Full Setup (Recommended)

On your EC2 instance, run:

```bash
cd /home/ubuntu/weapons
chmod +x complete-ssl-setup.sh
./complete-ssl-setup.sh yourdomain.com your@email.com
```

This will:
1. Update nginx.conf with your domain
2. Stop existing containers
3. Obtain SSL certificates from Let's Encrypt
4. Start all services with HTTPS enabled

### Option B: Manual Step-by-Step

1. **Update nginx.conf manually:**
   ```bash
   nano nginx/nginx.conf
   # Replace DOMAIN_PLACEHOLDER with your actual domain (2 places)
   ```

2. **Run the Let's Encrypt setup:**
   ```bash
   DOMAIN=yourdomain.com EMAIL=your@email.com ./init-letsencrypt.sh
   ```

## 📋 Pre-flight Checklist

Before running either option, ensure:

- [ ] Your domain's DNS A record points to your EC2 public IP
- [ ] Port 80 is open in EC2 Security Group
- [ ] Port 443 is open in EC2 Security Group
- [ ] Docker and docker-compose are installed on EC2
- [ ] You've pulled the latest code: `git pull`

## 🔍 How to verify DNS is ready:

```bash
# On EC2 or your local machine:
nslookup yourdomain.com

# Should return your EC2 public IP
```

## ⚠️ Important Notes:

1. **First time only**: The script will create a temporary certificate, then replace it with a real Let's Encrypt certificate
2. **Rate limits**: Let's Encrypt allows 5 certificates per domain per week
3. **Staging mode**: If testing, edit `init-letsencrypt.sh` and set `staging=1`

## 🆘 If something goes wrong:

```bash
# Check nginx logs
docker-compose -f docker-compose.prod.yml logs nginx

# Check certbot logs
docker-compose -f docker-compose.prod.yml logs certbot

# Check if containers are running
docker-compose -f docker-compose.prod.yml ps

# Restart everything
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d
```

## 🎉 When successful, you'll see:

- ✅ SSL certificates obtained successfully!
- Your website is now secured with Let's Encrypt SSL
- Visit: https://yourdomain.com

## 📱 After Setup:

Your certificates will auto-renew every 12 hours. No manual intervention needed!

## 🔗 Useful Commands:

```bash
# Check certificate expiry
docker-compose -f docker-compose.prod.yml run --rm certbot certificates

# Force renewal
docker-compose -f docker-compose.prod.yml run --rm certbot renew --force-renewal

# Reload nginx after changes
docker-compose -f docker-compose.prod.yml exec nginx nginx -s reload
```

---

**Ready to proceed?** Run the command from Option A above! 🚀
#!/bin/bash

# Complete SSL Setup and Deployment Script for EC2
# This script handles the entire SSL certificate setup process

set -e  # Exit on any error

echo "============================================="
echo "SSL Setup and Deployment for EC2"
echo "============================================="
echo ""

# Check if domain and email are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./complete-ssl-setup.sh <domain> <email>"
    echo "Example: ./complete-ssl-setup.sh example.com admin@example.com"
    exit 1
fi

DOMAIN=$1
EMAIL=$2

echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo ""

# Step 1: Update nginx.conf with the actual domain
echo "Step 1: Updating nginx.conf with domain name..."
sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" nginx/nginx.conf
echo "✓ nginx.conf updated"
echo ""

# Step 2: Stop any running containers
echo "Step 2: Stopping existing containers..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
echo "✓ Containers stopped"
echo ""

# Step 3: Run the Let's Encrypt initialization script
echo "Step 3: Running Let's Encrypt certificate setup..."
DOMAIN=$DOMAIN EMAIL=$EMAIL ./init-letsencrypt.sh

if [ $? -eq 0 ]; then
    echo "✓ SSL certificates obtained successfully!"
    echo ""
    echo "============================================="
    echo "✅ SSL Setup Complete!"
    echo "============================================="
    echo ""
    echo "Your website is now secured with Let's Encrypt SSL"
    echo "Visit: https://$DOMAIN"
    echo ""
    echo "Certificate auto-renewal is configured to run every 12 hours"
else
    echo "❌ SSL certificate setup failed"
    echo "Please check the logs above for errors"
    exit 1
fi

