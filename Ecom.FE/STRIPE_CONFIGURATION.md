# 🔐 Stripe Payment Configuration

## 📋 Environment Variables for Backend (.NET)

Khi deploy backend lên production (Render/Azure/AWS), bạn cần add các environment variables sau:

### **Required Stripe Configuration**

```bash
# Stripe API Keys
STRIPE_SECRET_KEY=sk_live_xxxxxxxxxxxxxxxxxxxxx
STRIPE_PUBLISHABLE_KEY=pk_live_xxxxxxxxxxxxxxxxxxxxx

# Stripe Webhook Secret (for production webhook endpoint)
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxxxxxxx

# Payment Success & Cancel URLs
STRIPE_SUCCESS_URL=https://your-frontend-domain.com/payment/success?orderId={orderId}
STRIPE_CANCEL_URL=https://your-frontend-domain.com/payment/fail?orderId={orderId}&reason=payment_cancelled
```

---

## 🌐 Frontend URLs (Đã có sẵn)

Frontend của bạn đã có 2 trang xử lý payment:

### ✅ **Payment Success Page**
- **Route:** `/payment/success`
- **File:** `src/pages/PaymentSuccessPage.tsx`
- **URL Example:** `https://your-frontend.com/payment/success?orderId=123`
- **Features:**
  - ✅ Hiển thị success icon
  - ✅ Hiển thị order ID
  - ✅ Button "View My Orders"
  - ✅ Button "Continue Shopping"

### ❌ **Payment Fail Page**
- **Route:** `/payment/fail`
- **File:** `src/pages/PaymentFailPage.tsx`
- **URL Example:** `https://your-frontend.com/payment/fail?orderId=123&reason=insufficient_funds`
- **Features:**
  - ⚠️ Hiển thị error icon
  - ⚠️ Hiển thị lý do fail
  - 🔄 Button "Try Again"
  - 🛒 Button "Back to Cart"
  - 🛍️ Button "Continue Shopping"

---

## 🔧 Backend Configuration (appsettings.json)

```json
{
  "Stripe": {
    "SecretKey": "sk_test_xxxxx",
    "PublishableKey": "pk_test_xxxxx",
    "WebhookSecret": "whsec_xxxxx",
    "SuccessUrl": "http://localhost:5174/payment/success?orderId={orderId}",
    "CancelUrl": "http://localhost:5174/payment/fail?orderId={orderId}&reason=payment_cancelled"
  }
}
```

**Environment Variables Override:**
```bash
Stripe__SecretKey=sk_live_xxxxx
Stripe__PublishableKey=pk_live_xxxxx
Stripe__WebhookSecret=whsec_xxxxx
Stripe__SuccessUrl=https://your-frontend.com/payment/success?orderId={orderId}
Stripe__CancelUrl=https://your-frontend.com/payment/fail?orderId={orderId}&reason=payment_cancelled
```

---

## 🚀 Deployment Steps

### 1️⃣ **Deploy Frontend (Vercel/Netlify)**

Sau khi deploy frontend, bạn sẽ có URL như:
- `https://your-app.vercel.app`
- `https://your-app.netlify.app`

### 2️⃣ **Update Backend Environment Variables**

Vào Render/Azure/AWS console và set:

```bash
# Production URLs
STRIPE_SUCCESS_URL=https://your-app.vercel.app/payment/success?orderId={orderId}
STRIPE_CANCEL_URL=https://your-app.vercel.app/payment/fail?orderId={orderId}&reason=payment_cancelled

# Stripe Keys (get from Stripe Dashboard)
STRIPE_SECRET_KEY=sk_live_xxxxx
STRIPE_PUBLISHABLE_KEY=pk_live_xxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxx
```

### 3️⃣ **Configure Stripe Webhook**

1. Vào [Stripe Dashboard](https://dashboard.stripe.com/webhooks)
2. Click "Add endpoint"
3. URL: `https://your-backend.render.com/api/v1/webhook`
4. Events to listen:
   - `checkout.session.completed`
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
5. Copy webhook secret → add vào `STRIPE_WEBHOOK_SECRET`

---

## 🔍 Testing Payment Flow

### **Local Testing:**
```bash
# Frontend
http://localhost:5174/payment/success?orderId=test-123

# Backend (Test Mode)
Stripe__SuccessUrl=http://localhost:5174/payment/success?orderId={orderId}
Stripe__CancelUrl=http://localhost:5174/payment/fail?orderId={orderId}&reason=test
```

### **Production Testing:**
1. Thêm sản phẩm vào cart
2. Checkout → redirect to Stripe
3. Nhập test card: `4242 4242 4242 4242`
4. Hoàn tất payment → redirect về `/payment/success`

---

## 📝 Environment Variable Template

Copy template này vào Render/Azure environment variables:

```bash
# ===== STRIPE CONFIGURATION =====
STRIPE_SECRET_KEY=sk_live_51xxxxxxxxxxxxxxxxxxxxx
STRIPE_PUBLISHABLE_KEY=pk_live_51xxxxxxxxxxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxxxxxxx

# ===== FRONTEND URLs =====
STRIPE_SUCCESS_URL=https://your-frontend.vercel.app/payment/success?orderId={orderId}
STRIPE_CANCEL_URL=https://your-frontend.vercel.app/payment/fail?orderId={orderId}&reason=payment_cancelled

# ===== OTHER SETTINGS =====
FRONTEND_ORIGIN=https://your-frontend.vercel.app
```

---

## ⚠️ Important Notes

1. **{orderId} placeholder**: Backend sẽ tự động replace `{orderId}` bằng actual order ID
2. **URL Encoding**: Đảm bảo URLs không có spaces hay special characters
3. **HTTPS Required**: Production phải dùng HTTPS (Stripe yêu cầu)
4. **Test vs Live Keys**: 
   - Test: `sk_test_xxx` (cho development)
   - Live: `sk_live_xxx` (cho production)

---

## 🎯 Quick Reference

| Environment | Frontend URL | Backend URL |
|-------------|--------------|-------------|
| **Development** | `http://localhost:5174` | `http://localhost:5000` |
| **Production** | `https://your-app.vercel.app` | `https://your-backend.render.com` |

### Success URL Pattern:
```
{FRONTEND_URL}/payment/success?orderId={orderId}
```

### Cancel/Fail URL Pattern:
```
{FRONTEND_URL}/payment/fail?orderId={orderId}&reason=payment_cancelled
```

---

## 📞 Support

- Stripe Docs: https://stripe.com/docs/payments/checkout
- Test Cards: https://stripe.com/docs/testing
- Webhook Testing: https://stripe.com/docs/webhooks/test

---

✅ Sau khi setup xong, payment flow sẽ hoạt động như sau:
1. User checkout từ cart
2. Backend tạo Stripe session với success_url & cancel_url
3. User redirect sang Stripe payment page
4. User hoàn tất payment:
   - ✅ Success → redirect về `/payment/success?orderId=xxx`
   - ❌ Cancel/Fail → redirect về `/payment/fail?orderId=xxx&reason=xxx`
5. Stripe gửi webhook event về backend
6. Backend update order status → User thấy order đã paid
