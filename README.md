# API Documentation – Flower Shop

## Overview

This API supports a flower shop application, with separate modules for customers
(iOS/mobile) and admin dashboard. It follows RESTful conventions and is built using
Ruby on Rails as a JSON-only API backend.

## Authentication

This API uses **JWT (JSON Web Token)** for authentication.
All requests to protected endpoints must include a valid token.

● **Login Endpoint**:
POST /login
Required params: email, password

**Response** :
{
"token": "your.jwt.token.here"
}

**Usage** :
Include the token in the Authorization header:
Authorization: Bearer your.jwt.token.here

**Roles** :
● **customer** : regular user placing orders
● **admin** : dashboard access and order management

## Data Models & Relationships

#### General Flow

User → Cart → CartItems → Product
User → BillingInfo → Orders → OrderItems → Product

**User**
● Has one cart
● Has one billing info (saved for reuse)
● Has many orders

**Cart and CartItem**
● A cart belongs to a user
● CartItems store the product and quantity added by the user
● Each CartItem links to a Product and belongs to one cart

**BillingInfo**
● Contains full billing data (name, address, phone, etc.)
● Used when creating an order
● Saved to user profile for future orders

**Order and OrderItem**
● An Order belongs to a user and stores a snapshot of billing info at the time of
order
● Has many OrderItems, each referencing a Product, its quantity, and price
● Products' stock is reduced upon order placement
● Orders have statuses (e.g., pending, delivered, cancelled)


## Modules

### 1. MarketPlace Module – Customers (Mobile App)

#### Products
● **GET** /products: List all active products
● **GET** /products/:id: Show details for a single product

**Tech stack:**
● Controller: MarketPlace::ProductsController
● Serializer: MarketPlace::ProductSerializer
● Uploads: Cloudinary via ActiveStorage

**Rationale:**
Customers browse products, so it only exposes index and show. Admin handles full
CRUD.

#### Cart
● **GET** /cart: Retrieve current user's cart and items
● **DELETE** /cart: Empty the cart
● **POST** /cart_items: Add a product to cart (product_id, optional quantity)
● **PUT** /cart_items/:product_id: Update quantity for a specific product
**DELETE** /cart_items/:product_id: Remove product from cart

**Tech stack:**
● Cart, CartItem models
● Controllers: MarketPlace::CartController, CartItemsController
● Serializer: MarketPlace::CartItemSerializer

**Rationale:**
It used product_id instead of cart item ID for better frontend mapping. Quantity logic
handles overstock and defaults.

#### Orders
● **POST** /orders: Place an order using billing info + cart contents
● **GET** /orders: List current user’s orders

**Tech stack:**
● Order, OrderItem, BillingInfo
● Controller: MarketPlace::OrdersController
Serializer: MarketPlace::OrderSerializer

**Key design:**
● Snapshot of BillingInfo is saved in Order
● If user has no billing_info, it's saved automatically during the first order

### 2. Admin Module – Dashboard (Web App)

#### Products
● **GET** /admin/products: List all products
● **POST** /admin/products: Create new product
● **PATCH** /admin/products/:id/toggle_status: Activate/deactivate
● **PUT/PATCH/DELETE** : Full CRUD support

#### Orders
● **GET** /admin/orders: List all orders (with filtering: ?state=pending)
● **PATCH** /admin/orders/:id: Update order status

**Tech stack:**
● Controller: Admin::OrdersController
● Live updates: via **ActionCable** (WebSockets-based)
● Serializer: Admin::OrderSerializer

**Design Reasoning:**
Admin doesn’t touch carts; they only manage placed orders and product lifecycle.

## Validations & Security

```
● All routes use JWT authentication via Devise.
● customer-only routes scoped with role-checks.
● Stock validation during cart/order creation.
● BillingInfo associated directly with User, but also copied into orders.
```
## Future Improvements

● Email confirmation for orders
● Invoice generation (PDF)
● Add payment provider integration (In App Purchasing for IOS)
● Support discount codes and promo campaigns
● Estimated delivery times & real-time tracking
● Support multiple shipping addresses per user

You can explore and test all endpoints via this Postman Collection, attached to the email.
It contains grouped requests by module (Cart, Orders, Products, etc.) and includes
example request bodies and authentication headers.


API Documentation made by Oana Codruta
Istoc.


