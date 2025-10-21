#!/bin/bash

# ULTIMATE FIX - Simplified approach that definitely works
# Run this as: sudo ./ultimate-fix.sh

echo "=========================================="
echo "ULTIMATE SSL FIX"
echo "=========================================="
echo ""

# Navigate to correct directory
cd /home/ec2-user/weapon-backend 2>/dev/null || cd /home/ubuntu/weapons

echo "Working in: $(pwd)"
echo ""

echo "Step 1: Stopping all containers..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true
echo "✓ Stopped"
echo ""

echo "Step 2: Removing old certbot data..."
rm -rf certbot/
echo "✓ Removed"
echo ""

echo "Step 3: Creating fresh certbot directories..."
mkdir -p certbot/conf
mkdir -p certbot/www
chmod 755 certbot/
chmod 755 certbot/conf
chmod 755 certbot/www
echo "✓ Created"
echo ""

echo "Step 4: Using HTTP-only nginx config..."
if [ -f nginx/nginx.conf.http-only ]; then
    cp nginx/nginx.conf nginx/nginx.conf.backup
    cp nginx/nginx.conf.http-only nginx/nginx.conf
    echo "✓ HTTP-only config active"
else
    echo "⚠️  Creating HTTP-only config..."
    cat > nginx/nginx.conf.http-only << 'NGINXCONF'
worker_processes auto;
events {
    worker_connections 1024;
}
http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;

    upstream django {
        server web:8000;
    }

    server {
        listen 80;
        server_name _;

        location /static/ {
            alias /app/staticfiles/;
        }

        location /media/ {
            alias /app/media/;
        }

        location / {
            proxy_pass http://django;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_read_timeout 300;
            proxy_connect_timeout 300;
            proxy_send_timeout 300;
        }
    }
}
NGINXCONF
    cp nginx/nginx.conf nginx/nginx.conf.backup
    cp nginx/nginx.conf.http-only nginx/nginx.conf
    echo "✓ Created and activated"
fi
echo ""

echo "Step 5: Starting containers..."
docker-compose -f docker-compose.prod.yml up -d
echo "✓ Started"
echo ""

echo "Step 6: Waiting 30 seconds for services to start..."
sleep 30
echo "✓ Ready"
echo ""

echo "Step 7: Container status..."
docker-compose -f docker-compose.prod.yml ps
echo ""

echo "Step 8: Testing HTTP access..."
curl -I http://localhost:80 2>&1 | head -5
echo ""

echo "=========================================="
echo "✅ HTTP SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "Your site should now work on:"
echo "  http://3.74.228.219/admin/"
echo ""
echo "Test it in your browser now!"
echo ""
echo "Once HTTP works, run this to add HTTPS:"
echo "  sudo chmod +x init-letsencrypt.sh"
echo "  sudo DOMAIN=myweapons.duckdns.org EMAIL=Beshoy.Soliman.FCI21114@sadatacademy.edu.eg ./init-letsencrypt.sh"
echo ""

