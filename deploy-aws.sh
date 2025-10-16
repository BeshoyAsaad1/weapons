#!/bin/bash
# Deploy script for AWS EC2

echo "============================================"
echo "Deploying to AWS EC2"
echo "============================================"
echo ""

# Navigate to project directory
cd /home/ec2-user/weapon-backend

# Check if directory exists
if [ ! -d "/home/ec2-user/weapon-backend" ]; then
    echo "ERROR: weapon-backend directory not found!"
    echo "Please clone the repository first:"
    echo "cd /home/ec2-user"
    echo "git clone https://github.com/BeshoyAsaad1/weapons.git weapon-backend"
    exit 1
fi

echo "Step 1: Pulling latest changes from GitHub..."
git pull origin main

echo ""
echo "Step 2: Stopping containers..."
docker-compose down -v

echo ""
echo "Step 3: Removing old images to save space..."
docker image prune -af

echo ""
echo "Step 4: Rebuilding and starting containers (this will take 3-5 minutes)..."
docker-compose up -d --build --force-recreate

echo ""
echo "Step 5: Waiting for containers to stabilize..."
sleep 30

echo ""
echo "Step 6: Checking container status..."
docker ps -a

echo ""
echo "============================================"
echo "Deployment Complete!"
echo "============================================"
echo ""
echo "Checking web container logs..."
docker logs weaponbackend_web --tail 50

echo ""
echo "If you see errors above, check the full logs with:"
echo "docker logs weaponbackend_web --tail 200"

