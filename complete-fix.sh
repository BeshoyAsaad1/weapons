#!/bin/bash

# COMPLETE FIX - Get the site working with HTTPS
# This script fixes all common issues

set -e

echo "=========================================="
echo "COMPLETE SSL SETUP AND FIX"
echo "=========================================="
echo ""

# Find the correct directory
if [ -d "/home/ubuntu/weapons" ]; then
    cd /home/ubuntu/weapons
elif [ -d "/home/ec2-user/weapon-backend" ]; then
    cd /home/ec2-user/weapon-backend
else
    echo "Error: Cannot find project directory"
    exit 1
fi

echo "Working directory: $(pwd)"
echo ""

# Step 1: Stop everything
echo "Step 1: Stopping all containers..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true
echo "✓ All containers stopped and removed"
echo ""

# Step 2: Create necessary directories
echo "Step 2: Creating certificate directories..."
mkdir -p certbot/conf/live
mkdir -p certbot/www
echo "✓ Directories created"
echo ""

# Step 3: Temporarily use HTTP-only config
echo "Step 3: Setting up temporary HTTP-only nginx config..."
if [ -f nginx/nginx.conf.http-only ]; then
    cp nginx/nginx.conf nginx/nginx.conf.ssl-original
    cp nginx/nginx.conf.http-only nginx/nginx.conf
    echo "✓ Using HTTP-only config"
else
    echo "⚠️  HTTP-only config not found, will try with current config"
fi
echo ""

# Step 4: Start containers
echo "Step 4: Starting containers..."
docker-compose -f docker-compose.prod.yml up -d
echo "✓ Containers started"
echo ""

# Step 5: Wait for services
echo "Step 5: Waiting for services to be ready (20 seconds)..."
sleep 20
echo ""

# Step 6: Check container status
echo "Step 6: Checking container status..."
docker-compose -f docker-compose.prod.yml ps
echo ""

# Step 7: Check if nginx is healthy
NGINX_STATUS=$(docker ps --filter "name=nginx" --format "{{.Status}}")
echo "Nginx status: $NGINX_STATUS"
echo ""

if echo "$NGINX_STATUS" | grep -q "Restarting"; then
    echo "❌ Nginx is still crashing!"
    echo "Checking nginx logs:"
    docker logs weaponbackend_nginx_prod --tail 20
    echo ""
    echo "This is likely because SSL certificates are missing."
    echo "Let's set them up now..."

    # Restore original SSL config and run Let's Encrypt
    if [ -f nginx/nginx.conf.ssl-original ]; then
        cp nginx/nginx.conf.ssl-original nginx/nginx.conf
    fi

    # Run Let's Encrypt setup
    echo ""
    echo "Step 8: Running Let's Encrypt certificate setup..."
    chmod +x init-letsencrypt.sh
    DOMAIN=myweapons.duckdns.org EMAIL=Beshoy.Soliman.FCI21114@sadatacademy.edu.eg ./init-letsencrypt.sh

    echo ""
    echo "Step 9: Restarting all containers with SSL..."
    docker-compose -f docker-compose.prod.yml down
    docker-compose -f docker-compose.prod.yml up -d
    sleep 10
else
    echo "✓ Nginx is running!"
fi

echo ""
echo "Step 10: Final container status check..."
docker-compose -f docker-compose.prod.yml ps
echo ""

echo "Step 11: Checking if ports are listening..."
sudo netstat -tlnp | grep -E ':80 |:443 ' || echo "Ports not listening yet"
echo ""

echo "Step 12: Testing local connection..."
curl -I http://localhost:80 2>&1 | head -10 || echo "Local connection failed"
echo ""

echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Try accessing:"
echo "HTTP:  http://3.74.228.219/admin/"
echo "HTTPS: https://myweapons.duckdns.org/admin/"
echo ""
echo "If it still doesn't work, check logs with:"
echo "docker-compose -f docker-compose.prod.yml logs nginx"
echo "docker-compose -f docker-compose.prod.yml logs web"

