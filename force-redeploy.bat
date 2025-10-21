@echo off
echo ============================================
echo Force Git Pull and Full Redeploy on EC2
echo ============================================

set EC2_HOST=ec2-user@3.74.228.219
set REMOTE_PATH=/home/ec2-user/weapon-backend
set SSH_KEY=C:\Users\besho\Weapons.pem

echo.
echo Step 1: Stopping all containers first...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && docker-compose -f docker-compose.prod.yml down"

echo.
echo Step 2: Discarding local changes and force pulling from GitHub...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && git reset --hard HEAD && git clean -fd && git pull origin main"

echo.
echo Step 3: Verifying settings.py has the CSP fix...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && grep -n 'localhost:5173' weaponpowercloud_backend/settings.py | head -5"

echo.
echo Step 4: Removing all Docker images and cache...
ssh -i %SSH_KEY% %EC2_HOST% "docker system prune -af --volumes"

echo.
echo Step 5: Rebuilding and starting containers with fresh code...
ssh -i %SSH_KEY% %EC2_HOST% "cd %REMOTE_PATH% && docker-compose -f docker-compose.prod.yml build --no-cache && docker-compose -f docker-compose.prod.yml up -d"

echo.
echo Step 6: Waiting for containers to fully start (60 seconds)...
timeout /t 60 /nobreak

echo.
echo Step 7: Checking container status...
ssh -i %SSH_KEY% %EC2_HOST% "docker ps"

echo.
echo Step 8: Checking web container logs...
ssh -i %SSH_KEY% %EC2_HOST% "docker logs weaponbackend_web_prod --tail 100 2>&1"

echo.
echo Step 9: Testing if the site is responding...
ssh -i %SSH_KEY% %EC2_HOST% "curl -I http://localhost:8000/api/ 2>&1 | head -10"

echo.
echo ============================================
echo Deployment Complete!
echo ============================================
echo.
echo Check the logs above for any errors.
echo If no errors, test from:
echo - http://3.74.228.219
echo - https://3.74.228.219
echo.
echo The CSP fix should now be active!
echo.

pause

