# Let's Encrypt SSL Setup Guide for EC2

## Prerequisites

1. **Domain Name**: You need a domain pointing to your EC2 instance's public IP
2. **EC2 Security Group**: Ensure ports 80 and 443 are open
3. **DNS Setup**: Create an A record pointing your domain to your EC2 public IP

## Setup Steps

### Step 1: Update Your Domain in nginx.conf

Replace `DOMAIN_PLACEHOLDER` in `nginx/nginx.conf` with your actual domain name:

```bash
# Change this line:
ssl_certificate /etc/letsencrypt/live/DOMAIN_PLACEHOLDER/fullchain.pem;

# To (example):
ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
```

Do the same for the `ssl_certificate_key` line.

### Step 2: Deploy Files to EC2

Push your changes to GitHub and pull on EC2:

```bash
# On your local machine
git add .
git commit -m "Add Let's Encrypt SSL support"
git push

# On EC2
cd /home/ubuntu/weapons
git pull
```

Or use your existing deploy script.

### Step 3: Run the SSL Setup Script

On your EC2 instance, run:

```bash
cd /home/ubuntu/weapons
chmod +x init-letsencrypt.sh
DOMAIN=yourdomain.com EMAIL=your@email.com ./init-letsencrypt.sh
```

Replace:
- `yourdomain.com` with your actual domain
- `your@email.com` with your email address

### Step 4: Verify SSL Certificate

After the script completes:

1. Visit `https://yourdomain.com` in your browser
2. Check that the certificate is valid (green padlock)
3. Certificate should be issued by "Let's Encrypt Authority"

## Automatic Certificate Renewal

The Certbot container automatically renews certificates every 12 hours. No manual intervention needed!

## Troubleshooting

### Issue: "Failed authorization procedure"

**Solution**: 
- Verify your domain's DNS A record points to your EC2 public IP
- Ensure port 80 is accessible (Security Group)
- Wait a few minutes for DNS propagation

### Issue: "Connection refused"

**Solution**:
- Check if nginx is running: `docker-compose -f docker-compose.prod.yml ps`
- Check nginx logs: `docker-compose -f docker-compose.prod.yml logs nginx`

### Issue: Rate limit exceeded

**Solution**:
- Let's Encrypt has rate limits (5 certificates per domain per week)
- For testing, set `staging=1` in `init-letsencrypt.sh`
- Wait a week if you hit the limit

### Testing Mode

To test the setup without hitting rate limits:

1. Edit `init-letsencrypt.sh`
2. Change `staging=0` to `staging=1`
3. Run the script
4. Once verified, change back to `staging=0` and re-run

## Manual Certificate Renewal

If needed, manually renew certificates:

```bash
docker-compose -f docker-compose.prod.yml run --rm certbot renew
docker-compose -f docker-compose.prod.yml exec nginx nginx -s reload
```

## Checking Certificate Expiry

```bash
docker-compose -f docker-compose.prod.yml run --rm certbot certificates
```

## Using with Multiple Domains

Edit the `domains` array in `init-letsencrypt.sh`:

```bash
domains=(yourdomain.com www.yourdomain.com)
```

## Important Notes

1. **First Time Setup**: The script creates a dummy certificate first, then replaces it with a real one
2. **DNS Must Be Ready**: Your domain MUST point to your EC2 IP before running the script
3. **Backup Certificates**: The certificates are stored in `./certbot/conf` directory
4. **Port 80 Required**: Let's Encrypt needs port 80 for validation, don't block it

## Quick Command Reference

```bash
# Start all services
docker-compose -f docker-compose.prod.yml up -d

# Stop all services
docker-compose -f docker-compose.prod.yml down

# View logs
docker-compose -f docker-compose.prod.yml logs -f nginx
docker-compose -f docker-compose.prod.yml logs -f certbot

# Restart nginx
docker-compose -f docker-compose.prod.yml restart nginx

# Force certificate renewal
docker-compose -f docker-compose.prod.yml run --rm certbot renew --force-renewal
```
#!/bin/bash

# Let's Encrypt SSL Certificate Setup Script for EC2
# This script initializes SSL certificates using Certbot

if [ -z "$DOMAIN" ]; then
    echo "Error: DOMAIN environment variable not set"
    echo "Usage: DOMAIN=yourdomain.com EMAIL=your@email.com ./init-letsencrypt.sh"
    exit 1
fi

if [ -z "$EMAIL" ]; then
    echo "Error: EMAIL environment variable not set"
    echo "Usage: DOMAIN=yourdomain.com EMAIL=your@email.com ./init-letsencrypt.sh"
    exit 1
fi

domains=($DOMAIN)
rsa_key_size=4096
data_path="./certbot"
staging=0 # Set to 1 if you're testing your setup to avoid hitting request limits

echo "### Preparing directories ..."
mkdir -p "$data_path/conf"
mkdir -p "$data_path/www"

echo "### Downloading recommended TLS parameters ..."
curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"

echo "### Creating dummy certificate for $domains ..."
path="/etc/letsencrypt/live/$domains"
mkdir -p "$data_path/conf/live/$domains"
docker-compose -f docker-compose.prod.yml run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
    -keyout '$path/privkey.pem' \
    -out '$path/fullchain.pem' \
    -subj '/CN=localhost'" certbot
echo

echo "### Starting nginx ..."
docker-compose -f docker-compose.prod.yml up --force-recreate -d nginx
echo

echo "### Deleting dummy certificate for $domains ..."
docker-compose -f docker-compose.prod.yml run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$domains && \
  rm -Rf /etc/letsencrypt/archive/$domains && \
  rm -Rf /etc/letsencrypt/renewal/$domains.conf" certbot
echo

echo "### Requesting Let's Encrypt certificate for $domains ..."
# Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$EMAIL" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $EMAIL" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

docker-compose -f docker-compose.prod.yml run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
echo

echo "### Reloading nginx ..."
docker-compose -f docker-compose.prod.yml exec nginx nginx -s reload

