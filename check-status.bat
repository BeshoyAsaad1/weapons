@echo off
echo ============================================
echo Checking EC2 Deployment Status
echo ============================================

set EC2_HOST=ec2-user@3.74.228.219
set SSH_KEY=C:\Users\besho\Weapons.pem

echo.
echo Step 1: Checking all container status...
ssh -i %SSH_KEY% %EC2_HOST% "docker ps -a"

echo.
echo Step 2: Checking nginx logs...
ssh -i %SSH_KEY% %EC2_HOST% "docker logs weaponbackend_nginx_prod --tail 30"

echo.
echo Step 3: Checking web container logs...
ssh -i %SSH_KEY% %EC2_HOST% "docker logs weaponbackend_web_prod --tail 30"

echo.
echo Step 4: Testing HTTP access...
ssh -i %SSH_KEY% %EC2_HOST% "curl -I http://localhost 2>&1 | head -20"

echo.
echo Step 5: Testing API endpoint...
ssh -i %SSH_KEY% %EC2_HOST% "curl http://localhost/api/ 2>&1 | head -5"

echo.
echo ============================================
echo Status Check Complete
echo ============================================
echo.
echo If all containers are running without errors:
echo - Access your site at: http://3.74.228.219
echo - Your developer can test from localhost:5173
echo.

pause

