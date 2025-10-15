# 🔍 Debug Payment Webhook Flow

Hướng dẫn debug để kiểm tra tại sao order status không được cập nhật sau khi thanh toán thành công.

## 📋 Checklist

### 1. Kiểm tra Logs Khi Thanh Toán
Sau khi hoàn thành thanh toán trên Stripe, check terminal logs để tìm:

```
=== WEBHOOK RECEIVED ===
```

**Nếu KHÔNG thấy log này:**
- ❌ Webhook chưa được Stripe gọi
- Kiểm tra Stripe webhook configuration
- Kiểm tra webhook endpoint URL

**Nếu thấy log:**
- ✅ Tiếp tục đọc các logs sau đó

### 2. Phân Tích Logs Chi Tiết

#### A. Signature Verification
```
✅ Webhook signature verified
```
- ✅ OK: Stripe signature hợp lệ
- ❌ FAIL: Check `Stripe:WebhookSecret` trong appsettings.json

#### B. Event Type
```
Event type matched SUCCESS: checkout.session.completed
```
- ✅ OK: Event type đúng
- ⚠️ Nếu là event khác: Webhook bị gọi cho event không liên quan

#### C. Payment Lookup
```
Payment lookup: FOUND, PaymentId: xxx
```
- ✅ OK: Tìm thấy payment record
- ❌ NOT FOUND: `ProviderPaymentId` không match → Check Stripe session ID

#### D. Order Lookup
```
Order found: {OrderId}, Current status: pending
```
- ✅ OK: Tìm thấy order
- ❌ FAIL: Payment không liên kết đúng order

#### E. Status Update
```
📝 Setting order status: pending → paid
💾 Saving changes to database...
✅ Database saved. 2 rows affected
```
- ✅ OK: Status đã được cập nhật
- ❌ 0 rows affected: Database không save được

#### F. Final Status
```
🎉 WEBHOOK PROCESSING COMPLETE. Order {OrderId} final status: paid
```
- ✅ SUCCESS: Webhook processed hoàn toàn

### 3. Kiểm Tra Database Trực Tiếp

```sql
-- Check order status
SELECT "Id", "Status", "TotalAmount", "UpdatedAt" 
FROM orders 
WHERE "Id" = 'your-order-id';

-- Check payment status
SELECT "Id", "OrderId", "Status", "ProviderPaymentId", "UpdatedAt"
FROM payments
WHERE "OrderId" = 'your-order-id';

-- Check webhook events received
SELECT "Id", "PaymentId", "Type", "ProviderEventId", "CreatedAt"
FROM payment_events
ORDER BY "CreatedAt" DESC
LIMIT 10;
```

### 4. Sử Dụng Test Script

```powershell
# Chạy script để monitor order status
.\test-webhook-status.ps1 -OrderId "your-order-id" -Token "your-jwt-token"

# Script sẽ:
# - Check initial order status
# - Cung cấp hướng dẫn tạo payment
# - Tùy chọn monitor status mỗi 5 giây
```

## 🐛 Common Issues

### Issue 1: Webhook Không Được Gọi (404)
**Triệu chứng:**
```
HTTP POST /api/webhook responded 404
```

**Nguyên nhân:**
- Endpoint không tồn tại hoặc route sai

**Giải pháp:**
```csharp
// PaymentsController.cs phải có:
[HttpPost("webhook")]
[HttpPost("/api/webhook")]  // ← Route thứ 2 này quan trọng
public async Task<IActionResult> Webhook(...)
```

### Issue 2: Signature Verification Failed
**Triệu chứng:**
```
❌ Stripe webhook signature verification FAILED
```

**Nguyên nhân:**
- `Stripe:WebhookSecret` sai hoặc thiếu

**Giải pháp:**
1. Vào Stripe Dashboard → Developers → Webhooks
2. Click vào webhook endpoint
3. Copy "Signing secret"
4. Update `appsettings.json`:
```json
"Stripe": {
  "WebhookSecret": "whsec_xxx..."
}
```

### Issue 3: Payment Not Found
**Triệu chứng:**
```
❌ Webhook not mapped to any payment (providerPaymentId: cs_xxx)
```

**Nguyên nhân:**
- Payment record chưa được tạo
- `ProviderPaymentId` không khớp

**Giải pháp:**
- Kiểm tra flow tạo payment:
  1. POST `/api/v1/payments/create` phải thành công
  2. Payment record phải được lưu với `ProviderPaymentId = session.Id`

### Issue 4: Order Status Vẫn Pending
**Triệu chứng:**
- Logs cho thấy webhook processed thành công
- Database vẫn `status = 'pending'`

**Debug:**
1. Check `SaveChangesAsync` có throw exception không
2. Check transaction có commit không
3. Check có process nào khác rollback transaction không

**Giải pháp:**
```csharp
// Đảm bảo không có transaction nào conflict
logger.LogInformation("💾 Saving changes to database...");
var saveResult = await db.SaveChangesAsync(ct);
logger.LogInformation("✅ Database saved. {RowsAffected} rows affected", saveResult);
```

## 🧪 Test Webhook Locally với Stripe CLI

### Cài đặt Stripe CLI
```powershell
scoop install stripe  # hoặc download từ stripe.com/docs/stripe-cli
```

### Forward webhooks to local
```powershell
stripe listen --forward-to https://localhost:7188/api/webhook
```

### Trigger test event
```powershell
# Trigger checkout.session.completed
stripe trigger checkout.session.completed

# Với custom session ID
stripe trigger checkout.session.completed --override checkout_session:id=cs_test_xxx
```

## 📊 Monitoring Dashboard

### Real-time Logs
```powershell
# Watch logs với grep
dotnet run | Select-String "WEBHOOK"

# Hoặc chỉ xem payment-related logs
dotnet run | Select-String "payment|order|webhook" -CaseSensitive:$false
```

### Structured Logging Query (nếu dùng Seq/Elastic)
```
EventType = "WebhookReceived" OR 
EventType = "OrderStatusChanged" OR
EventType = "PaymentStatusChanged"
```

## ✅ Success Indicators

Khi mọi thứ hoạt động đúng, bạn sẽ thấy log sequence như sau:

```
[16:20:14 INF] === WEBHOOK RECEIVED ===
[16:20:14 INF] Webhook payload length: 3809 bytes
[16:20:14 INF] 🔍 [StripeProvider] Parsing webhook...
[16:20:14 INF] ✅ [StripeProvider] Matched checkout.session.completed - Session ID: cs_test_xxx
[16:20:14 INF] ✅ Webhook signature verified. Event ID: evt_xxx, Type: checkout.session.completed
[16:20:14 INF] Payment lookup: FOUND, PaymentId: xxx
[16:20:14 INF] Order found: {OrderId}, Current status: pending
[16:20:14 INF] 🎯 Event type matched SUCCESS: checkout.session.completed
[16:20:14 INF] 📝 Setting order status: pending → paid
[16:20:14 INF] 💾 Saving changes to database...
[16:20:14 INF] ✅ Database saved. 2 rows affected
[16:20:14 INF] 🎉 WEBHOOK PROCESSING COMPLETE. Order {OrderId} final status: paid
```

## 🆘 Still Not Working?

1. **Enable verbose EF logging:**
   ```json
   // appsettings.Development.json
   "Logging": {
     "LogLevel": {
       "Microsoft.EntityFrameworkCore": "Information"
     }
   }
   ```

2. **Check database connection:**
   ```powershell
   # Test PostgreSQL connection
   psql -h db.xxx.supabase.co -U postgres -d postgres
   ```

3. **Verify webhook endpoint accessible:**
   ```powershell
   curl -X POST https://localhost:7188/api/webhook `
        -H "Content-Type: application/json" `
        -d "{}"
   # Expect: 401 Unauthorized (signature missing) - это нормально
   ```

4. **Share logs** để được hỗ trợ thêm
