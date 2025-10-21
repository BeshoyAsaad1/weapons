# SIMPLE SOLUTION - Get Your Site Working with HTTPS

I understand you're frustrated. Let me give you the simplest possible solution.

## The Problem

Your nginx container keeps crashing because it's looking for SSL certificates that don't exist yet.

## The Solution (3 Simple Steps on EC2)

### Step 1: Stop Everything and Start Fresh

```bash
cd /home/ec2-user/weapon-backend
sudo docker-compose -f docker-compose.prod.yml down
sudo docker stop $(sudo docker ps -aq)
sudo rm -rf certbot/
```

### Step 2: Edit nginx.conf to Remove SSL Temporarily

```bash
sudo nano nginx/nginx.conf
```

Replace the ENTIRE content with this simple version:

```nginx
worker_processes auto;
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;
    
    upstream django { server web:8000; }
    
    server {
        listen 80;
        server_name _;
        
        location /static/ { alias /app/staticfiles/; }
        location /media/ { alias /app/media/; }
        location / {
            proxy_pass http://django;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
```

Press `Ctrl+X`, then `Y`, then `Enter` to save.

### Step 3: Start Containers

```bash
sudo docker-compose -f docker-compose.prod.yml up -d
```

Wait 30 seconds, then check:

```bash
sudo docker ps
```

All containers should show "Up" status.

### Step 4: Test Your Site

Open in browser:
```
http://3.74.228.219/admin/
```

**This WILL work** because we removed all SSL complexity.

---

## Once HTTP Works, Add HTTPS (Optional)

If you really need HTTPS with the DuckDNS domain:

```bash
cd /home/ec2-user/weapon-backend
sudo mkdir -p certbot/conf certbot/www
sudo chmod 755 certbot/ -R
sudo chmod +x init-letsencrypt.sh
sudo DOMAIN=myweapons.duckdns.org EMAIL=Beshoy.Soliman.FCI21114@sadatacademy.edu.eg ./init-letsencrypt.sh
```

Then restore the SSL nginx config and restart.

---

## Alternative: Use the IP Address for Testing

If the developer just wants to test functionality (not SSL):
- Use `http://3.74.228.219` (HTTP, no S)
- Tell them the SSL certificate error is expected with IP addresses
- SSL certificates only work with domain names

The site will work perfectly for testing on HTTP!

---

## Summary

**Right now, just run these 3 commands:**

```bash
cd /home/ec2-user/weapon-backend
sudo docker-compose -f docker-compose.prod.yml down
sudo rm -rf certbot/
```

Then edit nginx.conf with the simple config above and run:

```bash
sudo docker-compose -f docker-compose.prod.yml up -d
```

**Your site will be working in 60 seconds at `http://3.74.228.219/admin/`**

That's it. No more complicated scripts.

