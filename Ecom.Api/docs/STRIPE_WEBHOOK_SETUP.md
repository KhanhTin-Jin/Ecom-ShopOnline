# 🚀 Quick Setup: Stripe Webhook Local Testing

## Vấn đề hiện tại
```
❌ Stripe webhook signature verification FAILED
The expected signature was not found in the Stripe-Signature header.
```

**Nguyên nhân**: `WebhookSecret` trong config không khớp với webhook endpoint.

---

## ✅ Giải pháp: Dùng Stripe CLI

### Bước 1: Cài đặt Stripe CLI

**Windows (Scoop):**
```powershell
scoop install stripe
```

**Windows (Manual):**
1. Download từ: https://github.com/stripe/stripe-cli/releases/latest
2. Giải nén và add vào PATH

**macOS:**
```bash
brew install stripe/stripe-cli/stripe
```

### Bước 2: Login Stripe

```powershell
stripe login
```

Sẽ mở browser để authenticate. Sau khi xong:
```
✔ Done! The Stripe CLI is configured for [your-account]
```

### Bước 3: Start Webhook Forwarding

**Terminal 1 - Run API:**
```powershell
cd "d:\FPT Fall 2025 Semeter8\PRN232\Assignment2\src\Ecom.Api"
dotnet run
```

**Terminal 2 - Forward Webhooks:**
```powershell
stripe listen --forward-to https://localhost:7188/api/webhook
```

**Output quan trọng:**
```
> Ready! Your webhook signing secret is whsec_1234567890abcdef...
                                          ^^^^^^^^^^^^^^^^^^^^^^^^^^
                                          ← Copy secret này
```

### Bước 4: Update Config

Copy webhook secret từ terminal và paste vào:

**File: `appsettings.Development.json`**
```json
{
  "Stripe": {
    "WebhookSecret": "whsec_1234567890abcdef..."
  }
}
```

### Bước 5: Restart API

Nhấn `Ctrl+C` ở Terminal 1, sau đó:
```powershell
dotnet run
```

---

## 🧪 Test Webhook

### Cách 1: Thanh toán thật qua Checkout

1. Tạo payment:
```bash
POST https://localhost:7188/api/v1/payments/create
Authorization: Bearer your-token
Content-Type: application/json

{
  "orderId": "your-order-id",
  "provider": "stripe"
}
```

2. Mở checkout URL và hoàn thành thanh toán (dùng test card)

3. **Check Terminal 2** (Stripe CLI), sẽ thấy:
```
2025-10-13 16:49:28   --> checkout.session.completed [evt_xxx]
2025-10-13 16:49:28   <-- [200] POST https://localhost:7188/api/webhook [evt_xxx]
```

4. **Check Terminal 1** (API logs), sẽ thấy:
```
[16:49:28 INF] === WEBHOOK RECEIVED ===
[16:49:28 INF] ✅ Webhook signature verified
[16:49:28 INF] 🎯 Event type matched SUCCESS: checkout.session.completed
[16:49:28 INF] 📝 Setting order status: pending → paid
[16:49:28 INF] ✅ Database saved. 2 rows affected
[16:49:28 INF] 🎉 WEBHOOK PROCESSING COMPLETE
```

### Cách 2: Trigger Test Event

**Terminal 3:**
```powershell
# Trigger checkout completed event
stripe trigger checkout.session.completed

# Output:
# Triggering test webhook event for checkout.session.completed
# Received event evt_test_webhook [200]
```

---

## 📊 Verify Order Status

### Option A: Check Database
```sql
SELECT "Id", "Status", "TotalAmount", "UpdatedAt" 
FROM orders 
WHERE "Id" = 'your-order-id';
```

**Expected:** `Status = 'paid'`, `UpdatedAt` recent

### Option B: Use PowerShell Script
```powershell
.\test-webhook-status.ps1 `
    -OrderId "264d3cf8-54dc-4692-897e-62a5ae3e28b3" `
    -Token "your-jwt-token"
```

### Option C: API Call
```bash
GET https://localhost:7188/api/v1/orders/{orderId}
Authorization: Bearer your-token
```

---

## 🐛 Troubleshooting

### Issue: "stripe: command not found"
**Giải pháp:** Stripe CLI chưa được cài hoặc chưa trong PATH
```powershell
# Verify installation
stripe --version
```

### Issue: "Failed to forward request"
**Giải pháp:** API chưa chạy hoặc URL sai
```powershell
# Kiểm tra API đang chạy
curl https://localhost:7188/api/v1/health
```

### Issue: Vẫn 401 Unauthorized
**Giải pháp:** Secret chưa được update hoặc app chưa restart
1. Check `appsettings.Development.json` có `WebhookSecret` đúng không
2. Restart API (`Ctrl+C` → `dotnet run`)
3. Verify config được load:
```powershell
# Add log khi startup
dotnet run | Select-String "Stripe"
```

### Issue: Stripe CLI timeout
**Giải pháp:** Re-authenticate
```powershell
stripe login --interactive
```

---

## 📝 Test Card Numbers

Dùng các test cards sau để test payment:

| Card Number         | Brand      | Result           |
|---------------------|------------|------------------|
| 4242 4242 4242 4242 | Visa       | Success          |
| 4000 0025 0000 3155 | Visa       | 3D Secure        |
| 4000 0000 0000 9995 | Visa       | Declined (funds) |
| 5555 5555 5555 4444 | Mastercard | Success          |

- **Expiry:** Any future date (e.g., `12/34`)
- **CVC:** Any 3 digits (e.g., `123`)
- **ZIP:** Any 5 digits (e.g., `12345`)

---

## 🎯 Expected Flow

```
┌──────────┐        ┌──────────┐        ┌──────────┐
│  Client  │        │ Your API │        │  Stripe  │
└────┬─────┘        └────┬─────┘        └────┬─────┘
     │                   │                   │
     │ POST /payments/create                │
     ├──────────────────>│                   │
     │                   │ Create Session    │
     │                   ├──────────────────>│
     │                   │<──────────────────┤
     │<──────────────────┤  Session ID       │
     │  Checkout URL     │                   │
     │                   │                   │
     │ Complete Payment  │                   │
     ├───────────────────────────────────────>│
     │                   │                   │
     │                   │ Webhook Event     │
     │                   │<──────────────────┤
     │                   │ (checkout.session.completed)
     │                   │                   │
     │                   │ ✅ Verify Signature
     │                   │ ✅ Update Order → paid
     │                   │ ✅ Update Payment → paid
     │                   │                   │
     │                   │ 200 OK            │
     │                   ├──────────────────>│
     │                   │                   │
```

---

## ✅ Success Checklist

- [ ] Stripe CLI installed và authenticated
- [ ] `stripe listen` đang chạy ở Terminal 2
- [ ] `WebhookSecret` đã được update trong `appsettings.Development.json`
- [ ] API đã restart sau khi update config
- [ ] Test payment hoàn thành
- [ ] Webhook event xuất hiện trong Terminal 2 với `[200]` status
- [ ] API logs cho thấy `🎉 WEBHOOK PROCESSING COMPLETE`
- [ ] Order status trong DB là `paid`

---

## 🔗 Useful Links

- [Stripe CLI Docs](https://stripe.com/docs/stripe-cli)
- [Test Webhooks](https://stripe.com/docs/webhooks/test)
- [Test Cards](https://stripe.com/docs/testing)
- [Webhook Events](https://stripe.com/docs/api/events/types)
