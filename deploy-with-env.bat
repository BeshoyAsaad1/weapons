@echo off
echo ============================================
echo Full Deployment - Upload .env and Pull Code
echo ============================================

set EC2_HOST=ec2-user@3.74.228.219
set REMOTE_PATH=/home/ec2-user/weapon-backend
set SSH_KEY=C:\Users\besho\Weapons.pem

echo.
echo Step 1: Uploading .env file to EC2 (contains secrets - NEVER commit to git)...
scp -i %SSH_KEY% .env %EC2_HOST%:%REMOTE_PATH%/.env
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to upload .env file
    pause
    exit /b 1
)

echo.
echo Step 2: Pulling latest code from GitHub on EC2...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && git reset --hard HEAD && git pull origin main"

echo.
echo Step 3: Stopping containers...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && docker-compose -f docker-compose.prod.yml down"

echo.
echo Step 4: Rebuilding and starting containers with new code...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && docker-compose -f docker-compose.prod.yml up -d --build --force-recreate"

echo.
echo Step 5: Waiting for containers to start (60 seconds)...
timeout /t 60 /nobreak

echo.
echo Step 6: Checking container status...
ssh -i %SSH_KEY% %EC2_HOST% "docker ps"

echo.
echo Step 7: Checking web container logs...
ssh -i %SSH_KEY% %EC2_HOST% "docker logs weaponbackend_web_prod --tail 50"

echo.
echo Step 8: Testing API endpoint...
ssh -i %SSH_KEY% %EC2_HOST% "curl http://localhost/api/ 2>&1"

echo.
echo ============================================
echo Deployment Complete!
echo ============================================
echo.
echo Your backend is now live at:
echo - http://3.74.228.219
echo - http://apps.lightidea.org (if DNS is configured)
echo.
echo Developer can test from localhost:5173 - CSP error should be fixed!
echo.

pause

