# 🐛 Supabase Email Confirmation Issue

## Problem

Registration returns 200 OK but response is missing `access_token` or `refresh_token` because **email confirmation is enabled** in Supabase.

## Solution Options

### Option 1: Disable Email Confirmation (Recommended for Development)

1. Go to **Supabase Dashboard** → Your Project
2. Navigate to **Authentication** → **Providers** → **Email**
3. Find **"Confirm email"** setting
4. **Toggle OFF** (disable)
5. Click **Save**

**Result:** Users can login immediately after registration without email verification.

### Option 2: Handle Email Confirmation Flow (Production)

If you want to keep email confirmation enabled:

1. **Update Registration Response:**
   - Return success message without tokens
   - Tell user to check email

2. **Add Email Confirmation Endpoint:**
   ```csharp
   POST /api/v1/auth/verify-email
   {
     "token": "confirmation-token-from-email"
   }
   ```

3. **Update Frontend:**
   - Show "Check your email" message after registration
   - Redirect to login after email confirmation

### Option 3: Check Email Confirmation Status

Update `ParseAuthResponse()` to detect confirmation required:

```csharp
// Check if email confirmation is pending
if (string.IsNullOrEmpty(accessToken) && root.TryGetProperty("user", out var userEl))
{
    if (userEl.TryGetProperty("email_confirmed_at", out var confirmedAt) 
        && confirmedAt.ValueKind == JsonValueKind.Null)
    {
        throw new InvalidOperationException("Email confirmation required. Please check your email.");
    }
}
```

## Current Fix Applied

✅ **Code now handles missing tokens gracefully:**
- Logs warning if `refresh_token` is missing
- Throws clear error if `access_token` is missing
- Logs full response for debugging

## Quick Test

After disabling email confirmation:

```bash
# 1. Delete existing user in Supabase Dashboard
# Authentication → Users → Find user → Delete

# 2. Re-test registration
curl -X POST https://localhost:7188/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test1234!","fullName":"Test User"}'

# Expected: Full AuthResponse with both tokens
```

## Verify Supabase Settings

**Check current setting:**
```
Dashboard → Authentication → Settings → Auth Settings
→ Enable email confirmations: [Toggle Status]
```

**Recommended for Development:**
- ❌ Disable email confirmations
- ❌ Disable email change confirmations

**Recommended for Production:**
- ✅ Enable email confirmations
- ✅ Enable email change confirmations
- Configure custom email templates
- Add email verification reminder flow
