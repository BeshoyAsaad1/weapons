# AWS EC2 Setup and Deployment Guide

## Initial Setup on AWS EC2 (One-time only)

### 1. Connect to your EC2 instance
```bash
ssh ec2-user@3.74.228.219
```

### 2. Install Git (if not already installed)
```bash
sudo yum install git -y
```

### 3. Clone your repository
```bash
cd /home/ec2-user
git clone https://github.com/BeshoyAsaad1/weapons.git weapon-backend
cd weapon-backend
```

### 4. Create .env file on the server
```bash
nano .env
```

Paste your environment variables and save (Ctrl+X, then Y, then Enter).

### 5. Install Docker and Docker Compose (if not already installed)
```bash
# Install Docker
sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Log out and log back in for group changes to take effect
exit
```

---

## Deployment Process (Every time you update code)

### On Your Local Machine (Windows):
```cmd
cd C:\Users\besho\IdeaProjects\weapons
git add .
git commit -m "Your commit message"
git push origin main
```

### On AWS EC2 Server:
```bash
cd /home/ec2-user/weapon-backend

# Pull latest changes
git pull origin main

# Stop and remove all containers
docker-compose down -v

# Remove old images (optional, saves space)
docker image prune -af

# Rebuild and start containers
docker-compose up -d --build --force-recreate

# Wait for containers to start (important for Oracle Client installation)
echo "Waiting for containers to build and start..."
sleep 30

# Check container status
docker ps -a

# View logs
docker logs weaponbackend_web --tail 100
docker logs weaponbackend_nginx --tail 50
```

---

## Troubleshooting Commands

### Check if containers are running
```bash
docker ps -a
```

### View web container logs
```bash
docker logs weaponbackend_web --tail 100
docker logs weaponbackend_web -f  # Follow logs in real-time
```

### View nginx logs
```bash
docker logs weaponbackend_nginx --tail 50
```

### Access container shell for debugging
```bash
docker exec -it weaponbackend_web /bin/bash
```

### Check Redis connection
```bash
docker exec -it weaponbackend_redis redis-cli ping
```

### Restart specific container
```bash
docker restart weaponbackend_web
```

### Complete cleanup (nuclear option)
```bash
docker-compose down -v
docker system prune -af --volumes
docker-compose up -d --build --force-recreate
```

---

## Quick Deploy Script for AWS

Create this file on your EC2 server for easy deployment:

```bash
nano ~/deploy.sh
```

Paste this content:
```bash
#!/bin/bash
cd /home/ec2-user/weapon-backend
echo "Pulling latest changes..."
git pull origin main
echo "Stopping containers..."
docker-compose down -v
echo "Rebuilding and starting containers..."
docker-compose up -d --build --force-recreate
echo "Waiting for containers to stabilize..."
sleep 30
echo "Container status:"
docker ps -a
echo ""
echo "Web container logs:"
docker logs weaponbackend_web --tail 50
```

Make it executable:
```bash
chmod +x ~/deploy.sh
```

Now you can deploy with just:
```bash
~/deploy.sh
```

---

## Current Issues Fixed:
1. ✅ Django Admin AlreadyRegistered error - Fixed by unregistering User model before re-registering
2. ✅ Oracle Instant Client missing - Added to Dockerfile
3. ✅ Redis connection - Configured to use Docker service name

## Next Steps:
1. Ensure the weapon-backend directory exists on AWS: `/home/ec2-user/weapon-backend`
2. If it doesn't exist, follow the "Initial Setup" section above
3. Once setup is complete, use the deployment commands to deploy your fixes

