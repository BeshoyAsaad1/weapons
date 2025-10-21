@echo off
echo ============================================
echo Deploying Django Admin Fix to AWS
echo ============================================
echo.

echo Step 1: Committing changes to git...
git add authentication/admin.py .env
git commit -m "Fix: Django admin AlreadyRegistered error and Redis host configuration for Docker"
git push origin main

echo.
echo Step 2: SSH commands to run on AWS EC2...
echo.
echo Copy and run these commands on your EC2 instance:
echo.
echo ----------------------------------------
echo # Navigate to project directory
echo cd /home/ec2-user/weapon-backend
echo.
echo # Pull latest changes
echo git pull origin main
echo.
echo # Stop and remove all containers
echo docker-compose down -v
echo.
echo # Remove any orphaned containers and volumes
echo docker container prune -f
echo docker volume prune -f
echo.
echo # Rebuild and start services
echo docker-compose up -d --build --force-recreate
echo.
echo # Wait 10 seconds for containers to stabilize
echo sleep 10
echo.
echo # Check container status
echo docker ps -a
echo.
echo # View web container logs
echo docker logs weaponbackend_web --tail 100
echo.
echo # If still having issues, check nginx logs
echo docker logs weaponbackend_nginx --tail 50
echo ----------------------------------------
echo.
echo Deployment script completed!
pause
