#!/bin/bash

# Simple Let's Encrypt SSL Setup for DuckDNS
# Usage: sudo ./init-letsencrypt.sh

DOMAIN="myweapons.duckdns.org"
EMAIL="Beshoy.Soliman.FCI21114@sadatacademy.edu.eg"

echo "============================================"
echo "Let's Encrypt SSL Certificate Setup"
echo "============================================"
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo ""

# Create directories
echo "Creating directories..."
mkdir -p certbot/conf
mkdir -p certbot/www
chmod 755 certbot/ -R

# Download recommended TLS parameters
echo "Downloading TLS parameters..."
curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > certbot/conf/options-ssl-nginx.conf
curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > certbot/conf/ssl-dhparams.pem

# Request certificate
echo ""
echo "Requesting SSL certificate from Let's Encrypt..."
echo "This may take 1-2 minutes..."
echo ""

docker run --rm \
  -v "$(pwd)/certbot/conf:/etc/letsencrypt" \
  -v "$(pwd)/certbot/www:/var/www/certbot" \
  certbot/certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email $EMAIL \
  --agree-tos \
  --no-eff-email \
  --force-renewal \
  -d $DOMAIN

if [ $? -eq 0 ]; then
    echo ""
    echo "============================================"
    echo "✅ SSL Certificate Obtained Successfully!"
    echo "============================================"
    echo ""
    echo "Certificate files are in: certbot/conf/live/$DOMAIN/"
    echo ""
    echo "Next steps:"
    echo "1. Update nginx.conf to use the certificates"
    echo "2. Restart nginx: sudo docker-compose -f docker-compose.prod.yml restart nginx"
    echo "3. Visit: https://$DOMAIN/admin/"
else
    echo ""
    echo "❌ Failed to obtain SSL certificate"
    echo "Please check:"
    echo "- DNS is correctly pointing to your server"
    echo "- Port 80 is accessible from the internet"
    echo "- Domain name is correct"
fi

