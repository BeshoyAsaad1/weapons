@echo off
echo ============================================
echo Full Deployment to AWS EC2...
echo ============================================

set EC2_HOST=ec2-user@3.74.228.219
set REMOTE_PATH=/home/ec2-user/weapon-backend
set SSH_KEY=C:\Users\besho\Weapons.pem

echo.
echo Step 1: Uploading updated settings.py with CSP fix...
scp -i %SSH_KEY% weaponpowercloud_backend\settings.py %EC2_HOST%:%REMOTE_PATH%/weaponpowercloud_backend/settings.py
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to upload settings.py
    pause
    exit /b 1
)

echo.
echo Step 2: Stopping current containers...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && docker-compose -f docker-compose.prod.yml down"

echo.
echo Step 3: Rebuilding and starting containers with new settings...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && docker-compose -f docker-compose.prod.yml up -d --build"

echo.
echo Step 4: Waiting for containers to start (30 seconds)...
timeout /t 30 /nobreak

echo.
echo Step 5: Checking container status...
ssh -i %SSH_KEY% %EC2_HOST% "docker ps"

echo.
echo Step 6: Checking web container logs...
ssh -i %SSH_KEY% %EC2_HOST% "docker logs weaponbackend_web_prod --tail 100"

echo.
echo ============================================
echo Deployment Complete!
echo ============================================
echo.
echo The CSP fix has been deployed.
echo Your developer at localhost:5173 should now be able to connect without CSP blocking errors.
echo.

pause

