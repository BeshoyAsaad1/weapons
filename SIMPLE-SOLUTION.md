# SIMPLE SOLUTION - Get HTTPS Working with DuckDNS

This will get your site working with HTTPS and a valid SSL certificate from Let's Encrypt.

## The Problem

Nginx is crashing because SSL certificates don't exist yet. We need to start with HTTP first, then add SSL.

## The Solution (Step by Step on EC2)

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

**Your site will be working at `http://3.74.228.219/admin/`**

---

## Now Add HTTPS (Let's Encrypt SSL)

Once HTTP works, run these commands to add HTTPS:

### Step 5: Prepare for SSL certificates

```bash
cd /home/ec2-user/weapon-backend
sudo mkdir -p certbot/conf certbot/www
sudo chmod 777 certbot/ -R
```

### Step 6: Update nginx.conf for SSL

```bash
sudo nano nginx/nginx.conf
```

Replace the content with this (supports both HTTP and HTTPS):

```nginx
worker_processes auto;
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;
    
    upstream django { server web:8000; }
    
    # HTTP server - for Let's Encrypt validation
    server {
        listen 80;
        server_name _;
        
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }
        
        location / {
            return 301 https://$host$request_uri;
        }
    }
    
    # HTTPS server
    server {
        listen 443 ssl;
        server_name _;
        
        ssl_certificate /etc/letsencrypt/live/myweapons.duckdns.org/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/myweapons.duckdns.org/privkey.pem;
        
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        
        location /static/ { alias /app/staticfiles/; }
        location /media/ { alias /app/media/; }
        location / {
            proxy_pass http://django;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto https;
        }
    }
}
```

Press `Ctrl+X`, `Y`, `Enter` to save.

### Step 7: Get SSL Certificates from Let's Encrypt

```bash
sudo chmod +x init-letsencrypt.sh
sudo ./init-letsencrypt.sh
```

When prompted, enter:
- Domain: `myweapons.duckdns.org`
- Email: `Beshoy.Soliman.FCI21114@sadatacademy.edu.eg`

Wait 2-3 minutes for certificates to be created.

### Step 8: Restart with HTTPS enabled

```bash
sudo docker-compose -f docker-compose.prod.yml restart nginx
```

Wait 10 seconds, then check:

```bash
sudo docker ps
```

All containers should show "Up" (not "Restarting").

### Step 9: Test HTTPS

Open in browser:
```
https://myweapons.duckdns.org/admin/
```

You should see:
- ✅ Green padlock in browser
- ✅ Django admin login page
- ✅ Valid Let's Encrypt certificate

---

## If Step 7 Fails (init-letsencrypt.sh doesn't exist)

Run this instead to get certificates manually:

```bash
sudo docker run --rm -v "$(pwd)/certbot/conf:/etc/letsencrypt" -v "$(pwd)/certbot/www:/var/www/certbot" certbot/certbot certonly --webroot --webroot-path=/var/www/certbot --email Beshoy.Soliman.FCI21114@sadatacademy.edu.eg --agree-tos --no-eff-email -d myweapons.duckdns.org
```

Then restart nginx:

```bash
sudo docker-compose -f docker-compose.prod.yml restart nginx
```

---

## Summary of All Commands

```bash
# Step 1-3: Get HTTP working
cd /home/ec2-user/weapon-backend
sudo docker-compose -f docker-compose.prod.yml down
sudo rm -rf certbot/
# Edit nginx.conf with HTTP-only config
sudo docker-compose -f docker-compose.prod.yml up -d

# Step 5-9: Add HTTPS
sudo mkdir -p certbot/conf certbot/www
sudo chmod 777 certbot/ -R
# Edit nginx.conf with HTTPS config
sudo chmod +x init-letsencrypt.sh
sudo ./init-letsencrypt.sh
sudo docker-compose -f docker-compose.prod.yml restart nginx
```

That's it! Your site will have valid HTTPS with Let's Encrypt.

