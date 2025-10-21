# "Site Can't Be Reached" - Troubleshooting Guide

## 🔴 Error: "This site can't be reached"

This means one of the following:

1. ❌ SSL setup hasn't been completed on EC2 yet
2. ❌ Docker containers aren't running
3. ❌ DuckDNS isn't pointing to the correct IP
4. ❌ EC2 Security Group ports aren't open

## 🔍 Let's Diagnose the Issue

### On Your EC2 Instance, Run These Commands:

```bash
# 1. Check if you're in the right directory
cd /home/ubuntu/weapons
pwd

# 2. Check if containers are running
docker-compose -f docker-compose.prod.yml ps

# 3. Check if nginx is listening on port 443
sudo netstat -tlnp | grep -E '80|443'

# 4. Test if DNS is working
nslookup myweapons.duckdns.org

# 5. Check if you can reach the server locally
curl -I http://localhost:80
```

## 🚨 Quick Diagnosis by Output:

### If `docker-compose -f docker-compose.prod.yml ps` shows no containers:
**Problem**: Containers aren't running
**Solution**: Run the SSL setup script

```bash
cd /home/ubuntu/weapons
git stash
git pull
chmod +x complete-ssl-setup.sh quick-deploy.sh init-letsencrypt.sh
./complete-ssl-setup.sh myweapons.duckdns.org Beshoy.Soliman.FCI21114@sadatacademy.edu.eg
```

### If `nslookup myweapons.duckdns.org` doesn't return `3.74.228.219`:
**Problem**: DNS not configured correctly
**Solution**: 
1. Go to [duckdns.org](https://www.duckdns.org)
2. Login
3. Make sure your domain points to `3.74.228.219`
4. Wait 2-3 minutes for DNS propagation

### If `netstat` shows nothing on port 80/443:
**Problem**: Nginx isn't running
**Solution**: Start the containers

```bash
docker-compose -f docker-compose.prod.yml up -d
docker-compose -f docker-compose.prod.yml ps
```

## ✅ Complete Fix - Run ALL These Commands:

**Copy and paste this entire block into your EC2 terminal:**

```bash
# Navigate to project directory
cd /home/ubuntu/weapons

# Fix git conflict and pull latest code
git stash
git pull

# Make scripts executable
chmod +x complete-ssl-setup.sh quick-deploy.sh init-letsencrypt.sh

# Verify DuckDNS is pointing to your EC2 IP
echo "Checking DNS..."
nslookup myweapons.duckdns.org

# If DNS looks good, run the SSL setup
./complete-ssl-setup.sh myweapons.duckdns.org Beshoy.Soliman.FCI21114@sadatacademy.edu.eg

# Check if containers started successfully
echo ""
echo "Checking container status..."
docker-compose -f docker-compose.prod.yml ps

# Check if ports are listening
echo ""
echo "Checking if nginx is listening..."
sudo netstat -tlnp | grep -E '80|443'

# Test local connection
echo ""
echo "Testing local connection..."
curl -I http://localhost:80
```

## 🎯 Expected Successful Output:

After running the commands above, you should see:

```
✅ DNS Resolution:
Address: 3.74.228.219

✅ Containers Running:
weaponbackend_web_prod     (healthy)
weaponbackend_nginx_prod   (running)
weaponbackend_redis_prod   (healthy)
weaponbackend_certbot      (running)

✅ Ports Listening:
tcp6  0  0  :::80   :::*  LISTEN
tcp6  0  0  :::443  :::*  LISTEN

✅ HTTP Response:
HTTP/1.1 301 Moved Permanently
```

## 🌐 After Successful Setup:

1. Wait 30 seconds for services to fully start
2. Open browser
3. Visit: `https://myweapons.duckdns.org/admin/`
4. Should see: Green padlock + Django admin page

## 🆘 Still Not Working?

### Check EC2 Security Group:

Your EC2 Security Group MUST have these inbound rules:

| Type  | Protocol | Port Range | Source    |
|-------|----------|------------|-----------|
| HTTP  | TCP      | 80         | 0.0.0.0/0 |
| HTTPS | TCP      | 443        | 0.0.0.0/0 |
| SSH   | TCP      | 22         | Your IP   |

To check/add these rules:
1. Go to AWS Console → EC2 → Security Groups
2. Find your instance's security group
3. Check Inbound Rules
4. Add missing rules if needed

### Check DuckDNS Configuration:

1. Visit [duckdns.org](https://www.duckdns.org)
2. Login
3. Your domain should show: `myweapons` → IP: `3.74.228.219`
4. Click "update ip" button to refresh

### Verify Your EC2 Public IP:

```bash
# On EC2, run:
curl http://169.254.169.254/latest/meta-data/public-ipv4
```

Should return: `3.74.228.219`

If different, update DuckDNS with the new IP!

## 📞 Quick Test from Your Local Machine:

From your Windows machine, test if the EC2 server is reachable:

```bash
# Test HTTP (should work even before SSL setup)
curl -I http://3.74.228.219

# Test DNS resolution
nslookup myweapons.duckdns.org
```

If these work, the problem is with the SSL setup. If they don't work, it's a Security Group or EC2 issue.

---

## 🎬 Next Steps:

1. **Run the complete fix commands** from the "Complete Fix" section above
2. **Post the output here** so I can see what's happening
3. **Try accessing** `https://myweapons.duckdns.org/admin/` again

The most likely issue is that you haven't run the SSL setup script yet. Once you run it, everything should work! 🚀

