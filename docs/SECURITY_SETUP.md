# Security Setup Guide

## Quick Setup

### Automated Setup (Recommended)

Run the automated setup script:

```powershell
# Windows PowerShell
.\scripts\setup-production.ps1
```

This script will:
- Generate Laravel APP_KEY
- Generate and set JWT_SECRET_KEY for FastAPI
- Enable HTTPS redirect in Nginx
- Run database migrations

### 1. Environment Variables

#### Laravel Backend (.env)
```env
APP_KEY=base64:xxxxxxxxxxxxx  # Generate with: php artisan key:generate
FRONTEND_URL=https://yourdomain.com
```

#### FastAPI Automation (.env)
```env
JWT_SECRET_KEY=your-super-secret-key-minimum-32-characters-long
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30
FRONTEND_URL=https://yourdomain.com
```

### 2. SSL Certificate Setup

#### Option A: Certbot (Let's Encrypt)
```bash
# Install certbot in nginx container
docker exec socialtrend_nginx apk add certbot certbot-nginx

# Get certificate
docker exec socialtrend_nginx certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal (add to crontab)
0 0 * * * docker exec socialtrend_nginx certbot renew --quiet
```

#### Option B: Cloudflare
1. Get Origin Certificate from Cloudflare Dashboard
2. Save certificate and key to `docker/nginx/ssl/`
3. Update nginx config with Cloudflare paths
4. Uncomment Cloudflare SSL lines in `default.conf`

### 3. Enable HTTPS Redirect

Edit `docker/nginx/conf.d/default.conf`:
1. Uncomment HTTPS server block
2. Update domain names
3. Update certificate paths
4. Uncomment HTTP to HTTPS redirect

### 4. Generate Laravel App Key

```bash
docker exec socialtrend_backend php artisan key:generate
```

This key is required for AES-256 token encryption.

### 5. Run Migrations

```bash
docker exec socialtrend_backend php artisan migrate
```

This creates the `audit_logs` table.

## Testing Security

### Test Rate Limiting
```bash
# Should fail after 5 attempts
for i in {1..10}; do
  curl -X POST http://localhost/api/login \
    -H "Content-Type: application/json" \
    -d '{"email":"test@test.com","password":"wrong"}'
done
```

### Test JWT Authentication
```bash
# Get token
TOKEN=$(curl -X POST http://localhost/automation/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=secret" | jq -r '.access_token')

# Use token
curl http://localhost/automation/api/upload \
  -H "Authorization: Bearer $TOKEN"
```

### Test CORS
```bash
# Should fail from non-whitelisted origin
curl -X POST http://localhost/automation/api/upload \
  -H "Origin: http://evil.com" \
  -H "Authorization: Bearer $TOKEN"
```

## Security Checklist

- [ ] SSL certificate installed
- [ ] HTTPS redirect enabled
- [ ] `APP_KEY` set in Laravel .env
- [ ] `JWT_SECRET_KEY` set in FastAPI .env
- [ ] `FRONTEND_URL` updated with production domain
- [ ] CORS origins updated
- [ ] Audit logs migration run
- [ ] Rate limiting tested
- [ ] Token encryption verified
- [ ] Security headers verified

