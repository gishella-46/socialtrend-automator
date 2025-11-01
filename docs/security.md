# Security Implementation Guide

## Overview

SocialTrend Automator implements production-grade security measures across all layers to protect against HTTP leaks, brute-force attacks, and token exposure.

## 🔒 Security Features Implemented

### 1. Nginx SSL Configuration

#### SSL/TLS Setup
- **Certbot (Let's Encrypt)**: Free SSL certificates
- **Cloudflare Proxy**: Alternative SSL solution
- **HTTPS Redirect**: All HTTP traffic redirected to HTTPS
- **Strong Cipher Suites**: TLS 1.2 and TLS 1.3 only

#### Security Headers
- **HSTS (HTTP Strict Transport Security)**: `max-age=31536000; includeSubDomains; preload`
- **X-Frame-Options**: `SAMEORIGIN` (prevents clickjacking)
- **X-Content-Type-Options**: `nosniff` (prevents MIME sniffing)
- **X-XSS-Protection**: `1; mode=block`
- **Content-Security-Policy**: Restricts resource loading
- **Referrer-Policy**: Controls referrer information

#### Configuration Location
- `docker/nginx/conf.d/default.conf`
- Uncomment HTTPS server block for production

### 2. Backend Security (Laravel)

#### Rate Limiting
**Protection**: Brute-force attack prevention

**Configuration**:
- General API: 60 requests/minute
- Login endpoint: 5 requests/minute
- Register endpoint: 3 requests/minute

**Implementation**:
```php
// bootstrap/app.php
$middleware->api(throttle: [
    '60,1',
    'login' => '5,1',
    'register' => '3,1',
]);
```

#### Token Encryption (AES-256)
**Protection**: Social media token exposure

**Implementation**:
- `app/Services/EncryptionService.php` - AES-256 encryption service
- `app/Models/SocialAccount.php` - Auto encrypt/decrypt on save/retrieve

**Features**:
- Tokens encrypted before database storage
- Automatic decryption on retrieval
- Uses Laravel's Crypt facade (AES-256-CBC)

#### CSRF Protection
**Protection**: Cross-site request forgery

**Implementation**:
- Enabled via Sanctum for stateful requests
- Webhook endpoints excluded (external service callbacks)
- Configurable via `bootstrap/app.php`

#### Audit Logging
**Protection**: Activity tracking and security monitoring

**Implementation**:
- `app/Models/AuditLog.php` - Audit log model
- `app/Services/AuditLogService.php` - Logging service
- Migration: `2024_12_01_000000_create_audit_logs_table.php`

**Logged Activities**:
- User login (success/failure)
- User registration
- Content upload/schedule
- All user actions with IP and user agent

**Database Schema**:
```sql
- user_id (foreign key)
- action (login, upload, edit, etc.)
- resource_type (ScheduledPost, SocialAccount, etc.)
- resource_id
- ip_address
- user_agent
- metadata (JSON)
- created_at
```

### 3. FastAPI Security

#### OAuth2/JWT Authentication
**Protection**: Unauthorized API access

**Implementation**:
- `app/services/auth_service.py` - OAuth2/JWT service
- `app/api/routes/auth.py` - Authentication endpoints

**Features**:
- OAuth2 password flow
- JWT Bearer token authentication
- Token expiration (configurable, default 30 minutes)
- Password hashing with bcrypt

**Endpoints**:
- `POST /automation/token` - Get access token
- `GET /automation/me` - Get current user

**Usage**:
```python
from fastapi import Depends
from app.services.auth_service import get_current_active_user

@router.post("/endpoint")
async def protected_endpoint(
    current_user: dict = Depends(get_current_active_user)
):
    # Endpoint requires authentication
    pass
```

#### CORS Whitelist
**Protection**: Cross-origin request attacks

**Configuration**:
```python
# automation/main.py
ALLOWED_ORIGINS = [
    "http://localhost",
    "http://localhost:8080",
    "https://yourdomain.com",  # Production domain
]
```

**Features**:
- Only whitelisted origins allowed
- Credentials support for authenticated requests
- Restricted methods and headers

## 🛡️ Security Checklist

### Production Deployment

- [ ] **SSL Certificate**: Install via Certbot or Cloudflare
- [ ] **HTTPS Redirect**: Uncomment redirect in nginx config
- [ ] **Environment Variables**: Set `JWT_SECRET_KEY` in FastAPI `.env`
- [ ] **App Key**: Set `APP_KEY` in Laravel `.env`
- [ ] **CORS Origins**: Update with production frontend domain
- [ ] **Rate Limits**: Adjust based on expected traffic
- [ ] **Database Encryption**: Verify APP_KEY is set for token encryption
- [ ] **Audit Logs**: Monitor regularly for suspicious activity

### Environment Variables Required

#### Laravel Backend (.env)
```env
APP_KEY=base64:xxxxxxxxxxxxx  # Required for encryption
FRONTEND_URL=https://yourdomain.com
```

#### FastAPI Automation (.env)
```env
JWT_SECRET_KEY=your-super-secret-jwt-key-min-32-chars
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30
FRONTEND_URL=https://yourdomain.com
```

## 📊 Security Monitoring

### Audit Log Queries

```sql
-- Failed login attempts
SELECT * FROM audit_logs 
WHERE action = 'login_failed' 
ORDER BY created_at DESC;

-- Recent user activities
SELECT * FROM audit_logs 
WHERE user_id = ? 
ORDER BY created_at DESC 
LIMIT 50;

-- Suspicious activity (multiple failed logins)
SELECT user_id, COUNT(*) as attempts 
FROM audit_logs 
WHERE action = 'login_failed' 
AND created_at > NOW() - INTERVAL '1 hour'
GROUP BY user_id 
HAVING COUNT(*) > 5;
```

## 🔐 Token Security

### Social Media Tokens
- ✅ Encrypted with AES-256 before database storage
- ✅ Automatically decrypted on model retrieval
- ✅ Never exposed in API responses
- ✅ Stored in encrypted format only

### JWT Tokens (FastAPI)
- ✅ Signed with secret key
- ✅ Time-limited expiration
- ✅ Bearer token authentication
- ✅ Protected endpoints require valid token

### Laravel Sanctum Tokens
- ✅ API token authentication
- ✅ Token-based (no cookies needed for API)
- ✅ Per-user token generation
- ✅ Revocable tokens

## 🚨 Incident Response

### Brute-Force Detection
Rate limiting automatically blocks excessive login attempts:
- After 5 failed logins per minute, further attempts are throttled
- All attempts logged in audit_logs table

### Token Exposure
If tokens are compromised:
1. **Social Media Tokens**: Rotate immediately on social platform
2. **JWT Tokens**: Change `JWT_SECRET_KEY`, invalidates all tokens
3. **Sanctum Tokens**: Revoke user tokens via `$user->tokens()->delete()`

### Audit Log Review
Regular review of audit_logs for:
- Unusual access patterns
- Multiple failed login attempts
- Access from unexpected IPs
- Unauthorized resource access

## 📝 Security Best Practices

1. **Never commit secrets**: Use `.env` files (in `.gitignore`)
2. **Regular updates**: Keep dependencies updated
3. **Strong passwords**: Enforce strong password policies
4. **HTTPS only**: Never use HTTP in production
5. **Monitor logs**: Regular audit log review
6. **Backup encryption**: Encrypt database backups
7. **Access control**: Limit admin access to audit logs

## 🔗 Related Documentation

- [API Specification](./api-spec.md)
- [Architecture](./architecture.md)
- [Deployment Guide](./deployment.md)








