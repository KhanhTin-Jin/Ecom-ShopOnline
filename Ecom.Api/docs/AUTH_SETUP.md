# 🚀 Quick Setup Guide: Authentication

## Prerequisites

- Supabase project created
- API credentials ready

---

## Setup Steps

### 1️⃣ Get Supabase Credentials

1. Go to **Supabase Dashboard**: https://app.supabase.com
2. Select your project
3. Navigate to **Settings** → **API**
4. Copy these values:
   - **Project URL** (e.g., `https://abc123.supabase.co`)
   - **Project API keys** → **anon public** key
   - **JWT Settings** → **JWT Secret**

### 2️⃣ Update Configuration

Edit `appsettings.json`:

```json
{
  "Supabase": {
    "Url": "https://rioqfyejijcvdteaglzo.supabase.co",
    "AnonKey": "PASTE_YOUR_ANON_KEY_HERE"
  },
  "SupabaseAuth": {
    "JwtIssuer": "https://rioqfyejijcvdteaglzo.supabase.co/auth/v1",
    "JwtAudience": "authenticated",
    "JwtSecret": "PASTE_YOUR_JWT_SECRET_HERE"
  }
}
```

**⚠️ Important:** Never commit real credentials to git!

### 3️⃣ Build & Run

```powershell
dotnet build
dotnet run --project Ecom.Api.csproj
```

### 4️⃣ Test Registration

Open `auth-test.http` in VS Code and run:

```http
POST https://localhost:7188/api/v1/auth/register
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "Test1234!",
  "fullName": "Test User"
}
```

**Expected Response:**
```json
{
  "accessToken": "eyJhbGci...",
  "refreshToken": "v1.MQ...",
  "expiresIn": 3600,
  "tokenType": "bearer",
  "user": {
    "id": "uuid-here",
    "email": "test@example.com",
    "fullName": "Test User"
  }
}
```

### 5️⃣ Test Login

```http
POST https://localhost:7188/api/v1/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "Test1234!"
}
```

### 6️⃣ Test Protected Endpoint

Copy `accessToken` from login response:

```http
GET https://localhost:7188/api/v1/auth/me
Authorization: Bearer {PASTE_ACCESS_TOKEN_HERE}
```

---

## Troubleshooting

### ❌ Error: "Supabase:AnonKey missing"

**Fix:** Check `appsettings.json` has correct `Supabase:AnonKey` value.

### ❌ Error: "Registration failed"

**Causes:**
1. Email already exists → Use different email
2. Password too weak → Follow requirements (8+ chars, upper/lower/digit)
3. Invalid email format → Check email syntax

### ❌ Error: 401 Unauthorized

**Causes:**
1. Token expired → Login again (tokens expire after 1 hour)
2. Wrong token → Verify you copied full token
3. JWT secret mismatch → Check `SupabaseAuth:JwtSecret` in config

### ❌ Error: "Login failed: Invalid email or password"

**Fix:** 
1. Verify email/password are correct
2. Check user exists in Supabase (Dashboard → Authentication → Users)

---

## Verify Setup ✅

Run all these commands successfully:

```bash
# 1. Register
curl -X POST https://localhost:7188/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"verify@test.com","password":"Test1234!"}'

# 2. Login
curl -X POST https://localhost:7188/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"verify@test.com","password":"Test1234!"}'

# 3. Get user (replace TOKEN)
curl https://localhost:7188/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"

# 4. Logout
curl -X POST https://localhost:7188/api/v1/auth/logout \
  -H "Authorization: Bearer YOUR_TOKEN"
```

If all 4 succeed: **✅ Setup Complete!**

---

## Next Steps

- [ ] Set admin role in Supabase (for admin endpoints)
- [ ] Test product creation with admin user
- [ ] Integrate with frontend
- [ ] Setup email confirmation (optional)

---

## Admin Role Setup (Optional)

To use admin-only endpoints (e.g., POST `/api/v1/products`):

### Option 1: Via Supabase Dashboard

1. Go to **Authentication** → **Users**
2. Click on user
3. Scroll to **User Metadata** → **Raw**
4. Edit JSON:
   ```json
   {
     "app_metadata": {
       "app_role": "admin"
     }
   }
   ```
5. Save

### Option 2: Via SQL

```sql
UPDATE auth.users
SET raw_app_meta_data = raw_app_meta_data || '{"app_role": "admin"}'::jsonb
WHERE email = 'test@example.com';
```

After setting role, **logout and login again** to get new token with admin claim.

---

## API Documentation

Full documentation: [`docs/AUTH_API.md`](AUTH_API.md)
