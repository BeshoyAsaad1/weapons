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
sed -i.bak "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" nginx/nginx.conf
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

