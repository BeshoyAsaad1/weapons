@echo off
echo ============================================
echo Pulling latest code and deploying on AWS EC2...
echo ============================================

set EC2_HOST=ec2-user@3.74.228.219
set REMOTE_PATH=/home/ec2-user/weapon-backend
set SSH_KEY=C:\Users\besho\Weapons.pem

echo.
echo Step 1: Connecting to EC2 and pulling latest code from GitHub...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && git pull origin main"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to pull code from GitHub
    pause
    exit /b 1
)

echo.
echo Step 2: Stopping current containers...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && docker-compose -f docker-compose.prod.yml down"

echo.
echo Step 3: Rebuilding and starting containers...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && docker-compose -f docker-compose.prod.yml up -d --build"

echo.
echo Step 4: Checking container status...
ssh -i %SSH_KEY% %EC2_HOST% "docker ps"

echo.
echo ============================================
echo Deployment Complete!
echo ============================================

echo.
echo Checking web container logs...
ssh -i %SSH_KEY% %EC2_HOST% "docker logs weaponbackend_web_prod --tail 50"

echo.
echo If you see errors above, check the full logs with:
echo docker logs weaponbackend_web_prod --tail 200

pause

