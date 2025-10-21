@echo off
echo ============================================
echo Git Pull and Deploy on EC2
echo ============================================

set EC2_HOST=ec2-user@3.74.228.219
set REMOTE_PATH=/home/ec2-user/weapon-backend
set SSH_KEY=C:\Users\besho\Weapons.pem

echo.
echo Step 1: Connecting to EC2 and checking current directory...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && pwd && ls -la"

echo.
echo Step 2: Pulling latest code from GitHub (origin main)...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && git pull origin main"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo WARNING: Git pull failed. This might be because it's not a git repository.
    echo Attempting to initialize git repository...
    ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && git init && git remote add origin https://github.com/BeshoyAsaad1/weapons.git && git fetch && git reset --hard origin/main"
)

echo.
echo Step 3: Stopping current containers...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && docker-compose -f docker-compose.prod.yml down"

echo.
echo Step 4: Removing old images to force rebuild...
ssh -i %SSH_KEY% %EC2_HOST% "docker system prune -f"

echo.
echo Step 5: Rebuilding and starting containers with new code...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && docker-compose -f docker-compose.prod.yml up -d --build --force-recreate"

echo.
echo Step 6: Waiting for containers to start (45 seconds)...
timeout /t 45 /nobreak

echo.
echo Step 7: Checking container status...
ssh -i %SSH_KEY% %EC2_HOST% "docker ps"

echo.
echo Step 8: Checking web container logs for errors...
ssh -i %SSH_KEY% %EC2_HOST% "docker logs weaponbackend_web_prod --tail 100"

echo.
echo Step 9: Checking nginx logs...
ssh -i %SSH_KEY% %EC2_HOST% "docker logs weaponbackend_nginx_prod --tail 50"

echo.
echo ============================================
echo Deployment Complete!
echo ============================================
echo.
echo If containers are running without errors, the site should be working now.
echo Check: http://3.74.228.219 or https://3.74.228.219
echo.

pause

