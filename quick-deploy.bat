@echo off
echo ============================================
echo Quick Deploy Fix to AWS
echo ============================================

git add authentication/admin.py
git commit -m "Fix: Unregister User model before re-registering in admin"
git push origin main

echo.
echo ============================================
echo NOW RUN THESE COMMANDS ON YOUR EC2 SERVER:
echo ============================================
echo.
echo cd /home/ec2-user/weapon-backend
echo git pull origin main
echo docker-compose down
echo docker-compose up -d --build --force-recreate
echo docker logs weaponbackend_web --tail 100
echo.
pause

