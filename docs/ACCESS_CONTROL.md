# Access Control Documentation

## Overview

**SocialTrend Automator** uses **flat access control** - all authenticated users have **full access** to all features and data. No role-based authorization (RBAC) is implemented.

## Authentication vs Authorization

### ✅ Authentication (REQUIRED)
- Users must **login** to access protected endpoints
- JWT tokens (Laravel Sanctum / FastAPI OAuth2) are required
- Token validation is enforced

### ❌ Authorization (DISABLED)
- **No role checks** - no `admin`, `user`, `moderator`, etc.
- **No permission checks** - no `can()`, `authorize()`, `@permission_required`
- **No ACL/RBAC** - all users are treated equally after authentication

## Implementation Details

### Backend (Laravel)

**Files Modified:**
- `app/Models/User.php` - Documented flat access control
- `routes/api.php` - Added comments about no role restrictions
- `app/Http/Controllers/Controller.php` - Added documentation comment

**Routes:**
```php
// All authenticated users can access these
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [UserController::class, 'user']);
    Route::get('/trends', [TrendController::class, 'index']);
    Route::post('/schedule', [ScheduleController::class, 'store']);
});
```

**No Role Checks:**
- ❌ No `middleware('role:admin')`
- ❌ No `$user->hasRole('admin')`
- ❌ No `Gate::allows('admin-action')`
- ✅ Only `auth:sanctum` middleware

### Automation Service (FastAPI)

**Files Modified:**
- `app/api/routes/auth.py` - Documented flat access control
- `app/services/auth_service.py` - Added documentation comment

**Endpoints:**
```python
# All authenticated users can access these
@router.post("/upload")
@router.post("/trends/fetch")
@router.post("/ai/caption")
# All require: Depends(get_current_active_user)
# But NO role/permission checks
```

**No Role Checks:**
- ❌ No `@require_role('admin')`
- ❌ No `user.role == 'admin'`
- ❌ No permission decorators
- ✅ Only `Depends(get_current_active_user)`

### Frontend (Vue.js)

- No role-based UI restrictions
- All features available to all authenticated users
- No conditional rendering based on roles

## Example API Requests

### Before (if roles existed):
```bash
# Would return 403 Forbidden if user is not admin
GET /api/admin/dashboard
Authorization: Bearer <token>
```

### After (flat access):
```bash
# Returns 200 OK for ANY authenticated user
GET /api/admin/dashboard  # (if endpoint exists)
Authorization: Bearer <token>
```

### Current Protected Endpoints:
```bash
# ✅ All authenticated users can access:

# Get user info
GET /api/user
Authorization: Bearer <token>

# Get trends
GET /api/trends
Authorization: Bearer <token>

# Schedule post
POST /api/schedule
Authorization: Bearer <token>
Content-Type: application/json
{
  "social_account_id": 1,
  "content": "Test post",
  "scheduled_at": "2024-12-25 10:00:00"
}

# FastAPI - Upload
POST /automation/api/upload
Authorization: Bearer <token>
{
  "platform": "instagram",
  "content": "Test content"
}

# FastAPI - Fetch trends
POST /automation/api/trends/fetch
Authorization: Bearer <token>
{
  "platform": "google",
  "keywords": ["AI", "Technology"]
}

# FastAPI - AI Caption
POST /automation/api/ai/caption
Authorization: Bearer <token>
{
  "topic": "Technology",
  "style": "professional"
}
```

## Security Considerations

⚠️ **Important Security Notes:**

1. **Public Deployment**: This system is **NOT suitable for public-facing applications** without additional security measures:
   - All authenticated users have **full access** to modify/delete any data
   - No data isolation between users
   - No audit trails for role-based actions

2. **Recommended for:**
   - Internal tools
   - Single-tenant applications
   - Development/testing environments
   - Applications with additional application-level security

3. **If you need multi-tenant/user isolation:**
   - Add user-specific data filtering
   - Implement ownership checks (`where('user_id', $user->id)`)
   - Add soft-delete or audit logging for sensitive operations

## Migration Notes

### Spatie Permission Package
- **Status**: Installed but **NOT USED**
- Package: `spatie/laravel-permission` (in `composer.json`)
- Tables: Permission tables may exist but are **ignored**
- Migration: Optional cleanup migration created at `database/migrations/2024_11_02_000001_drop_permission_tables.php`
  - Currently commented out (keeps existing structure)
  - Uncomment to remove permission tables completely

### Future Changes
If you want to add role-based access control later:
1. Enable Spatie Permission usage
2. Add `HasRoles` trait to User model
3. Add role checks to routes: `middleware('role:admin')`
4. Add permission checks in controllers: `$user->can('action')`

## Summary

✅ **Authentication**: Required (login/token)  
❌ **Authorization**: Disabled (no roles/permissions)  
✅ **Access**: Full access for all authenticated users  
⚠️ **Security**: Suitable for internal/trusted environments only

