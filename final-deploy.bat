@echo off
echo ============================================
echo Complete Deployment with Full .env File
echo ============================================

set EC2_HOST=ec2-user@3.74.228.219
set REMOTE_PATH=/home/ec2-user/weapon-backend
set SSH_KEY=C:\Users\besho\Weapons.pem

echo.
echo Step 1: Uploading complete .env file...
scp -i %SSH_KEY% .env %EC2_HOST%:%REMOTE_PATH%/.env
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to upload .env file
    pause
    exit /b 1
)

echo.
echo Step 2: Verifying .env file on server...
ssh -i %SSH_KEY% %EC2_HOST% "wc -l %REMOTE_PATH%/.env && grep -c AZURE_TENANT_ID %REMOTE_PATH%/.env && grep -c CORS_ALLOWED_ORIGINS %REMOTE_PATH%/.env && grep -c SECURE_SSL_REDIRECT %REMOTE_PATH%/.env"

echo.
echo Step 3: Stopping all containers...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && docker-compose -f docker-compose.prod.yml down"

echo.
echo Step 4: Starting containers with new .env...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && docker-compose -f docker-compose.prod.yml up -d"

echo.
echo Step 5: Waiting for startup (60 seconds)...
timeout /t 60 /nobreak

echo.
echo Step 6: Checking container status...
ssh -i %SSH_KEY% %EC2_HOST% "docker ps --format 'table {{.Names}}\t{{.Status}}'"

echo.
echo Step 7: Testing API endpoint...
ssh -i %SSH_KEY% %EC2_HOST% "curl -s http://localhost/api/"

echo.
echo Step 8: Checking web container logs...
ssh -i %SSH_KEY% %EC2_HOST% "docker logs weaponbackend_web_prod --tail 50"

echo.
echo ============================================
echo Deployment Complete!
echo ============================================
echo.
echo Your backend should now be accessible at:
echo - http://3.74.228.219/api/
echo - http://apps.lightidea.org (if DNS configured)
echo.
echo Developer can test from localhost:5173 without CSP errors!
echo.

pause

