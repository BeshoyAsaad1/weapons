@echo off
REM Quick deployment script for EC2 with SSL setup

echo ============================================
echo Deploy to EC2 with SSL Setup
echo ============================================
echo.

REM Check if .env file exists
if not exist ".env" (
    echo Error: .env file not found!
    echo Please create .env file with your configuration
    pause
    exit /b 1
)

echo Step 1: Committing changes to Git...
git add .
git commit -m "SSL setup with Let's Encrypt" 2>nul
git push origin main

echo.
echo Step 2: Deploying to EC2...
echo.

set /p EC2_IP=Enter your EC2 public IP:
set /p DOMAIN=Enter your domain name (e.g., example.com):
set /p EMAIL=Enter your email for SSL notifications:
set /p KEY_FILE=Enter path to your .pem key file:

echo.
echo Connecting to EC2 at %EC2_IP%...
echo.

REM Create the deployment command
set "DEPLOY_CMD=cd /home/ubuntu/weapons && git pull && chmod +x complete-ssl-setup.sh init-letsencrypt.sh && ./complete-ssl-setup.sh %DOMAIN% %EMAIL%"

REM Execute on EC2
ssh -i "%KEY_FILE%" ubuntu@%EC2_IP% "%DEPLOY_CMD%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo ✅ Deployment Successful!
    echo ============================================
    echo.
    echo Your site is now live at: https://%DOMAIN%
    echo.
) else (
    echo.
    echo ❌ Deployment failed! Check the logs above.
    echo.
)

pause

