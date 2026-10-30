
-- ============================================================
-- PROJECT: Retail Order Analytics
-- FILE: 01_schema.sql
-- PURPOSE: Create the database and its nine relational tables
-- ============================================================

-- Create the retail analytics database.
CREATE DATABASE retail_order_analytics;

-- Select the database for subsequent operations.
USE retail_order_analytics;


-- ============================================================
-- 1. CUSTOMERS TABLE
-- Stores customer details and registration information.
-- ============================================================

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    city VARCHAR(50),
    state VARCHAR(50),
    signup_date DATE
);


-- ============================================================
-- 2. CATEGORIES TABLE
-- Stores the product categories.
-- ============================================================

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
);


-- ============================================================
-- 3. SUPPLIERS TABLE
-- Stores supplier contact and delivery lead-time details.
-- ============================================================

CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100) UNIQUE,
    city VARCHAR(50),
    supplier_region VARCHAR(50),
    lead_time_days INT NOT NULL DEFAULT 7
);


-- ============================================================
-- 4. PRODUCTS TABLE
-- Stores product, pricing, inventory, and supplier details.
-- Includes foreign keys to categories and suppliers.
-- ============================================================

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    supplier_id INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL DEFAULT 10,
    product_status VARCHAR(20) NOT NULL DEFAULT 'Active',

    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id)
        REFERENCES categories(category_id),

    CONSTRAINT fk_products_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES suppliers(supplier_id)
);


-- ============================================================
-- 5. ORDERS TABLE
-- Stores customer orders and shipping destinations.
-- Includes a foreign key to customers.
-- ============================================================

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    shipping_city VARCHAR(50),
    shipping_state VARCHAR(50),

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


-- ============================================================
-- 6. ORDER ITEMS TABLE
-- Stores individual products purchased in each order.
-- Includes quantity and discount validation constraints.
-- ============================================================

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_percent DECIMAL(5,2) NOT NULL DEFAULT 0,

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    CONSTRAINT chk_order_items_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_order_items_discount
        CHECK (discount_percent >= 0 AND discount_percent <= 100)
);


-- ============================================================
-- 7. PAYMENTS TABLE
-- Stores payment transactions and their statuses.
-- Includes a foreign key to orders.
-- ============================================================

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(30) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    transaction_reference VARCHAR(100) UNIQUE,

    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT chk_payments_amount
        CHECK (amount > 0)
);


-- ============================================================
-- 8. SHIPMENTS TABLE
-- Stores courier, tracking, and delivery information.
-- Includes a foreign key to orders.
-- ============================================================

CREATE TABLE shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    courier_name VARCHAR(100),
    tracking_number VARCHAR(100) UNIQUE,
    shipment_date DATE,
    estimated_delivery_date DATE,
    actual_delivery_date DATE,
    shipment_status VARCHAR(30) NOT NULL DEFAULT 'Preparing',

    CONSTRAINT fk_shipments_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);


-- ============================================================
-- 9. RETURNS TABLE
-- Stores returned products, reasons, refunds, and statuses.
-- Includes a foreign key to order_items.
-- ============================================================

CREATE TABLE returns (
    return_id INT AUTO_INCREMENT PRIMARY KEY,
    order_item_id INT NOT NULL,
    return_date DATE NOT NULL,
    return_quantity INT NOT NULL,
    return_reason VARCHAR(255),
    refund_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    return_status VARCHAR(30) NOT NULL DEFAULT 'Requested',

    CONSTRAINT fk_returns_order_item
        FOREIGN KEY (order_item_id)
        REFERENCES order_items(order_item_id),

    CONSTRAINT chk_returns_quantity
        CHECK (return_quantity > 0),

    CONSTRAINT chk_returns_refund
        CHECK (refund_amount >= 0)
);
