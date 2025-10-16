#!/bin/bash
# Debug deployment script

echo "============================================"
echo "Debugging Docker Compose Issues"
echo "============================================"
echo ""

cd /home/ec2-user/weapon-backend

echo "Step 1: Checking Docker Compose file..."
if [ -f "docker-compose.yml" ]; then
    echo "✅ docker-compose.yml found"
else
    echo "❌ docker-compose.yml NOT found"
    exit 1
fi

echo ""
echo "Step 2: Checking .env file..."
if [ -f ".env" ]; then
    echo "✅ .env file found"
else
    echo "❌ .env file NOT found - creating template..."
    cat > .env << 'EOF'
# Azure AD Configuration
AZURE_TENANT_ID=61032d68-6ef9-4d5f-9b9e-46c6556b6f47
AZURE_CLIENT_ID=91ce101f-58e6-4d4c-8f0b-599b713c3101

# Django Configuration
DEBUG=False
SECRET_KEY='6hyk-x9f#r!16lez2i+ek+@!x(4!k6x9y-$^1h69_@y9ropte_'
ALLOWED_HOST=apps.lightidea.org,3.74.228.219

# Encryption Configuration
SURVEYS_ENCRYPTION_KEY=1j1J0jFbbvDfZ23EcNYsf10zq6872EM1nA8IdU5C8nA=

# Database (Oracle for production)
USE_ORACLE=True
ORACLE_USERNAME=timesheet
ORACLE_PASSWORD=KgJyrx3$1
ORACLE_HOST=185.197.251.203
ORACLE_PORT=1521
ORACLE_SERVICE=PROD

# CORS Settings
CORS_ALLOWED_ORIGINS=https://apps.lightidea.org,http://localhost:5173,https://127.0.0.1:5173,http://127.0.0.1:5173
CORS_ALLOW_ALL_ORIGINS=False
CORS_ALLOW_CREDENTIALS=True

# Cache Settings
CACHE_TTL=300

# Security Settings
SESSION_COOKIE_SECURE=True
CSRF_COOKIE_SECURE=True
SECURE_SSL_REDIRECT=True
SECURE_HSTS_SECONDS=31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS=True
SECURE_HSTS_PRELOAD=True
SECURE_CONTENT_TYPE_NOSNIFF=True
SECURE_BROWSER_XSS_FILTER=True
SECURE_REFERRER_POLICY=strict-origin-when-cross-origin

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# Notification Settings
NOTIFICATION_CLEANUP_DAYS=30
NOTIFICATION_MAX_PER_USER=1000

# Logging
LOG_LEVEL=INFO
EOF
    echo "✅ .env file created"
fi

echo ""
echo "Step 3: Validating docker-compose.yml..."
docker-compose config > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ docker-compose.yml is valid"
else
    echo "❌ docker-compose.yml has errors:"
    docker-compose config
    exit 1
fi

echo ""
echo "Step 4: Stopping any existing containers..."
docker-compose down -v

echo ""
echo "Step 5: Building and starting containers with verbose output..."
docker-compose up -d --build --force-recreate

echo ""
echo "Step 6: Waiting for containers to start..."
sleep 10

echo ""
echo "Step 7: Container status..."
docker-compose ps

echo ""
echo "Step 8: Checking logs for each service..."
echo ""
echo "=== WEB CONTAINER LOGS ==="
docker-compose logs web --tail 100

echo ""
echo "=== NGINX CONTAINER LOGS ==="
docker-compose logs nginx --tail 50

echo ""
echo "=== REDIS CONTAINER LOGS ==="
docker-compose logs redis --tail 50

