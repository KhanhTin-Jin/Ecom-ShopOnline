# 🎯 Frontend Build Prompt - E-commerce Clothing Store

## 📋 Executive Summary

Build a **Vite + React SPA** for an e-commerce clothing store with:
- **Authentication**: Supabase Auth (email/password)
- **Backend**: .NET 9 REST API (already deployed)
- **Features**: Product browsing, cart, checkout, orders, admin CRUD
- **Styling**: Tailwind CSS / Material-UI
- **State**: TanStack Query + Context API
- **Routing**: React Router v6
- **Deployment**: Vercel/Netlify

---

## 🎯 Goals & Success Metrics

### Goals
1. **G1**: Allow users to browse, search products, and add to cart easily on all devices
2. **G2**: Support quick checkout, order history display; CRUD products for authenticated admin users
3. **G3**: Stable Supabase Auth integration; call .NET API via HTTPS with route/UI protection based on auth state

### Objectives (Measurable)
- **O1**: First contentful paint (LCP) < 2.5s on 4G; Time to Interactive < 3s (Home page)
- **O2**: Add-to-cart conversion rate > 10% of product view sessions in MVP phase
- **O3**: 100% of main flows have clear status feedback (loading/error/success) and pass QA checklist
- **O4**: Complete MVP in 2-3 weeks: Home, Product Detail, Cart, Checkout, Orders, Auth, basic CRUD

---

## 👥 User Personas

### 1. Guest User
- **Needs**: Quick product viewing, images, prices; add to cart (local) before signup/login
- **Behavior**: Browse on mobile; sensitive to speed & ease of use

### 2. Registered Shopper
- **Needs**: Sync cart, place orders, track order history; reliable experience
- **Behavior**: Compare products, return to previous cart/orders

### 3. Admin/Manager
- **Needs**: CRUD products (name, description, price, image); show/hide buttons by role; safe operations (confirm delete)
- **Behavior**: Works on desktop, prioritizes efficiency & accuracy

---

## 🔌 Backend API Specification

### Base URL
```
Production: https://ecommerce-ej3l.onrender.com
Development: http://localhost:7188 (if running locally)
```

### Authentication
- **Method**: JWT Bearer token from Supabase Auth
- **Header**: `Authorization: Bearer <access_token>`
- **Get Token**: Use Supabase SDK `session.access_token`

### API Endpoints

#### **Authentication (Supabase Auth - via Backend proxy)**
```http
POST /api/v1/auth/register
Content-Type: application/json
{
  "email": "user@example.com",
  "password": "Password123!",
  "fullName": "John Doe"
}
Response: {
  "accessToken": "eyJ...",
  "refreshToken": "v1.MQ...",
  "expiresIn": 3600,
  "tokenType": "bearer",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "fullName": "John Doe",
    "createdAt": "2025-10-14T00:00:00Z"
  }
}

POST /api/v1/auth/login
Content-Type: application/json
{
  "email": "user@example.com",
  "password": "Password123!"
}
Response: Same as register

POST /api/v1/auth/logout
Authorization: Bearer <token>
Response: 204 No Content

GET /api/v1/auth/me
Authorization: Bearer <token>
Response: {
  "id": "uuid",
  "email": "user@example.com",
  "fullName": "John Doe",
  "appRole": "admin" // optional, for admin users
}
```

#### **Products (Public endpoints for GET, Admin for CUD)**
```http
GET /api/v1/products?page=1&pageSize=12&sortBy=name&sortOrder=asc
Response: {
  "items": [
    {
      "id": "uuid",
      "name": "Product Name",
      "description": "Description",
      "price": 299000,
      "imageUrl": "https://...",
      "createdAt": "2025-10-14T00:00:00Z"
    }
  ],
  "totalCount": 50,
  "page": 1,
  "pageSize": 12
}

GET /api/v1/products/{id}
Response: {
  "id": "uuid",
  "name": "Product Name",
  "description": "Full description...",
  "price": 299000,
  "imageUrl": "https://...",
  "createdBy": "Admin Name",
  "createdAt": "2025-10-14T00:00:00Z"
}

POST /api/v1/products (Admin only)
Authorization: Bearer <token>
Content-Type: application/json
{
  "name": "New Product",
  "description": "Description",
  "price": 299000,
  "imageUrl": "https://..."
}
Response: 201 Created

PUT /api/v1/products/{id} (Admin only)
Authorization: Bearer <token>
Content-Type: application/json
{
  "name": "Updated Name",
  "description": "Updated description",
  "price": 350000,
  "imageUrl": "https://..."
}
Response: 204 No Content

DELETE /api/v1/products/{id} (Admin only)
Authorization: Bearer <token>
Response: 204 No Content
```

#### **Cart (Authenticated users only)**
```http
GET /api/v1/cart
Authorization: Bearer <token>
Response: {
  "items": [
    {
      "productId": "uuid",
      "name": "Product Name",
      "imageUrl": "https://...",
      "price": 299000,
      "quantity": 2,
      "lineTotal": 598000
    }
  ],
  "totalAmount": 598000
}

POST /api/v1/cart/items
Authorization: Bearer <token>
Content-Type: application/json
{
  "productId": "uuid",
  "quantity": 1
}
Response: Returns updated cart (same as GET /cart)

PUT /api/v1/cart/items/{productId}
Authorization: Bearer <token>
Content-Type: application/json
{
  "quantity": 3
}
Response: Returns updated cart

DELETE /api/v1/cart/items/{productId}
Authorization: Bearer <token>
Response: Returns updated cart

DELETE /api/v1/cart
Authorization: Bearer <token>
Response: { "message": "Cart cleared" }
```

#### **Orders (Authenticated users only)**
```http
GET /api/v1/orders
Authorization: Bearer <token>
Response: {
  "items": [
    {
      "id": "uuid",
      "products": [
        {
          "productId": "uuid",
          "productName": "Product Name",
          "quantity": 2,
          "unitPrice": 299000,
          "imageUrl": "https://..."
        }
      ],
      "totalAmount": 598000,
      "status": "pending",
      "createdAt": "2025-10-14T00:00:00Z"
    }
  ],
  "totalCount": 5,
  "page": 1,
  "pageSize": 10
}

GET /api/v1/orders/{id}
Authorization: Bearer <token>
Response: Single order object

POST /api/v1/orders
Authorization: Bearer <token>
Content-Type: application/json
{
  "items": [
    {
      "productId": "uuid",
      "quantity": 2
    }
  ]
}
Response: 201 Created, returns order object
```

#### **Payments (Optional - Stripe integration)**
```http
POST /api/v1/payments/create
Authorization: Bearer <token>
Content-Type: application/json
{
  "orderId": "uuid"
}
Response: {
  "checkoutUrl": "https://checkout.stripe.com/..."
}
```

#### **Health Check**
```http
GET /api/v1/health
Response: {
  "status": "Healthy",
  "timestamp": "2025-10-14T00:00:00Z"
}
```

---

## 🎨 Frontend Technical Requirements

### Tech Stack
```json
{
  "runtime": "Vite 5.x",
  "framework": "React 18.x",
  "router": "react-router-dom ^6.20",
  "state": ["@tanstack/react-query ^5.0", "Context API"],
  "auth": "@supabase/supabase-js ^2.39",
  "styling": "tailwindcss ^3.4 OR @mui/material ^5.15",
  "http": "axios ^1.6",
  "forms": "react-hook-form ^7.49",
  "validation": "zod ^3.22",
  "deployment": "Vercel OR Netlify"
}
```

### Project Structure
```
src/
├── api/
│   ├── client.ts          # Axios instance with auth interceptor
│   ├── products.ts        # Product API calls
│   ├── cart.ts            # Cart API calls
│   ├── orders.ts          # Orders API calls
│   └── auth.ts            # Auth API calls (optional proxy)
├── components/
│   ├── common/
│   │   ├── Header.tsx     # Navigation with auth state
│   │   ├── Footer.tsx
│   │   ├── LoadingSpinner.tsx
│   │   └── ErrorBoundary.tsx
│   ├── products/
│   │   ├── ProductCard.tsx
│   │   ├── ProductList.tsx
│   │   ├── ProductDetail.tsx
│   │   └── ProductForm.tsx (Admin)
│   ├── cart/
│   │   ├── CartItem.tsx
│   │   └── CartSummary.tsx
│   └── orders/
│       ├── OrderList.tsx
│       └── OrderDetail.tsx
├── contexts/
│   ├── AuthContext.tsx    # Supabase auth state
│   └── CartContext.tsx    # Local cart (optional)
├── hooks/
│   ├── useAuth.ts
│   ├── useProducts.ts     # TanStack Query hooks
│   ├── useCart.ts
│   └── useOrders.ts
├── pages/
│   ├── HomePage.tsx
│   ├── ProductsPage.tsx
│   ├── ProductDetailPage.tsx
│   ├── CartPage.tsx
│   ├── CheckoutPage.tsx
│   ├── OrdersPage.tsx
│   ├── LoginPage.tsx
│   ├── RegisterPage.tsx
│   └── admin/
│       └── ProductManagePage.tsx
├── routes/
│   ├── AppRouter.tsx
│   └── ProtectedRoute.tsx # Auth guard
├── lib/
│   └── supabase.ts        # Supabase client setup
├── types/
│   └── index.ts           # TypeScript interfaces
└── App.tsx
```

---

## 🔐 Authentication Implementation

### Supabase Setup
```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

### Auth Context Pattern
```typescript
// contexts/AuthContext.tsx
import { createContext, useContext, useEffect, useState } from 'react'
import { Session, User } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'

interface AuthContextType {
  session: Session | null
  user: User | null
  loading: boolean
  signIn: (email: string, password: string) => Promise<void>
  signUp: (email: string, password: string, fullName: string) => Promise<void>
  signOut: () => Promise<void>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [session, setSession] = useState<Session | null>(null)
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session)
      setUser(session?.user ?? null)
      setLoading(false)
    })

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        setSession(session)
        setUser(session?.user ?? null)
      }
    )

    return () => subscription.unsubscribe()
  }, [])

  const signIn = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
  }

  const signUp = async (email: string, password: string, fullName: string) => {
    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: { full_name: fullName }
      }
    })
    if (error) throw error
  }

  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  }

  return (
    <AuthContext.Provider value={{ session, user, loading, signIn, signUp, signOut }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (!context) throw new Error('useAuth must be used within AuthProvider')
  return context
}
```

### Protected Route
```typescript
// routes/ProtectedRoute.tsx
import { Navigate, Outlet } from 'react-router-dom'
import { useAuth } from '@/contexts/AuthContext'

export function ProtectedRoute() {
  const { user, loading } = useAuth()

  if (loading) return <LoadingSpinner />
  if (!user) return <Navigate to="/login" replace />

  return <Outlet />
}
```

---

## 🌐 API Client Setup

### Axios Instance with Auth Interceptor
```typescript
// api/client.ts
import axios from 'axios'
import { supabase } from '@/lib/supabase'

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'https://ecommerce-ej3l.onrender.com',
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor: Add auth token
apiClient.interceptors.request.use(async (config) => {
  const { data: { session } } = await supabase.auth.getSession()
  
  if (session?.access_token) {
    config.headers.Authorization = `Bearer ${session.access_token}`
  }
  
  return config
})

// Response interceptor: Handle errors
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Redirect to login or refresh token
      supabase.auth.signOut()
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export default apiClient
```

---

## 📝 Key Features Implementation

### 1. Product List with TanStack Query
```typescript
// hooks/useProducts.ts
import { useQuery } from '@tanstack/react-query'
import apiClient from '@/api/client'

interface Product {
  id: string
  name: string
  description: string
  price: number
  imageUrl: string
  createdAt: string
}

interface ProductsResponse {
  items: Product[]
  totalCount: number
  page: number
  pageSize: number
}

export function useProducts(page = 1, pageSize = 12) {
  return useQuery({
    queryKey: ['products', page, pageSize],
    queryFn: async () => {
      const { data } = await apiClient.get<ProductsResponse>(
        `/api/v1/products?page=${page}&pageSize=${pageSize}`
      )
      return data
    },
  })
}

export function useProduct(id: string) {
  return useQuery({
    queryKey: ['product', id],
    queryFn: async () => {
      const { data } = await apiClient.get<Product>(`/api/v1/products/${id}`)
      return data
    },
    enabled: !!id,
  })
}
```

### 2. Cart Management (Context + API)
```typescript
// hooks/useCart.ts
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import apiClient from '@/api/client'
import { useAuth } from '@/contexts/AuthContext'

interface CartItem {
  productId: string
  name: string
  imageUrl: string
  price: number
  quantity: number
  lineTotal: number
}

interface Cart {
  items: CartItem[]
  totalAmount: number
}

export function useCart() {
  const { user } = useAuth()
  const queryClient = useQueryClient()

  const { data: cart, isLoading } = useQuery({
    queryKey: ['cart'],
    queryFn: async () => {
      const { data } = await apiClient.get<Cart>('/api/v1/cart')
      return data
    },
    enabled: !!user,
  })

  const addToCartMutation = useMutation({
    mutationFn: async ({ productId, quantity }: { productId: string; quantity: number }) => {
      const { data } = await apiClient.post('/api/v1/cart/items', { productId, quantity })
      return data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['cart'] })
    },
  })

  const updateQuantityMutation = useMutation({
    mutationFn: async ({ productId, quantity }: { productId: string; quantity: number }) => {
      const { data } = await apiClient.put(`/api/v1/cart/items/${productId}`, { quantity })
      return data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['cart'] })
    },
  })

  const removeItemMutation = useMutation({
    mutationFn: async (productId: string) => {
      await apiClient.delete(`/api/v1/cart/items/${productId}`)
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['cart'] })
    },
  })

  return {
    cart,
    isLoading,
    addToCart: addToCartMutation.mutate,
    updateQuantity: updateQuantityMutation.mutate,
    removeItem: removeItemMutation.mutate,
  }
}
```

### 3. Order Flow
```typescript
// hooks/useOrders.ts
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import apiClient from '@/api/client'

interface CreateOrderRequest {
  items: Array<{ productId: string; quantity: number }>
}

export function useOrders(page = 1) {
  return useQuery({
    queryKey: ['orders', page],
    queryFn: async () => {
      const { data } = await apiClient.get(`/api/v1/orders?page=${page}`)
      return data
    },
  })
}

export function useCreateOrder() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (request: CreateOrderRequest) => {
      const { data } = await apiClient.post('/api/v1/orders', request)
      return data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['orders'] })
      queryClient.invalidateQueries({ queryKey: ['cart'] })
    },
  })
}
```

### 4. Admin Product CRUD
```typescript
// hooks/useProductMutations.ts (Admin only)
import { useMutation, useQueryClient } from '@tanstack/react-query'
import apiClient from '@/api/client'

interface CreateProductRequest {
  name: string
  description: string
  price: number
  imageUrl: string
}

export function useCreateProduct() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (data: CreateProductRequest) => {
      const response = await apiClient.post('/api/v1/products', data)
      return response.data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] })
    },
  })
}

export function useUpdateProduct() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({ id, data }: { id: string; data: CreateProductRequest }) => {
      await apiClient.put(`/api/v1/products/${id}`, data)
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['products'] })
      queryClient.invalidateQueries({ queryKey: ['product', variables.id] })
    },
  })
}

export function useDeleteProduct() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (id: string) => {
      await apiClient.delete(`/api/v1/products/${id}`)
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] })
    },
  })
}
```

---

## 🎨 UI/UX Requirements

### Responsive Design
- **Mobile-first**: ≥320px viewport
- **Breakpoints**: sm:640px, md:768px, lg:1024px, xl:1280px
- **Grid layouts**: 1 col (mobile) → 2-3 cols (tablet) → 4 cols (desktop)

### Loading States
- **Skeleton screens** for product list/detail
- **Spinner** for form submissions
- **Progress bar** for image uploads

### Error Handling
- **Toast/Snackbar** for API errors (4xx, 5xx)
- **Inline validation** for forms (react-hook-form + zod)
- **Empty states** for no products/orders

### Accessibility
- **Semantic HTML**: `<header>`, `<nav>`, `<main>`, `<footer>`
- **ARIA labels** for interactive elements
- **Keyboard navigation**: Tab order, focus styles
- **Alt text** for images

---

## 🚀 Deployment Configuration

### Environment Variables
```env
# .env.production
VITE_API_URL=https://ecommerce-ej3l.onrender.com
VITE_SUPABASE_URL=https://rioqfyejijcvdteaglzo.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJpb3FmeWVqaWpjdmR0ZWFnbHpvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwNTgyMjYsImV4cCI6MjA3NTYzNDIyNn0.7tNhV8j2NlLjJ-kB6NN_SMhMBXbDpwFTENWRO8X8Vfg
```

### Vercel Deployment
1. Connect GitHub repository
2. Framework: Vite
3. Build Command: `npm run build`
4. Output Directory: `dist`
5. Add environment variables
6. Deploy

### Netlify Deployment
1. Connect GitHub repository
2. Build Command: `npm run build`
3. Publish Directory: `dist`
4. Add environment variables
5. Deploy

---

## ✅ MVP Checklist

### Phase 1: Setup & Auth (Week 1)
- [ ] Initialize Vite + React + TypeScript project
- [ ] Setup Tailwind CSS / Material-UI
- [ ] Install dependencies (react-router, TanStack Query, Supabase, axios)
- [ ] Create project structure
- [ ] Setup Supabase client
- [ ] Implement AuthContext with auth state listener
- [ ] Create Login/Register pages
- [ ] Implement ProtectedRoute
- [ ] Test auth flow (signup → login → logout)

### Phase 2: Products & Cart (Week 2)
- [ ] Implement API client with auth interceptor
- [ ] Create useProducts hook (TanStack Query)
- [ ] Build ProductList component with grid layout
- [ ] Build ProductCard component
- [ ] Create ProductDetailPage
- [ ] Implement Cart context/hooks
- [ ] Build CartPage with item management (add/update/remove)
- [ ] Add toast notifications for user actions
- [ ] Test cart flow (add → update → remove → clear)

### Phase 3: Checkout & Orders (Week 2-3)
- [ ] Create CheckoutPage with order summary
- [ ] Implement useCreateOrder mutation
- [ ] Build OrdersPage with order history
- [ ] Create OrderDetailPage
- [ ] Test order flow (cart → checkout → place order → view orders)
- [ ] Add loading/error states for all API calls

### Phase 4: Admin CRUD (Week 3)
- [ ] Create ProductManagePage
- [ ] Build ProductForm component (create/update)
- [ ] Implement useProductMutations hooks
- [ ] Add role-based UI conditionals (show CRUD only for admin)
- [ ] Add delete confirmation dialog
- [ ] Test CRUD flow (create → update → delete)

### Phase 5: Polish & Deploy
- [ ] Add responsive design refinements
- [ ] Implement skeleton loaders
- [ ] Add empty states
- [ ] Test on mobile/tablet/desktop
- [ ] Run Lighthouse audit (LCP < 2.5s, TTI < 3s)
- [ ] Deploy to Vercel/Netlify
- [ ] Update CORS in backend to allow frontend origin
- [ ] End-to-end testing

---

## 🎯 Success Criteria

**MVP is complete when:**
1. ✅ Users can browse products, add to cart, and checkout
2. ✅ Authenticated users can view order history
3. ✅ Admin users can CRUD products
4. ✅ All API calls have loading/error/success states
5. ✅ Responsive design works on mobile/tablet/desktop
6. ✅ App is deployed and accessible via public URL
7. ✅ Lighthouse score: Performance > 80, Accessibility > 90

---

## 📚 Additional Resources

### Backend API
- **Base URL**: https://ecommerce-ej3l.onrender.com
- **Swagger**: https://ecommerce-ej3l.onrender.com/swagger
- **Health Check**: https://ecommerce-ej3l.onrender.com/api/v1/health

### Documentation
- **Supabase Auth Docs**: https://supabase.com/docs/guides/auth
- **TanStack Query Docs**: https://tanstack.com/query/latest
- **React Router Docs**: https://reactrouter.com/en/main
- **Tailwind CSS Docs**: https://tailwindcss.com/docs

---

## 🚨 Common Pitfalls to Avoid

1. **CORS Issues**: Ensure backend `FRONTEND_ORIGIN` env var is set to your deployed URL
2. **Token Expiry**: Handle 401 errors and refresh tokens automatically
3. **Cart Sync**: Sync local cart with backend after login
4. **Image URLs**: Validate image URLs before displaying
5. **Form Validation**: Use Zod schemas for consistent validation
6. **Error Messages**: Show user-friendly error messages, not raw API errors
7. **Loading States**: Always show loading indicators during API calls
8. **Empty States**: Handle empty product lists, cart, and orders gracefully

---

## 🎉 You're Ready!

Use this prompt to guide your Frontend development. The Backend API is fully functional and deployed at:

**https://ecommerce-ej3l.onrender.com**

Test all endpoints via Swagger before integration:
**https://ecommerce-ej3l.onrender.com/swagger**

Happy coding! 🚀
