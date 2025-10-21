#!/bin/bash

# Simple deployment script for testing
# This updates nginx.conf and starts services

echo "============================================="
echo "Quick Deploy Script"
echo "============================================="

if [ -z "$1" ]; then
    echo "Usage: ./quick-deploy.sh <domain>"
    echo "Example: ./quick-deploy.sh myweapons.duckdns.org"
    exit 1
fi

DOMAIN=$1

echo "Updating nginx.conf with domain: $DOMAIN"
sed -i.bak "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" nginx/nginx.conf

echo "Stopping containers..."
docker-compose -f docker-compose.prod.yml down

echo "Starting containers..."
docker-compose -f docker-compose.prod.yml up -d

echo "Checking container status..."
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "✅ Deployment complete!"
echo "Check logs with: docker-compose -f docker-compose.prod.yml logs -f"

