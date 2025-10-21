#!/bin/bash

# Complete Self-Signed HTTPS Fix
# Run this with: sudo ./setup-self-signed-https.sh

echo "=========================================="
echo "Self-Signed HTTPS Setup"
echo "=========================================="
echo ""

# Navigate to project directory
cd /home/ec2-user/weapon-backend 2>/dev/null || cd /home/ubuntu/weapons

echo "Working directory: $(pwd)"
echo ""

echo "Step 1: Stopping all containers..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
docker stop $(docker ps -aq) 2>/dev/null || true
echo "✓ Stopped"
echo ""

echo "Step 2: Cleaning up old SSL files..."
rm -rf certbot/
rm -rf nginx/ssl/
echo "✓ Cleaned"
echo ""

echo "Step 3: Creating SSL directory..."
mkdir -p nginx/ssl
chmod 755 nginx/ssl
echo "✓ Created"
echo ""

echo "Step 4: Generating self-signed certificate..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/nginx-selfsigned.key \
  -out nginx/ssl/nginx-selfsigned.crt \
  -subj "/C=US/ST=State/L=City/O=WeaponPowerCloud/CN=3.74.228.219"

if [ $? -eq 0 ]; then
    echo "✓ Certificate generated"
    ls -lh nginx/ssl/
else
    echo "❌ Failed to generate certificate"
    exit 1
fi
echo ""

echo "Step 5: Setting correct permissions..."
chmod 644 nginx/ssl/nginx-selfsigned.crt
chmod 600 nginx/ssl/nginx-selfsigned.key
echo "✓ Permissions set"
echo ""

echo "Step 6: Verifying nginx configuration..."
if grep -q "nginx-selfsigned.crt" nginx/nginx.conf; then
    echo "✓ Nginx config looks good"
else
    echo "⚠️  Nginx config may need updating"
fi
echo ""

echo "Step 7: Starting containers..."
docker-compose -f docker-compose.prod.yml up -d
echo "✓ Started"
echo ""

echo "Step 8: Waiting for services to start (30 seconds)..."
sleep 30
echo "✓ Ready"
echo ""

echo "Step 9: Container status..."
docker-compose -f docker-compose.prod.yml ps
echo ""

echo "Step 10: Checking nginx specifically..."
NGINX_STATUS=$(docker ps --filter "name=nginx" --format "{{.Status}}")
echo "Nginx status: $NGINX_STATUS"
echo ""

if echo "$NGINX_STATUS" | grep -q "Up"; then
    echo "✅ Nginx is running!"
elif echo "$NGINX_STATUS" | grep -q "Restarting"; then
    echo "❌ Nginx is crashing! Checking logs..."
    docker logs weaponbackend_nginx_prod --tail 30
else
    echo "❌ Nginx is not running!"
fi
echo ""

echo "Step 11: Testing local connection..."
curl -I -k https://localhost:443 2>&1 | head -10
echo ""

echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "Access your site at:"
echo "  https://3.74.228.219/admin/"
echo ""
echo "⚠️  You will see a browser security warning - this is normal!"
echo "    Click 'Advanced' then 'Proceed to site'"
echo ""
echo "If it still doesn't work, check:"
echo "  - EC2 Security Group has port 443 open"
echo "  - Run: sudo docker logs weaponbackend_nginx_prod"
echo ""

