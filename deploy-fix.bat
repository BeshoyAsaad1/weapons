@echo off
echo ============================================
echo Deploying fixes to AWS EC2...
echo ============================================

set EC2_HOST=ec2-user@3.74.228.219
set REMOTE_PATH=/home/ec2-user/weapon-backend
set SSH_KEY=C:\Users\besho\Weapons.pem

echo.
echo Step 1: Uploading .env file...
scp -i %SSH_KEY% .env %EC2_HOST%:%REMOTE_PATH%/.env
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to upload .env file
    pause
    exit /b 1
)

echo.
echo Step 2: Uploading Dockerfile.prod...
scp -i %SSH_KEY% Dockerfile.prod %EC2_HOST%:%REMOTE_PATH%/Dockerfile.prod
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to upload Dockerfile.prod
    pause
    exit /b 1
)

echo.
echo Step 3: Uploading nginx configuration...
scp -i %SSH_KEY% nginx\nginx.conf %EC2_HOST%:%REMOTE_PATH%/nginx/nginx.conf
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to upload nginx config
    pause
    exit /b 1
)

echo.
echo Step 4: Uploading settings.py...
scp -i %SSH_KEY% weaponpowercloud_backend\settings.py %EC2_HOST%:%REMOTE_PATH%/weaponpowercloud_backend/settings.py
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to upload settings.py
    pause
    exit /b 1
)

echo.
echo Step 5: Uploading admin.py...
scp -i %SSH_KEY% authentication\admin.py %EC2_HOST%:%REMOTE_PATH%/authentication/admin.py
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to upload admin.py
    pause
    exit /b 1
)

echo.
echo Step 6: Stopping and removing old containers...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && docker-compose -f docker-compose.prod.yml down"

echo.
echo Step 7: Rebuilding and starting containers...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && docker-compose -f docker-compose.prod.yml up -d --build"

echo.
echo Step 8: Waiting for containers to start...
timeout /t 15 /nobreak

echo.
echo Step 9: Checking container status...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && docker-compose -f docker-compose.prod.yml ps"

echo.
echo Step 10: Checking web container logs...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && docker-compose -f docker-compose.prod.yml logs --tail=50 web"

echo.
echo ============================================
echo Deployment Complete!
echo ============================================
echo.
echo The application should now be accessible at:
echo   - http://3.74.228.219
echo   - http://apps.lightidea.org
echo.
echo Developer frontend at localhost:5173 should be able to connect.
echo.
echo If there are still issues, check logs with:
echo   ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && docker-compose -f docker-compose.prod.yml logs --tail=100"
echo.
pause
