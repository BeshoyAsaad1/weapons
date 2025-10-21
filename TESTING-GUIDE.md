# Complete Testing Guide for DuckDNS SSL Setup

## ✅ What I Just Fixed:

1. **Docker Build Issue**: Changed `libaio1` to `libaio-dev` (compatible with Debian Trixie)
2. **SSL Setup Script**: Recreated `complete-ssl-setup.sh` with proper content
3. **Added Quick Deploy**: Created `quick-deploy.sh` for simple deployments

## 🚀 Step-by-Step Testing on EC2:

### Step 1: Pull Latest Changes

```bash
cd /home/ubuntu/weapons
git pull
```

You should see:
- `Dockerfile.prod` updated
- `complete-ssl-setup.sh` updated
- `quick-deploy.sh` added

### Step 2: Make Scripts Executable

```bash
chmod +x complete-ssl-setup.sh
chmod +x quick-deploy.sh
chmod +x init-letsencrypt.sh
```

### Step 3: Verify Your DuckDNS Domain

```bash
nslookup myweapons.duckdns.org
```

Should return your EC2 IP: `3.74.228.219`

### Step 4: Run Complete SSL Setup

```bash
./complete-ssl-setup.sh myweapons.duckdns.org Beshoy.Soliman.FCI21114@sadatacademy.edu.eg
```

This will:
- Update nginx.conf with your domain
- Stop existing containers
- Obtain Let's Encrypt SSL certificates
- Start all services

### Step 5: Verify Containers are Running

```bash
docker-compose -f docker-compose.prod.yml ps
```

You should see:
- ✅ weaponbackend_web_prod
- ✅ weaponbackend_nginx_prod
- ✅ weaponbackend_redis_prod
- ✅ weaponbackend_certbot

### Step 6: Check SSL Certificate

```bash
docker-compose -f docker-compose.prod.yml run --rm certbot certificates
```

Should show your certificate for `myweapons.duckdns.org`

### Step 7: Test in Browser

1. Open: `https://myweapons.duckdns.org`
2. Check for green padlock 🔒
3. Click padlock → Should say "Connection is secure"
4. Certificate should be issued by "Let's Encrypt"

## 🔍 Troubleshooting Commands:

### If containers won't start:
```bash
docker-compose -f docker-compose.prod.yml logs
```

### If nginx has errors:
```bash
docker-compose -f docker-compose.prod.yml logs nginx
```

### If SSL certificate failed:
```bash
docker-compose -f docker-compose.prod.yml logs certbot
```

### Restart everything:
```bash
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d
```

### Check if ports are listening:
```bash
sudo netstat -tlnp | grep -E '80|443'
```

## 📋 Pre-flight Checklist:

- [ ] DuckDNS domain created: `myweapons.duckdns.org`
- [ ] DuckDNS points to: `3.74.228.219`
- [ ] Port 80 open in Security Group
- [ ] Port 443 open in Security Group
- [ ] Docker installed on EC2
- [ ] docker-compose installed on EC2

## 🆘 Common Issues:

### "Failed authorization procedure"
**Solution**: Wait 2-3 minutes for DNS propagation, then try again

### "Rate limit exceeded"
**Solution**: You've requested too many certificates. Wait 1 hour or use staging mode

### "Connection refused"
**Solution**: Check if containers are running: `docker ps`

### "502 Bad Gateway"
**Solution**: Django app isn't ready yet. Check: `docker-compose -f docker-compose.prod.yml logs web`

## ✨ Alternative: Quick Deploy (Without SSL Setup)

If you just want to test without setting up SSL again:

```bash
./quick-deploy.sh myweapons.duckdns.org
```

This updates nginx and restarts containers without touching certificates.

## 🎯 Expected Success Output:

```
=============================================
SSL Setup and Deployment for EC2
=============================================

Domain: myweapons.duckdns.org
Email: Beshoy.Soliman.FCI21114@sadatacademy.edu.eg

Step 1: Updating nginx.conf with domain name...
✓ nginx.conf updated

Step 2: Stopping existing containers...
✓ Containers stopped

Step 3: Running Let's Encrypt certificate setup...
### Preparing directories ...
### Downloading recommended TLS parameters ...
### Creating dummy certificate for myweapons.duckdns.org ...
### Starting nginx ...
### Deleting dummy certificate ...
### Requesting Let's Encrypt certificate ...
Successfully received certificate.

✓ SSL certificates obtained successfully!

=============================================
✅ SSL Setup Complete!
=============================================

Your website is now secured with Let's Encrypt SSL
Visit: https://myweapons.duckdns.org

Certificate auto-renewal is configured to run every 12 hours
```

## 🔐 After Successful Setup:

Your API endpoints will be:
- `https://myweapons.duckdns.org/api/`
- `https://myweapons.duckdns.org/admin/`

Update your frontend to use this domain instead of the IP address!

---

**Ready to test? Run the commands from Step 1-4 above!** 🚀

