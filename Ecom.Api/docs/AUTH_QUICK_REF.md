# 🎯 Auth API Quick Reference

## Endpoints

```
POST   /api/v1/auth/register    Register new user
POST   /api/v1/auth/login       Login with email/password
POST   /api/v1/auth/logout      Logout (requires token)
GET    /api/v1/auth/me          Get current user (requires token)
```

## Register

```bash
curl -X POST https://localhost:7188/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"Pass1234!","fullName":"John Doe"}'
```

## Login

```bash
curl -X POST https://localhost:7188/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"Pass1234!"}'
```

## Get User

```bash
curl https://localhost:7188/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Logout

```bash
curl -X POST https://localhost:7188/api/v1/auth/logout \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Password Rules

- ✅ Min 8 characters
- ✅ 1 uppercase (A-Z)
- ✅ 1 lowercase (a-z)
- ✅ 1 digit (0-9)

## Response Structure

### Success (Register/Login)
```json
{
  "accessToken": "eyJhbGci...",
  "refreshToken": "v1.MQ...",
  "expiresIn": 3600,
  "tokenType": "bearer",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "fullName": "John Doe",
    "phone": null,
    "createdAt": "2025-10-13T10:00:00Z",
    "lastSignInAt": "2025-10-13T10:00:00Z",
    "appRole": null
  }
}
```

### Error
```json
{
  "error": "Login failed",
  "message": "Invalid email or password"
}
```

## Config Required

```json
{
  "Supabase": {
    "Url": "https://your-project.supabase.co",
    "AnonKey": "your-anon-key"
  },
  "SupabaseAuth": {
    "JwtIssuer": "https://your-project.supabase.co/auth/v1",
    "JwtAudience": "authenticated",
    "JwtSecret": "your-jwt-secret"
  }
}
```

## Status Codes

- `200` - Success
- `400` - Bad request (validation error, user exists)
- `401` - Unauthorized (invalid token/credentials)
- `404` - User not found
- `500` - Server error

## Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| "Supabase:AnonKey missing" | Missing config | Add to appsettings.json |
| "User already registered" | Email exists | Use different email |
| "Password must contain..." | Weak password | Follow password rules |
| 401 on `/auth/me` | Invalid token | Login again |

## Files

- **Controller:** `Controllers/AuthController.cs`
- **Service:** `Provider/SupabaseAuthService.cs`
- **DTOs:** `Dtos/AuthDto.cs`
- **Validators:** `Validators/AuthRequestValidators.cs`
- **Tests:** `auth-test.http`
- **Docs:** `docs/AUTH_API.md`
