# Project Context

## Overview
- **Project**: `Ecom.Api`
- **Platform**: ASP.NET Core 9 (Web API)
- **Primary features**:
  - API v1 endpoints covering products, carts, orders, health, and weather.
  - Server-side cart management, product catalog CRUD, and transactional order creation.
  - Authentication via JWT Bearer tokens (Supabase-compatible).
  - Infrastructure middleware: CORS, response compression, IP rate limiting, Serilog logging, Swagger/OpenAPI.

## Key Folders
| Path | Purpose |
| --- | --- |
| `Controllers/` | API endpoints (`ProductsController`, `CartController`, `OrdersController`, `AuthDebugController`, `HealthController`). |
| `Domain/` | Entity models (`Product`, `Cart`, `Order`). |
| `Dtos/` | Data transfer objects for requests/responses. |
| `Infrastructure/` | `AppDbContext` for EF Core, migrations for PostgreSQL schema. |
| `Helpers/` | Shared utilities like `HttpContextUser`. |
| `Validators/` | FluentValidation validators (e.g., `CreateProductRequestValidator`). |

## Data Layer
- **Database**: PostgreSQL.
- **Entity Framework Core** configuration in `AppDbContext`:
  - JSONB columns for cart/order payloads.
  - Index definitions for product search performance.
- **Migrations** in `Migrations/` track schema changes.

## Middleware Pipeline (Program.cs)
1. Response compression.
2. IP rate limiting using `AspNetCoreRateLimit`.
3. Serilog request logging.
4. Environment-aware Swagger (public in dev, gated in prod).
5. HTTPS redirection.
6. CORS policy `FE` enforcing configured frontend origin.
7. Authentication (JWT Bearer).
8. Authorization (policies/roles).
9. Controller endpoint mapping.

## Authentication & Authorization
- JWT Bearer tokens validated against Supabase issuer/audience with symmetric signing.
- Custom helper `HttpContextUser.UserId` extracts `sub`/`user_id` claims for auditing.
- Admin policy (`Policies.AdminOnly`) enforced for product creation, updates, and deletions.

## Business Flows
- **Products**: CRUD endpoints with pagination, search, sorting on listing.
- **Cart**: Server-side cart persistence per user.
- **Orders**: Creation ensures transactional integrity, references cart data.
- **Health**: `/api/v1/health` returns service readiness probes.

## Logging & Telemetry
- Serilog bootstrap logger plus configuration-driven sinks.
- Request logging active by default; log levels adjustable via `appsettings`.

## Pending Work
- Extend documentation with deployment instructions if needed.
