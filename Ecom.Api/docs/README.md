# 📚 Ecom.Api Documentation

Welcome to the Ecom.Api documentation! This folder contains all technical documentation for the E-commerce API.

---

## 📖 Documentation Index

### Authentication
- **[AUTH_QUICK_REF.md](AUTH_QUICK_REF.md)** - Quick reference card for auth endpoints
- **[AUTH_API.md](AUTH_API.md)** - Complete auth API documentation
- **[AUTH_SETUP.md](AUTH_SETUP.md)** - Setup guide for authentication
- **[AUTH_IMPLEMENTATION_SUMMARY.md](AUTH_IMPLEMENTATION_SUMMARY.md)** - Implementation details
- **[CHECKLIST.md](CHECKLIST.md)** - Testing and verification checklist

### Payments & Webhooks
- **[STRIPE_WEBHOOK_SETUP.md](STRIPE_WEBHOOK_SETUP.md)** - Stripe webhook setup guide (local & ngrok)
- **[WEBHOOK_DEBUG_GUIDE.md](WEBHOOK_DEBUG_GUIDE.md)** - Troubleshooting webhook issues

### Project Context
- **[PROJECT_CONTEXT.md](PROJECT_CONTEXT.md)** - Project architecture and overview

---

## 🚀 Quick Start

### 1. First Time Setup

```powershell
# Clone & navigate
cd "d:\FPT Fall 2025 Semeter8\PRN232\Assignment2\src\Ecom.Api"

# Install dependencies
dotnet restore

# Update configuration
# Edit appsettings.json with your Supabase credentials

# Run migrations
dotnet ef database update

# Start API
dotnet run
```

### 2. Test Authentication

See [`CHECKLIST.md`](CHECKLIST.md) for complete testing steps.

Quick test:
```bash
# Register
curl -X POST https://localhost:7188/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test1234!"}'

# Login
curl -X POST https://localhost:7188/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test1234!"}'
```

### 3. Test Stripe Payments

See [`STRIPE_WEBHOOK_SETUP.md`](STRIPE_WEBHOOK_SETUP.md) for webhook setup.

---

## 📋 API Overview

### Authentication Endpoints
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/auth/register` | ❌ | Register new user |
| POST | `/api/v1/auth/login` | ❌ | Login |
| POST | `/api/v1/auth/logout` | ✅ | Logout |
| GET | `/api/v1/auth/me` | ✅ | Get user info |

### Product Endpoints
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/products` | ❌ | List products (paginated) |
| GET | `/api/v1/products/{id}` | ❌ | Get product by ID |
| POST | `/api/v1/products` | 🔒 Admin | Create product |
| PUT | `/api/v1/products/{id}` | 🔒 Admin | Update product |
| DELETE | `/api/v1/products/{id}` | 🔒 Admin | Delete product |

### Cart Endpoints
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/cart` | ✅ | Get user's cart |
| POST | `/api/v1/cart/items` | ✅ | Add item to cart |
| PUT | `/api/v1/cart/items/{id}` | ✅ | Update cart item |
| DELETE | `/api/v1/cart/items/{id}` | ✅ | Remove cart item |

### Order Endpoints
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/orders` | ✅ | List user's orders |
| GET | `/api/v1/orders/{id}` | ✅ | Get order by ID |
| POST | `/api/v1/orders` | ✅ | Create order from cart |
| PUT | `/api/v1/orders/{id}/status` | ✅ | Update order status |

### Payment Endpoints
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/payments/create` | ✅ | Create Stripe checkout session |
| POST | `/api/webhook` | ❌ | Stripe webhook (signature verified) |

### Utility Endpoints
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/health` | ❌ | Health check |
| GET | `/api/v1/auth-debug/me` | ✅ | Debug JWT claims |

---

## 🏗️ Architecture

```
┌─────────────┐
│   Client    │ (Frontend: React/Vue/Angular)
└──────┬──────┘
       │ HTTPS + JWT
       ↓
┌─────────────────────────────────────────────┐
│         ASP.NET Core 9 Web API              │
│  ┌────────────────────────────────────┐    │
│  │      Controllers Layer              │    │
│  │  - AuthController                   │    │
│  │  - ProductsController               │    │
│  │  - CartController                   │    │
│  │  - OrdersController                 │    │
│  │  - PaymentsController               │    │
│  └────────────────────────────────────┘    │
│  ┌────────────────────────────────────┐    │
│  │      Services Layer                 │    │
│  │  - SupabaseAuthService              │    │
│  │  - StripePaymentProvider            │    │
│  └────────────────────────────────────┘    │
│  ┌────────────────────────────────────┐    │
│  │      Data Layer (EF Core)           │    │
│  │  - AppDbContext                     │    │
│  │  - Entities (Product, Cart, Order)  │    │
│  └────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
       │                    │
       ↓                    ↓
┌─────────────┐      ┌─────────────┐
│  Supabase   │      │   Stripe    │
│  (Auth+DB)  │      │  (Payments) │
└─────────────┘      └─────────────┘
```

---

## 🔧 Technology Stack

### Backend
- **Framework:** ASP.NET Core 9 (Minimal hosting)
- **Language:** C# 13 (.NET 9)
- **Database:** PostgreSQL (Supabase managed)
- **ORM:** Entity Framework Core 9

### Authentication
- **Provider:** Supabase Auth
- **Method:** JWT Bearer tokens
- **Algorithm:** HS256 (symmetric key)

### Payment Processing
- **Provider:** Stripe
- **Integration:** Checkout Sessions + Webhooks
- **Currency:** VND (Vietnamese Dong)

### Validation & Logging
- **Validation:** FluentValidation
- **Logging:** Serilog (structured logging)
- **Compression:** Response compression middleware
- **Rate Limiting:** AspNetCoreRateLimit

---

## 📦 Dependencies

```xml
<PackageReference Include="Microsoft.EntityFrameworkCore.Design" />
<PackageReference Include="Microsoft.AspNetCore.Authentication.JwtBearer" />
<PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" />
<PackageReference Include="FluentValidation.AspNetCore" />
<PackageReference Include="Serilog.AspNetCore" />
<PackageReference Include="Stripe.net" />
<PackageReference Include="AspNetCoreRateLimit" />
<PackageReference Include="Swashbuckle.AspNetCore" />
```

---

## 🔐 Security Features

✅ **Implemented**
- JWT Bearer authentication
- Password complexity validation
- HTTPS enforcement
- CORS policy
- Rate limiting (10 req/s, 100 req/min)
- Stripe webhook signature verification
- SQL injection prevention (EF Core parameterized queries)
- Admin role-based authorization

⚠️ **Recommended Additions**
- Email verification
- Password reset flow
- Refresh token rotation
- 2FA/MFA
- Account lockout
- Audit logging

---

## 🧪 Testing

### Manual Testing
- **HTTP Client:** `auth-test.http` (VS Code REST Client)
- **cURL:** Examples in each documentation file
- **Swagger:** Available at `/swagger` (development only)

### PowerShell Scripts
- **`test-webhook-status.ps1`** - Monitor order status after payment

---

## 📝 Configuration

### Required Settings

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=...;Database=postgres;..."
  },
  "Supabase": {
    "Url": "https://your-project.supabase.co",
    "AnonKey": "your-anon-key"
  },
  "SupabaseAuth": {
    "JwtIssuer": "https://your-project.supabase.co/auth/v1",
    "JwtAudience": "authenticated",
    "JwtSecret": "your-jwt-secret"
  },
  "Stripe": {
    "SecretKey": "sk_test_...",
    "WebhookSecret": "whsec_...",
    "SuccessUrl": "https://...",
    "CancelUrl": "https://..."
  },
  "Cors": {
    "Origins": ["http://localhost:5173"]
  }
}
```

---

## 🐛 Troubleshooting

### Common Issues

**"Supabase:AnonKey missing"**
→ Add Supabase credentials to `appsettings.json`

**401 Unauthorized**
→ Check token is valid and included in `Authorization` header

**Stripe webhook 401**
→ Verify `WebhookSecret` matches Stripe Dashboard or CLI

**Database connection timeout**
→ Check `ConnectionStrings:DefaultConnection` and network access

**Product creation returns 401 (even with token)**
→ Check user has `admin` role in Supabase `app_metadata`

### Debug Endpoints

- **`/api/v1/health`** - Check API + DB connectivity
- **`/api/v1/auth-debug/me`** - Inspect JWT claims
- **Logs** - Check console for structured logs with emoji markers

---

## 📞 Support & Resources

### Documentation Files
- Start here: [`CHECKLIST.md`](CHECKLIST.md)
- Auth: [`AUTH_SETUP.md`](AUTH_SETUP.md)
- Payments: [`STRIPE_WEBHOOK_SETUP.md`](STRIPE_WEBHOOK_SETUP.md)
- Project: [`PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md)

### External Resources
- [ASP.NET Core Docs](https://learn.microsoft.com/en-us/aspnet/core/)
- [Supabase Docs](https://supabase.com/docs)
- [Stripe API Docs](https://stripe.com/docs/api)
- [EF Core Docs](https://learn.microsoft.com/en-us/ef/core/)

---

## 🚀 Deployment

### Local Development
```powershell
dotnet run --project Ecom.Api.csproj
```

### Production (Azure/Railway/Render)
1. Set environment variables (don't commit secrets!)
2. Configure connection strings
3. Run migrations
4. Deploy via CI/CD or manual publish

See deployment guides for specific platforms.

---

## 📄 License & Credits

**Project:** Ecom.Api  
**Purpose:** E-commerce API backend for PRN232 assignment  
**Stack:** ASP.NET Core 9 + PostgreSQL + Supabase + Stripe  
**Date:** October 2025

---

**Need help?** Check the relevant documentation file or review the code comments in `Controllers/`, `Provider/`, and `Infrastructure/`.
