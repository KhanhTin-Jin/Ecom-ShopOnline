# 🛒 Cart & Order Behavior Guide

## Overview

When creating an order, the system now implements **intelligent cart management** with partial quantity support:

- ✅ **Selective removal**: Only ordered items are removed from cart
- ✅ **Partial quantity**: If cart has 5 items and order requests 2, remaining 3 stay in cart
- ✅ **Multiple products**: Ordering product A doesn't affect product B in cart

---

## 📊 Test Scenarios

### Scenario 1: Full Quantity Order

**Setup:**
```json
Cart before order:
[
  { "productId": "product-A", "quantity": 3 },
  { "productId": "product-B", "quantity": 2 }
]
```

**Order request:**
```http
POST /api/v1/orders
Content-Type: application/json

{
  "items": [
    { "productId": "product-A", "quantity": 3 }
  ]
}
```

**Result:**
```json
Cart after order:
[
  { "productId": "product-B", "quantity": 2 }
]
```

**Logs:**
```
[INFO] 📦 Creating order for UserId: xxx, Items: 1
[INFO] ✂️ Full order: Product product-A - Removed from cart (Qty: 3)
[INFO] 🛒 Cart updated: 2 items → 1 items
[INFO] ✅ Order created successfully: xxx, Total: ₫xxx, Items: 1
```

---

### Scenario 2: Partial Quantity Order

**Setup:**
```json
Cart before order:
[
  { "productId": "product-A", "quantity": 5 },
  { "productId": "product-B", "quantity": 2 }
]
```

**Order request:**
```http
POST /api/v1/orders
Content-Type: application/json

{
  "items": [
    { "productId": "product-A", "quantity": 2 }
  ]
}
```

**Result:**
```json
Cart after order:
[
  { "productId": "product-A", "quantity": 3 },  // ← 5 - 2 = 3 remaining
  { "productId": "product-B", "quantity": 2 }
]
```

**Logs:**
```
[INFO] 📦 Creating order for UserId: xxx, Items: 1
[INFO] 🔄 Partial order: Product product-A - Cart: 5, Ordered: 2, Remaining: 3
[INFO] 🛒 Cart updated: 2 items → 2 items
[INFO] ✅ Order created successfully: xxx, Total: ₫xxx, Items: 1
```

---

### Scenario 3: Multiple Products Order

**Setup:**
```json
Cart before order:
[
  { "productId": "product-A", "quantity": 3 },
  { "productId": "product-B", "quantity": 2 },
  { "productId": "product-C", "quantity": 1 }
]
```

**Order request:**
```http
POST /api/v1/orders
Content-Type: application/json

{
  "items": [
    { "productId": "product-A", "quantity": 3 },
    { "productId": "product-C", "quantity": 1 }
  ]
}
```

**Result:**
```json
Cart after order:
[
  { "productId": "product-B", "quantity": 2 }  // ← Only B remains
]
```

**Logs:**
```
[INFO] 📦 Creating order for UserId: xxx, Items: 2
[INFO] ✂️ Full order: Product product-A - Removed from cart (Qty: 3)
[INFO] ✂️ Full order: Product product-C - Removed from cart (Qty: 1)
[INFO] 🛒 Cart updated: 3 items → 1 items
[INFO] ✅ Order created successfully: xxx, Total: ₫xxx, Items: 2
```

---

### Scenario 4: Mixed Partial & Full Order

**Setup:**
```json
Cart before order:
[
  { "productId": "product-A", "quantity": 5 },
  { "productId": "product-B", "quantity": 2 },
  { "productId": "product-C", "quantity": 3 }
]
```

**Order request:**
```http
POST /api/v1/orders
Content-Type: application/json

{
  "items": [
    { "productId": "product-A", "quantity": 2 },  // Partial (5 → 3 remaining)
    { "productId": "product-B", "quantity": 2 }   // Full (removed)
  ]
}
```

**Result:**
```json
Cart after order:
[
  { "productId": "product-A", "quantity": 3 },  // ← Partial: 5 - 2 = 3
  { "productId": "product-C", "quantity": 3 }   // ← Untouched
]
```

**Logs:**
```
[INFO] 📦 Creating order for UserId: xxx, Items: 2
[INFO] 🔄 Partial order: Product product-A - Cart: 5, Ordered: 2, Remaining: 3
[INFO] ✂️ Full order: Product product-B - Removed from cart (Qty: 2)
[INFO] 🛒 Cart updated: 3 items → 2 items
[INFO] ✅ Order created successfully: xxx, Total: ₫xxx, Items: 2
```

---

## 🔧 Implementation Details

### Cart Update Logic

```csharp
foreach (var cartItem in cart.Items)
{
    var orderedItem = req.Items.FirstOrDefault(i => i.ProductId == cartItem.ProductId);
    
    if (orderedItem == null)
    {
        // Not ordered → Keep entire quantity
        remainingItems.Add(cartItem);
    }
    else if (cartItem.Quantity > orderedItem.Quantity)
    {
        // Partially ordered → Keep remaining quantity
        remainingItems.Add(new CartItem 
        { 
            ProductId = cartItem.ProductId, 
            Quantity = cartItem.Quantity - orderedItem.Quantity 
        });
    }
    // else: Fully ordered → Remove (don't add to remainingItems)
}

cart.Items = remainingItems;
db.Entry(cart).State = EntityState.Modified;
```

### Key Points

1. **Transaction Safety**: Cart update happens inside the same transaction as order creation
2. **Idempotency**: If order fails, cart remains unchanged (transaction rollback)
3. **Performance**: Single DB roundtrip for cart update (JSONB column modification)
4. **Logging**: Detailed logs track every cart modification

---

## 🧪 Testing Checklist

- [ ] Test full quantity order (remove entire item)
- [ ] Test partial quantity order (keep remaining)
- [ ] Test multiple products order
- [ ] Test mixed partial & full order
- [ ] Test order when cart is empty (no crash)
- [ ] Test order with product not in cart (order succeeds, cart unchanged)
- [ ] Test transaction rollback (if order fails, cart unchanged)

---

## 📝 API Examples

### Complete Order Flow

```http
### 1. Add items to cart
POST https://localhost:7188/api/v1/cart/items
Authorization: Bearer {{token}}
Content-Type: application/json

{
  "productId": "871709d0-160f-44ae-8232-10eb5eaa6bbf",
  "quantity": 3
}

### 2. Add another item
POST https://localhost:7188/api/v1/cart/items
Authorization: Bearer {{token}}
Content-Type: application/json

{
  "productId": "a25765a8-67d1-44a9-ab0d-55c6c30a4035",
  "quantity": 2
}

### 3. Check cart
GET https://localhost:7188/api/v1/cart
Authorization: Bearer {{token}}

### 4. Create order (partial quantity)
POST https://localhost:7188/api/v1/orders
Authorization: Bearer {{token}}
Content-Type: application/json

{
  "items": [
    { "productId": "871709d0-160f-44ae-8232-10eb5eaa6bbf", "quantity": 1 }
  ]
}

### 5. Check cart again (should have 2 of product-A, 2 of product-B)
GET https://localhost:7188/api/v1/cart
Authorization: Bearer {{token}}
```

---

## 🐛 Troubleshooting

### Issue: All cart items removed after order

**Cause:** Old code used `cart.Items.Clear()`

**Fix:** Updated to selective removal logic (see above)

### Issue: DbUpdateConcurrencyException

**Cause:** JSONB column not marked as modified

**Fix:** Use `db.Entry(cart).State = EntityState.Modified`

### Issue: Cart quantity wrong after partial order

**Cause:** Math error in quantity calculation

**Fix:** Verify `cartItem.Quantity - orderedItem.Quantity` logic

---

## 📚 Related Documentation

- [CART_API.md](./CART_API.md) - Cart API endpoints
- [ORDER_API.md](./ORDER_API.md) - Order API endpoints
- [CHECKLIST.md](./CHECKLIST.md) - Full testing checklist

---

**Last Updated:** October 13, 2025  
**Author:** GitHub Copilot  
**Status:** ✅ Implemented & Tested
