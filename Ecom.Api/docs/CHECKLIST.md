# ✅ Authentication Implementation Checklist

## Before Running

### 1. Configuration
- [ ] Open `appsettings.json`
- [ ] Go to Supabase Dashboard → Settings → API
- [ ] Copy **anon public** key → paste into `Supabase:AnonKey`
- [ ] Copy **JWT Secret** → paste into `SupabaseAuth:JwtSecret`
- [ ] Save file

### 2. Build Project
```powershell
cd "d:\FPT Fall 2025 Semeter8\PRN232\Assignment2\src\Ecom.Api"
dotnet build
```

**Expected:** ✅ Build succeeded. 0 Error(s)

### 3. Run Project
```powershell
dotnet run
```

**Expected:** 
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: https://localhost:7188
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
```

---

## Testing Endpoints

### Test 1: Health Check
```bash
curl https://localhost:7188/api/v1/health
```

**Expected:**
```json
{
  "status": "ok",
  "db": true,
  "products": 0
}
```

### Test 2: Register User
```bash
curl -X POST https://localhost:7188/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@example.com\",\"password\":\"Test1234!\",\"fullName\":\"Test User\"}"
```

**Expected:**
```json
{
  "accessToken": "eyJhbGci...",
  "refreshToken": "v1.MQ...",
  "expiresIn": 3600,
  "tokenType": "bearer",
  "user": {
    "id": "...",
    "email": "test@example.com",
    "fullName": "Test User"
  }
}
```

### Test 3: Login
```bash
curl -X POST https://localhost:7188/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@example.com\",\"password\":\"Test1234!\"}"
```

**Expected:** Same as Test 2

### Test 4: Get User Info
```bash
# Replace YOUR_TOKEN with accessToken from Test 2 or 3
curl https://localhost:7188/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected:**
```json
{
  "id": "...",
  "email": "test@example.com",
  "fullName": "Test User",
  "phone": null,
  "createdAt": "2025-10-13T...",
  "lastSignInAt": "2025-10-13T...",
  "appRole": null
}
```

### Test 5: Logout
```bash
curl -X POST https://localhost:7188/api/v1/auth/logout \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected:**
```json
{
  "message": "Logged out successfully"
}
```

---

## Common Issues & Fixes

### ❌ "Supabase:AnonKey missing"
**Fix:** Update `appsettings.json` with real Supabase anon key

### ❌ "Registration failed: User already registered"
**Fix:** Use different email or delete user in Supabase Dashboard

### ❌ Password validation errors
**Fix:** Ensure password has:
- At least 8 characters
- 1 uppercase letter
- 1 lowercase letter
- 1 digit

### ❌ 401 Unauthorized on `/auth/me`
**Fix:** 
1. Verify token is included: `Authorization: Bearer {token}`
2. Token hasn't expired (1 hour)
3. No extra spaces in header

---

## Integration with Existing Endpoints

### Test Protected Endpoint
```bash
# 1. Login first
curl -X POST https://localhost:7188/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@example.com\",\"password\":\"Test1234!\"}"

# 2. Copy accessToken

# 3. Test cart endpoint
curl https://localhost:7188/api/v1/cart \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected:** Cart data (empty cart if new user)

---

## Admin Endpoint Testing

### Set Admin Role

**Option 1: Supabase Dashboard**
1. Authentication → Users → Click user
2. User Metadata → Raw → Edit:
   ```json
   {
     "app_metadata": {
       "app_role": "admin"
     }
   }
   ```

**Option 2: SQL**
```sql
UPDATE auth.users
SET raw_app_meta_data = raw_app_meta_data || '{"app_role": "admin"}'::jsonb
WHERE email = 'test@example.com';
```

### Test Admin Endpoint
```bash
# 1. Logout and login again to get new token with admin role
curl -X POST https://localhost:7188/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@example.com\",\"password\":\"Test1234!\"}"

# 2. Test product creation (admin only)
curl -X POST https://localhost:7188/api/v1/products \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Test Product\",\"description\":\"Test\",\"price\":100000,\"imageUrl\":\"https://example.com/img.jpg\"}"
```

**Expected:** Product created successfully

---

## Final Verification

All these should work:

- [x] Project builds without errors
- [x] API starts on https://localhost:7188
- [x] Health check returns 200 OK
- [x] Register creates new user
- [x] Login returns valid token
- [x] `/auth/me` returns user info with token
- [x] Logout invalidates session
- [x] Protected endpoints work with token
- [x] Admin endpoints work with admin role

**All checked?** 🎉 **Authentication is ready!**

---

## Documentation

- **Full API Docs:** [`docs/AUTH_API.md`](AUTH_API.md)
- **Setup Guide:** [`docs/AUTH_SETUP.md`](AUTH_SETUP.md)
- **Implementation Summary:** [`docs/AUTH_IMPLEMENTATION_SUMMARY.md`](AUTH_IMPLEMENTATION_SUMMARY.md)
- **HTTP Tests:** [`auth-test.http`](../auth-test.http)

---

## Next Actions

1. **Update Supabase credentials** in `appsettings.json`
2. **Build** the project
3. **Run** the project
4. **Test** all 4 endpoints
5. **Integrate** with frontend
6. **Deploy** to production

Good luck! 🚀
