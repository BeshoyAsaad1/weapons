#!/bin/bash

# EMERGENCY FIX - Start containers without SSL first
# This will get your site working on HTTP, then we can add SSL

echo "=========================================="
echo "Emergency Fix - Starting Without SSL"
echo "=========================================="
echo ""

# Navigate to correct directory
if [ -d "/home/ubuntu/weapons" ]; then
    cd /home/ubuntu/weapons
elif [ -d "/home/ec2-user/weapon-backend" ]; then
    cd /home/ec2-user/weapon-backend
else
    echo "Error: Cannot find project directory"
    exit 1
fi

echo "Current directory: $(pwd)"
echo ""

# Stop all containers
echo "Step 1: Stopping all containers..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
docker stop $(docker ps -aq) 2>/dev/null || true
echo "✓ Stopped"
echo ""

# Check if .env file exists
echo "Step 2: Checking .env file..."
if [ ! -f .env ]; then
    echo "⚠️  Warning: .env file not found!"
    echo "Creating basic .env file..."
    cat > .env << 'EOF'
DEBUG=False
SECRET_KEY=your-secret-key-here
ALLOWED_HOSTS=*
DATABASE_URL=sqlite:///db.sqlite3
EOF
fi
echo "✓ .env file exists"
echo ""

# Start containers
echo "Step 3: Starting containers..."
docker-compose -f docker-compose.prod.yml up -d
echo "✓ Containers started"
echo ""

# Wait for services to be ready
echo "Step 4: Waiting for services to start (30 seconds)..."
sleep 30
echo "✓ Wait complete"
echo ""

# Check status
echo "Step 5: Checking container status..."
docker-compose -f docker-compose.prod.yml ps
echo ""

# Check ports
echo "Step 6: Checking if ports are listening..."
sudo netstat -tlnp | grep -E ':80 |:443 '
echo ""

# Test local connection
echo "Step 7: Testing local connection..."
curl -I http://localhost:80
echo ""

echo "=========================================="
echo "Emergency Fix Complete!"
echo "=========================================="
echo ""
echo "Try these URLs in your browser:"
echo "1. HTTP (no SSL):  http://3.74.228.219/admin/"
echo "2. HTTPS:          https://myweapons.duckdns.org/admin/"
echo ""
echo "If HTTP works but HTTPS doesn't, we need to set up SSL certificates."
echo ""
#!/bin/bash

# Emergency Diagnostic Script
# Run this to see what's going on with your server

echo "=========================================="
echo "Emergency Diagnostic Check"
echo "=========================================="
echo ""

echo "1. Current Directory:"
pwd
echo ""

echo "2. Checking if Docker is installed:"
docker --version
docker-compose --version
echo ""

echo "3. Checking Docker containers status:"
docker ps -a
echo ""

echo "4. Checking with docker-compose:"
cd /home/ubuntu/weapons 2>/dev/null || cd /home/ec2-user/weapon-backend 2>/dev/null || cd ~
docker-compose -f docker-compose.prod.yml ps
echo ""

echo "5. Checking if ports 80 and 443 are listening:"
sudo netstat -tlnp | grep -E ':80 |:443 '
echo ""

echo "6. Checking nginx logs (last 20 lines):"
docker-compose -f docker-compose.prod.yml logs --tail=20 nginx 2>/dev/null || echo "Nginx not running"
echo ""

echo "7. Checking web container logs (last 20 lines):"
docker-compose -f docker-compose.prod.yml logs --tail=20 web 2>/dev/null || echo "Web container not running"
echo ""

echo "8. Checking if certbot directory exists:"
ls -la certbot/ 2>/dev/null || echo "Certbot directory doesn't exist"
echo ""

echo "9. Testing local HTTP connection:"
curl -I http://localhost:80 2>&1 | head -5
echo ""

echo "10. Checking nginx.conf for domain:"
grep "myweapons.duckdns.org" nginx/nginx.conf 2>/dev/null || echo "Domain not found in nginx.conf"
echo ""

echo "=========================================="
echo "Diagnostic Complete"
echo "=========================================="

