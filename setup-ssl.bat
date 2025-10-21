@echo off
REM Setup SSL certificates with Let's Encrypt on EC2

echo ====================================
echo Setup Let's Encrypt SSL Certificates
echo ====================================
echo.

set /p DOMAIN=Enter your domain name (e.g., example.com):
set /p EMAIL=Enter your email for SSL notifications:

if "%DOMAIN%"=="" (
    echo Error: Domain is required
    exit /b 1
)

if "%EMAIL%"=="" (
    echo Error: Email is required
    exit /b 1
)

echo.
echo Connecting to EC2 and setting up SSL...
echo.

REM Create the command to run on EC2
set "CMD=cd /home/ubuntu/weapons && DOMAIN=%DOMAIN% EMAIL=%EMAIL% bash init-letsencrypt.sh"

REM SSH into EC2 and run the setup script
ssh -i "your-key.pem" ubuntu@your-ec2-ip "%CMD%"

echo.
echo SSL setup complete!
echo Don't forget to update nginx.conf with your domain name
pause

