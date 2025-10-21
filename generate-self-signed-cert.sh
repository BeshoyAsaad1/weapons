#!/bin/bash

# Generate Self-Signed SSL Certificate
# This creates a self-signed certificate for testing HTTPS

echo "=========================================="
echo "Generating Self-Signed SSL Certificate"
echo "=========================================="
echo ""

# Create SSL directory
mkdir -p nginx/ssl

# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/nginx-selfsigned.key \
  -out nginx/ssl/nginx-selfsigned.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=3.74.228.219"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Self-signed certificate created successfully!"
    echo ""
    echo "Certificate files:"
    echo "  - nginx/ssl/nginx-selfsigned.crt"
    echo "  - nginx/ssl/nginx-selfsigned.key"
    echo ""
    echo "Valid for: 365 days"
    echo ""
    echo "⚠️  Note: Browsers will show a security warning"
    echo "   Click 'Advanced' and 'Proceed' to continue"
    echo ""
    echo "Next steps:"
    echo "1. Update nginx.conf to use self-signed certificates"
    echo "2. Start containers: sudo docker-compose -f docker-compose.prod.yml up -d"
    echo "3. Visit: https://3.74.228.219/admin/"
else
    echo "❌ Failed to generate certificate"
fi

