CREATE DATABASE retail_order_analytics;
USE retail_order_analytics;
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    city VARCHAR(50),
    state VARCHAR(50),
    signup_date DATE
);
DESCRIBE customers;
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
);
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100) UNIQUE,
    city VARCHAR(50),
    supplier_region VARCHAR(50),
    lead_time_days INT NOT NULL DEFAULT 7
);
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
SHOW TABLES;

INSERT INTO categories (category_name, description)
VALUES
    ('Electronics', 'Electronic devices and accessories'),
    ('Clothing', 'Apparel and fashion products'),
    ('Home & Kitchen', 'Home appliances and kitchen essentials'),
    ('Beauty', 'Beauty and personal care products'),
    ('Sports', 'Sports and fitness equipment');
    
    
INSERT INTO suppliers
    (supplier_name, contact_email, city, supplier_region, lead_time_days)
VALUES
    ('TechSource India', 'sales@techsource.example', 'Pune', 'West', 4),
    ('FashionHub Supplies', 'contact@fashionhub.example', 'Mumbai', 'West', 6),
    ('HomeEssentials Co', 'orders@homeessentials.example', 'Delhi', 'North', 8),
    ('BeautyWorld Distributors', 'sales@beautyworld.example', 'Bengaluru', 'South', 5),
    ('ActiveGear Wholesale', 'info@activegear.example', 'Hyderabad', 'South', 7),
    ('Global Retail Supply', 'support@globalretail.example', 'Kolkata', 'East', 10);
    
    
    
SELECT category_id, category_name
FROM categories;


SELECT supplier_id, supplier_name
FROM suppliers;



INSERT INTO products
    (product_name, category_id, supplier_id, unit_price,
     stock_quantity, reorder_level, product_status)
VALUES
    ('Wireless Headphones', 1, 1, 2499.00, 35, 10, 'Active'),
    ('Smart Watch', 1, 1, 3999.00, 18, 8, 'Active'),
    ('USB-C Charger', 1, 6, 799.00, 50, 15, 'Active'),
    ('Cotton T-Shirt', 2, 2, 599.00, 40, 12, 'Active'),
    ('Denim Jeans', 2, 2, 1499.00, 22, 8, 'Active'),
    ('Running Shoes', 2, 6, 2299.00, 16, 6, 'Active'),
    ('Electric Kettle', 3, 3, 1299.00, 25, 10, 'Active'),
    ('Storage Containers', 3, 3, 499.00, 60, 15, 'Active'),
    ('Face Moisturizer', 4, 4, 699.00, 30, 10, 'Active'),
    ('Sunscreen SPF 50', 4, 4, 899.00, 20, 8, 'Active'),
    ('Yoga Mat', 5, 5, 999.00, 28, 10, 'Active'),
    ('Dumbbell Set', 5, 5, 1799.00, 7, 8, 'Active');
    
    
    
SELECT
    product_id,
    product_name,
    category_id,
    supplier_id,
    unit_price,
    stock_quantity,
    reorder_level
FROM products;



INSERT INTO customers
    (first_name, last_name, email, city, state, signup_date)
VALUES
    ('Aarav', 'Shah', 'aarav.shah@example.com', 'Pune', 'Maharashtra', '2025-01-10'),
    ('Priya', 'Patil', 'priya.patil@example.com', 'Mumbai', 'Maharashtra', '2025-01-18'),
    ('Rohan', 'Mehta', 'rohan.mehta@example.com', 'Ahmedabad', 'Gujarat', '2025-02-05'),
    ('Ananya', 'Rao', 'ananya.rao@example.com', 'Bengaluru', 'Karnataka', '2025-02-12'),
    ('Vikram', 'Singh', 'vikram.singh@example.com', 'Delhi', 'Delhi', '2025-03-01'),
    ('Sneha', 'Iyer', 'sneha.iyer@example.com', 'Chennai', 'Tamil Nadu', '2025-03-15'),
    ('Arjun', 'Nair', 'arjun.nair@example.com', 'Hyderabad', 'Telangana', '2025-04-03'),
    ('Kavya', 'Deshmukh', 'kavya.deshmukh@example.com', 'Pune', 'Maharashtra', '2025-04-21'),
    ('Rahul', 'Verma', 'rahul.verma@example.com', 'Jaipur', 'Rajasthan', '2025-05-08'),
    ('Ishita', 'Kulkarni', 'ishita.kulkarni@example.com', 'Mumbai', 'Maharashtra', '2025-05-19');
    
    
    
SELECT
    customer_id,
    first_name,
    last_name,
    city
FROM customers
ORDER BY customer_id;



INSERT INTO orders
    (customer_id, order_date, order_status, shipping_city, shipping_state)
VALUES
    (1, '2025-06-01 10:15:00', 'Delivered', 'Pune', 'Maharashtra'),
    (2, '2025-06-02 12:30:00', 'Delivered', 'Mumbai', 'Maharashtra'),
    (3, '2025-06-03 14:20:00', 'Shipped', 'Ahmedabad', 'Gujarat'),
    (4, '2025-06-05 09:45:00', 'Delivered', 'Bengaluru', 'Karnataka'),
    (5, '2025-06-07 16:10:00', 'Cancelled', 'Delhi', 'Delhi'),
    (1, '2025-06-10 11:00:00', 'Delivered', 'Pune', 'Maharashtra'),
    (6, '2025-06-12 13:25:00', 'Delivered', 'Chennai', 'Tamil Nadu'),
    (7, '2025-06-15 15:40:00', 'Processing', 'Hyderabad', 'Telangana'),
    (8, '2025-06-18 10:05:00', 'Delivered', 'Pune', 'Maharashtra'),
    (9, '2025-06-20 17:15:00', 'Shipped', 'Jaipur', 'Rajasthan'),
    (10, '2025-06-22 12:00:00', 'Delivered', 'Mumbai', 'Maharashtra'),
    (2, '2025-07-01 09:30:00', 'Delivered', 'Mumbai', 'Maharashtra'),
    (3, '2025-07-04 14:45:00', 'Processing', 'Ahmedabad', 'Gujarat'),
    (4, '2025-07-08 11:20:00', 'Delivered', 'Bengaluru', 'Karnataka'),
    (6, '2025-07-12 16:50:00', 'Pending', 'Chennai', 'Tamil Nadu');
    
    
    
SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM orders
ORDER BY order_id;



INSERT INTO order_items
    (order_id, product_id, quantity, unit_price, discount_percent)
VALUES
    (1, 1, 1, 2499.00, 0),
    (1, 3, 2, 799.00, 5),
    (2, 4, 2, 599.00, 0),
    (2, 9, 1, 699.00, 0),
    (3, 2, 1, 3999.00, 10),
    (3, 5, 1, 1499.00, 0),
    (4, 7, 1, 1299.00, 0),
    (4, 8, 3, 499.00, 5),
    (5, 6, 1, 2299.00, 0),
    (6, 1, 1, 2499.00, 5),
    (6, 11, 2, 999.00, 0),
    (7, 10, 2, 899.00, 10),
    (7, 9, 1, 699.00, 0),
    (8, 12, 1, 1799.00, 0),
    (8, 11, 1, 999.00, 0),
    (9, 4, 3, 599.00, 5),
    (9, 8, 2, 499.00, 0),
    (10, 6, 1, 2299.00, 0),
    (10, 2, 1, 3999.00, 5),
    (11, 3, 2, 799.00, 0),
    (11, 10, 1, 899.00, 0),
    (12, 5, 1, 1499.00, 0),
    (12, 7, 2, 1299.00, 5),
    (13, 1, 1, 2499.00, 0),
    (13, 9, 2, 699.00, 0),
    (14, 4, 1, 599.00, 0),
    (14, 6, 1, 2299.00, 10),
    (15, 10, 1, 899.00, 0),
    (15, 8, 2, 499.00, 0);
    
    
    
SELECT
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    discount_percent
FROM order_items
ORDER BY order_id, order_item_id;



INSERT INTO payments
    (order_id, payment_date, payment_method, amount,
     payment_status, transaction_reference)
VALUES
    (1, '2025-06-01 10:20:00', 'UPI', 4017.05, 'Completed', 'TXN-1001'),
    (2, '2025-06-02 12:35:00', 'Credit Card', 1897.00, 'Completed', 'TXN-1002'),
    (3, '2025-06-03 14:25:00', 'Debit Card', 5098.10, 'Completed', 'TXN-1003'),
    (4, '2025-06-05 09:50:00', 'UPI', 2720.55, 'Completed', 'TXN-1004'),
    (5, '2025-06-07 16:15:00', 'Credit Card', 2299.00, 'Failed', 'TXN-1005'),
    (6, '2025-06-10 11:05:00', 'UPI', 4397.05, 'Completed', 'TXN-1006'),
    (7, '2025-06-12 13:30:00', 'Net Banking', 2316.20, 'Completed', 'TXN-1007'),
    (8, '2025-06-15 15:45:00', 'UPI', 2798.00, 'Pending', 'TXN-1008'),
    (9, '2025-06-18 10:10:00', 'Credit Card', 2786.05, 'Completed', 'TXN-1009'),
    (10, '2025-06-20 17:20:00', 'Debit Card', 6298.00, 'Completed', 'TXN-1010'),
    (11, '2025-06-22 12:05:00', 'UPI', 2497.00, 'Completed', 'TXN-1011'),
    (12, '2025-07-01 09:35:00', 'Credit Card', 3958.05, 'Completed', 'TXN-1012'),
    (13, '2025-07-04 14:50:00', 'UPI', 3897.00, 'Pending', 'TXN-1013'),
    (14, '2025-07-08 11:25:00', 'Net Banking', 2683.10, 'Completed', 'TXN-1014'),
    (15, '2025-07-12 16:55:00', 'UPI', 1897.00, 'Pending', 'TXN-1015');
    
    
    
INSERT INTO shipments
    (order_id, courier_name, tracking_number,
     shipment_date, estimated_delivery_date,
     actual_delivery_date, shipment_status)
VALUES
    (1, 'BlueDart', 'TRK-2001', '2025-06-02', '2025-06-05', '2025-06-04', 'Delivered'),
    (2, 'Delhivery', 'TRK-2002', '2025-06-03', '2025-06-07', '2025-06-08', 'Delivered'),
    (3, 'BlueDart', 'TRK-2003', '2025-06-04', '2025-06-08', NULL, 'In Transit'),
    (4, 'DTDC', 'TRK-2004', '2025-06-06', '2025-06-10', '2025-06-10', 'Delivered'),
    (6, 'Delhivery', 'TRK-2006', '2025-06-11', '2025-06-14', '2025-06-13', 'Delivered'),
    (7, 'BlueDart', 'TRK-2007', '2025-06-13', '2025-06-17', '2025-06-18', 'Delivered'),
    (8, 'DTDC', 'TRK-2008', '2025-06-16', '2025-06-20', NULL, 'Preparing'),
    (9, 'Delhivery', 'TRK-2009', '2025-06-19', '2025-06-23', '2025-06-22', 'Delivered'),
    (10, 'BlueDart', 'TRK-2010', '2025-06-21', '2025-06-25', NULL, 'In Transit'),
    (11, 'DTDC', 'TRK-2011', '2025-06-23', '2025-06-27', '2025-06-26', 'Delivered'),
    (12, 'Delhivery', 'TRK-2012', '2025-07-02', '2025-07-06', '2025-07-05', 'Delivered'),
    (14, 'BlueDart', 'TRK-2014', '2025-07-09', '2025-07-13', '2025-07-15', 'Delivered');
    
    
    
INSERT INTO returns
    (order_item_id, return_date, return_quantity,
     return_reason, refund_amount, return_status)
VALUES
    (3, '2025-06-10', 1, 'Wrong size', 599.00, 'Approved'),
    (7, '2025-06-15', 1, 'Damaged packaging', 1299.00, 'Approved'),
    (12, '2025-06-20', 1, 'Product not as described', 809.10, 'Approved'),
    (18, '2025-06-25', 1, 'Changed mind', 569.05, 'Requested'),
    (21, '2025-06-28', 1, 'Defective product', 799.00, 'Approved'),
    (24, '2025-07-10', 1, 'Wrong item received', 2499.00, 'Approved');
    
    

/*
PROJECT: Retail Order Management & Business Analytics Database
PURPOSE: Display product sales details with their category names.
CONCEPTS: INNER JOIN, table aliases, ORDER BY.
*/

SELECT
    oi.order_item_id,       -- Unique ID for each order line
    p.product_name,         -- Name of the purchased product
    c.category_name,        -- Category to which the product belongs
    oi.quantity,            -- Number of units purchased
    oi.unit_price,          -- Price per unit at the time of purchase
    oi.discount_percent     -- Discount applied to the order line

FROM order_items oi         -- Start with individual order items

-- Match each order item to its product using product_id
JOIN products p
    ON oi.product_id = p.product_id

-- Match each product to its category using category_id
JOIN categories c
    ON p.category_id = c.category_id

-- Sort results by order ID, from lowest to highest
ORDER BY oi.order_id;





/*
PROJECT: Retail Order Management & Business Analytics Database
PURPOSE: Calculate the revenue generated by each product line
         after applying its discount.
CONCEPTS: INNER JOIN, arithmetic, ROUND(), column aliases, ORDER BY.
*/

SELECT
    oi.order_item_id,       -- Unique ID of the order line
    o.order_id,             -- Order to which this item belongs
    p.product_name,         -- Purchased product's name
    oi.quantity,            -- Number of units purchased
    oi.unit_price,          -- Price per unit
    oi.discount_percent,    -- Discount percentage

    -- Calculate revenue after discount and round to 2 decimal places
    ROUND(
        oi.quantity * oi.unit_price
        * (1 - oi.discount_percent / 100),
        2
    ) AS net_revenue        -- Name the calculated column net_revenue

FROM order_items oi

-- Connect each item to its order
JOIN orders o
    ON oi.order_id = o.order_id

-- Connect each item to its product
JOIN products p
    ON oi.product_id = p.product_id

-- Display the highest-revenue product lines first
ORDER BY net_revenue DESC;





-- BUSINESS QUESTION: Which products generate the most revenue?
-- CONCEPTS: JOIN, SUM(), GROUP BY, ROUND(), and ORDER BY.

SELECT
    p.product_name,  -- Name of the product being analyzed

    -- Calculate revenue after applying the discount to each order item.
    ROUND(
        SUM(
            oi.quantity * oi.unit_price
            * (1 - oi.discount_percent / 100)
        ),
        2
    ) AS total_net_revenue  -- Total discounted revenue for this product

FROM order_items oi

-- Match each order item with its product details.
JOIN products p
    ON oi.product_id = p.product_id

-- Combine all order-item rows belonging to the same product.
GROUP BY
    p.product_id,
    p.product_name

-- Show the products with the highest revenue first.
ORDER BY total_net_revenue DESC;




-- BUSINESS QUESTION: Which product categories generate the most revenue?
-- CONCEPTS: Multiple JOINs, SUM(), GROUP BY, ROUND(), and ORDER BY.

SELECT
    c.category_name,  -- Name of the product category

    -- Add discounted revenue from all order items in this category.
    ROUND(
        SUM(
            oi.quantity * oi.unit_price
            * (1 - oi.discount_percent / 100)
        ),
        2
    ) AS total_net_revenue  -- Total revenue after discounts

FROM order_items oi

-- Connect each order item to its product.
JOIN products p
    ON oi.product_id = p.product_id

-- Connect each product to its category.
JOIN categories c
    ON p.category_id = c.category_id

-- Combine all order items belonging to the same category.
GROUP BY
    c.category_id,
    c.category_name

-- Rank categories from highest revenue to lowest.
ORDER BY total_net_revenue DESC;




-- BUSINESS QUESTION: How much does each customer spend, and how many orders have they placed?
-- CONCEPTS: JOIN, GROUP BY, COUNT(DISTINCT), SUM(), and ROUND().

SELECT
    c.customer_id,  -- Unique identifier for each customer

    -- Combine first and last names into one readable column.
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,

    -- Count each customer's unique orders.
    COUNT(DISTINCT o.order_id) AS total_orders,

    -- Add the discounted revenue from the customer's order items.
    ROUND(
        SUM(
            oi.quantity * oi.unit_price
            * (1 - oi.discount_percent / 100)
        ),
        2
    ) AS total_net_revenue

FROM customers c

-- Find the orders placed by each customer.
JOIN orders o
    ON c.customer_id = o.customer_id

-- Find the products and quantities included in those orders.
JOIN order_items oi
    ON o.order_id = oi.order_id

-- Produce one summary row per customer.
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name

-- Show customers with the highest calculated revenue first.
ORDER BY total_net_revenue DESC;




-- BUSINESS QUESTION: What is the net value of each order?
-- CONCEPTS: JOIN, SUM(), GROUP BY, ROUND(), and ORDER BY.

SELECT
    o.order_id,  -- Unique order identifier
    o.order_date,  -- Date and time the order was placed
    o.order_status,  -- Current status of the order

    -- Add the discounted revenue from every item in this order.
    ROUND(
        SUM(
            oi.quantity * oi.unit_price
            * (1 - oi.discount_percent / 100)
        ),
        2
    ) AS order_net_revenue  -- Total order value after item discounts

FROM orders o

-- Connect each order to the items it contains.
JOIN order_items oi
    ON o.order_id = oi.order_id

-- Produce one summary row for each order.
GROUP BY
    o.order_id,
    o.order_date,
    o.order_status

-- Display the most recently placed orders first.
ORDER BY o.order_date DESC;




-- BUSINESS QUESTION: Which categories generate more than ₹10,000 in net revenue?
-- CONCEPTS: JOIN, SUM(), GROUP BY, HAVING, ROUND(), and ORDER BY.

SELECT
    c.category_name,  -- Name of the category

    -- Calculate total revenue after applying item discounts.
    ROUND(
        SUM(
            oi.quantity * oi.unit_price
            * (1 - oi.discount_percent / 100)
        ),
        2
    ) AS total_net_revenue

FROM order_items oi

-- Connect order items to their products.
JOIN products p
    ON oi.product_id = p.product_id

-- Connect products to their categories.
JOIN categories c
    ON p.category_id = c.category_id

-- Calculate one revenue total for each category.
GROUP BY
    c.category_id,
    c.category_name

-- Keep only categories whose total revenue exceeds ₹10,000.
HAVING SUM(
    oi.quantity * oi.unit_price
    * (1 - oi.discount_percent / 100)
) > 10000

-- Sort the qualifying categories by revenue, highest first.
ORDER BY total_net_revenue DESC;




-- BUSINESS QUESTION: Which products have never been ordered?
-- CONCEPTS: LEFT JOIN, COUNT(), and WHERE ... IS NULL.

SELECT
    p.product_id,  -- Unique product identifier
    p.product_name,  -- Product name
    p.unit_price,  -- Current listed price
    p.stock_quantity  -- Current available stock

FROM products p

-- Keep every product, even if it has no matching order item.
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id

-- Keep only products with no matching order-item record.
WHERE oi.order_item_id IS NULL

-- Display products alphabetically.
ORDER BY p.product_name;




-- BUSINESS QUESTION: How many orders are in each status?
-- CONCEPTS: COUNT(), GROUP BY, and ORDER BY.

SELECT
    order_status,  -- Status of the order

    -- Count the number of orders in each status.
    COUNT(*) AS total_orders

FROM orders

-- Group orders that share the same status.
GROUP BY order_status

-- Show the status with the most orders first.
ORDER BY total_orders DESC;




-- BUSINESS QUESTION: What percentage of all orders belongs to each status?
-- CONCEPTS: COUNT(), GROUP BY, subquery, ROUND(), and percentage calculation.

SELECT
    order_status,  -- Status being analyzed

    -- Count orders belonging to this status.
    COUNT(*) AS total_orders,

    -- Calculate this status's share of all orders.
    ROUND(
        COUNT(*) * 100.0
        / (SELECT COUNT(*) FROM orders),
        2
    ) AS percentage_of_orders

FROM orders

-- Create one summary row per order status.
GROUP BY order_status

-- Display the most common statuses first.
ORDER BY total_orders DESC;



-- Count all orders in the table.
(SELECT COUNT(*) FROM orders);






-- BUSINESS QUESTION: How many orders and how much net revenue
-- were generated in each month?

SELECT
    -- Convert each order date into a Year-Month label.
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,

    -- Count unique orders placed during the month.
    COUNT(DISTINCT o.order_id) AS total_orders,

    -- Calculate revenue after applying item discounts.
    ROUND(
        SUM(
            oi.quantity * oi.unit_price
            * (1 - oi.discount_percent / 100)
        ),
        2
    ) AS total_net_revenue

FROM orders o

-- Connect orders to their order items.
JOIN order_items oi
    ON o.order_id = oi.order_id

-- Group results by calendar month.
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')

-- Display months from earliest to latest.
ORDER BY order_month ASC;




-- BUSINESS QUESTION: Which five products sold the most units?
-- CONCEPTS: JOIN, SUM(), GROUP BY, ORDER BY, and LIMIT.

SELECT
    p.product_name,  -- Name of the product

    -- Add the quantities from all order-item records for this product.
    SUM(oi.quantity) AS total_units_sold

FROM order_items oi

-- Match each order item to its product.
JOIN products p
    ON oi.product_id = p.product_id

-- Calculate one total quantity per product.
GROUP BY
    p.product_id,
    p.product_name

-- Rank products from the most units sold to the fewest.
ORDER BY total_units_sold DESC

-- Return only the first five products.
LIMIT 5;




-- BUSINESS QUESTION: Which three customers have the highest net revenue?
-- CONCEPTS: JOIN, SUM(), GROUP BY, ORDER BY, and LIMIT.

SELECT
    c.customer_id,  -- Unique customer identifier

    -- Combine the customer's first and last names.
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,

    -- Add discounted revenue across all the customer's order items.
    ROUND(
        SUM(
            oi.quantity * oi.unit_price
            * (1 - oi.discount_percent / 100)
        ),
        2
    ) AS total_net_revenue

FROM customers c

-- Connect each customer to their orders.
JOIN orders o
    ON c.customer_id = o.customer_id

-- Connect each order to its items.
JOIN order_items oi
    ON o.order_id = oi.order_id

-- Calculate one revenue total per customer.
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name

-- Rank customers by revenue, highest first.
ORDER BY total_net_revenue DESC

-- Return only the top three customers.
LIMIT 3;




-- BUSINESS QUESTION: Which products are priced above the overall average?
-- CONCEPTS: Subquery, AVG(), WHERE, and ORDER BY.

SELECT
    product_id,  -- Unique product identifier
    product_name,  -- Name of the product
    unit_price  -- Current listed price

FROM products

-- Keep products whose price exceeds the average price of all products.
WHERE unit_price > (
    -- Calculate the average price across the entire products table.
    SELECT AVG(unit_price)
    FROM products
)

-- Show the most expensive qualifying products first.
ORDER BY unit_price DESC;




-- BUSINESS QUESTION: What is the revenue rank of each product?
-- CONCEPTS: CTE, SUM(), GROUP BY, and the RANK() window function.

-- Step 1: Calculate total net revenue for each product.
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,

        -- Add discounted revenue across all order items for this product.
        ROUND(
            SUM(
                oi.quantity * oi.unit_price
                * (1 - oi.discount_percent / 100)
            ),
            2
        ) AS total_net_revenue

    FROM products p

    -- Match products to their order-item records.
    JOIN order_items oi
        ON p.product_id = oi.product_id

    -- Produce one revenue total per product.
    GROUP BY
        p.product_id,
        p.product_name
)

-- Step 2: Rank products using their calculated revenue.
SELECT
    product_id,
    product_name,
    total_net_revenue,

    -- Rank the highest-revenue product first.
    RANK() OVER (
        ORDER BY total_net_revenue DESC
    ) AS revenue_rank

FROM product_revenue

-- Display the products in rank order.
ORDER BY revenue_rank ASC;




-- BUSINESS QUESTION: How does cumulative net revenue grow each month?
-- CONCEPTS: CTE, DATE_FORMAT(), SUM(), GROUP BY, and a window function.

-- Step 1: Calculate order-item revenue for each month.
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,

        -- Add discounted revenue from all order items in the month.
        ROUND(
            SUM(
                oi.quantity * oi.unit_price
                * (1 - oi.discount_percent / 100)
            ),
            2
        ) AS total_net_revenue

    FROM orders o

    -- Connect orders to their order items.
    JOIN order_items oi
        ON o.order_id = oi.order_id

    -- Group revenue by calendar month.
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)

-- Step 2: Add each month's revenue to the previous cumulative total.
SELECT
    order_month,
    total_net_revenue,

    -- Calculate cumulative revenue from the earliest month onward.
    ROUND(
        SUM(total_net_revenue) OVER (
            ORDER BY order_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS cumulative_net_revenue

FROM monthly_revenue

-- Display months chronologically.
ORDER BY order_month ASC;




-- BUSINESS QUESTION: Which shipments arrived later than expected?
-- CONCEPTS: JOIN, WHERE, date comparison, and ORDER BY.

SELECT
    s.shipment_id,  -- Unique shipment identifier
    s.order_id,  -- Order associated with the shipment
    s.courier_name,  -- Delivery service provider
    s.estimated_delivery_date,  -- Promised delivery date
    s.actual_delivery_date,  -- Actual delivery date

    -- Calculate the number of calendar days the shipment was late.
    DATEDIFF(
        s.actual_delivery_date,
        s.estimated_delivery_date
    ) AS days_late

FROM shipments s

-- Match each shipment to its order.
JOIN orders o
    ON s.order_id = o.order_id

-- Keep shipments delivered after their estimated delivery date.
WHERE s.actual_delivery_date > s.estimated_delivery_date

-- Show the most delayed shipments first.
ORDER BY days_late DESC;




-- BUSINESS QUESTION: What percentage of completed deliveries were on time?
-- CONCEPTS: COUNT(), SUM(), CASE, NULLIF(), and percentage calculation.

SELECT
    -- Count shipments that have an actual delivery date.
    COUNT(*) AS completed_shipments,

    -- Count shipments delivered on or before the estimated date.
    SUM(
        CASE
            WHEN actual_delivery_date <= estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS on_time_shipments,

    -- Calculate the percentage delivered on time or early.
    ROUND(
        100.0 * SUM(
            CASE
                WHEN actual_delivery_date <= estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS on_time_delivery_rate_pct

FROM shipments

-- Include only shipments with an actual delivery date.
WHERE actual_delivery_date IS NOT NULL

-- Exclude records without an estimated delivery date,
-- because their on-time performance cannot be evaluated.
AND estimated_delivery_date IS NOT NULL;




-- BUSINESS QUESTION: What are the most common reasons for product returns?
-- CONCEPTS: COUNT(), SUM(), GROUP BY, ROUND(), and ORDER BY.

SELECT
    return_reason,  -- Reason the customer gave for returning the product

    -- Count the number of return records for each reason.
    COUNT(*) AS total_return_records,

    -- Add the quantities returned for each reason.
    SUM(return_quantity) AS total_units_returned,

    -- Add the refund amounts associated with each reason.
    ROUND(SUM(refund_amount), 2) AS total_refund_amount

FROM returns

-- Combine return records with the same reason.
GROUP BY return_reason

-- Show the reasons with the most return records first.
ORDER BY total_return_records DESC;




-- BUSINESS QUESTION: What percentage of ordered units were returned for each product?
-- CONCEPTS: JOIN, LEFT JOIN, SUM(), GROUP BY, COALESCE(), and percentage calculation.

SELECT
    p.product_id,  -- Unique product identifier
    p.product_name,  -- Product name

    -- Calculate the total number of units ordered for this product.
    SUM(oi.quantity) AS total_units_ordered,

    -- Add returned quantities, using zero when no return records exist.
    COALESCE(SUM(r.return_quantity), 0) AS total_units_returned,

    -- Calculate the returned quantity as a percentage of ordered units.
    ROUND(
        100.0 * COALESCE(SUM(r.return_quantity), 0)
        / NULLIF(SUM(oi.quantity), 0),
        2
    ) AS return_rate_pct

FROM products p

-- Include products that have order items.
JOIN order_items oi
    ON p.product_id = oi.product_id

-- Match each order item to any associated return records.
LEFT JOIN returns r
    ON oi.order_item_id = r.order_item_id

-- Produce one result row per product.
GROUP BY
    p.product_id,
    p.product_name

-- Show products with the highest calculated return rate first.
ORDER BY return_rate_pct DESC;




-- BUSINESS QUESTION: Which suppliers have the longest lead times?
-- CONCEPTS: JOIN, AVG(), MIN(), MAX(), GROUP BY, and ORDER BY.

SELECT
    s.supplier_id,  -- Unique supplier identifier
    s.supplier_name,  -- Supplier name
    s.supplier_region,  -- Supplier's region

    -- Calculate the average lead time for products from this supplier.
    ROUND(AVG(s.lead_time_days), 2) AS average_lead_time_days,

    -- Identify the shortest recorded product lead time for this supplier.
    MIN(s.lead_time_days) AS minimum_lead_time_days,

    -- Identify the longest recorded product lead time for this supplier.
    MAX(s.lead_time_days) AS maximum_lead_time_days

FROM suppliers s

-- Match each supplier to the products they supply.
JOIN products p
    ON s.supplier_id = p.supplier_id

-- Produce one summary row per supplier.
GROUP BY
    s.supplier_id,
    s.supplier_name,
    s.supplier_region

-- Display suppliers with the longest average lead time first.
ORDER BY average_lead_time_days DESC;




-- BUSINESS QUESTION: Which products need restocking?
-- CONCEPTS: WHERE, comparison operators, and ORDER BY.

SELECT
    product_id,  -- Unique product identifier
    product_name,  -- Product name
    stock_quantity,  -- Current available stock
    reorder_level,  -- Minimum stock threshold for replenishment

    -- Calculate the additional units needed to reach the reorder level.
    reorder_level - stock_quantity AS units_to_reorder

FROM products

-- Find products whose stock is at or below the reorder threshold.
WHERE stock_quantity <= reorder_level

-- Show the lowest-stock products first.
ORDER BY stock_quantity ASC;




-- BUSINESS QUESTION: What is the average net value of an order?
-- CONCEPTS: CTE, SUM(), GROUP BY, AVG(), and ROUND().

-- Step 1: Calculate the net revenue for each order.
WITH order_totals AS (
    SELECT
        o.order_id,  -- Unique order identifier

        -- Add discounted revenue across all items in this order.
        SUM(
            oi.quantity * oi.unit_price
            * (1 - oi.discount_percent / 100)
        ) AS order_net_revenue

    FROM orders o

    -- Connect each order to its items.
    JOIN order_items oi
        ON o.order_id = oi.order_id

    -- Produce one revenue total per order.
    GROUP BY o.order_id
)

-- Step 2: Calculate the average order value.
SELECT
    -- Calculate the average net revenue across all included orders.
    ROUND(AVG(order_net_revenue), 2) AS average_order_value

FROM order_totals;




-- BUSINESS PURPOSE: Save a reusable view of order-level revenue.
-- CONCEPTS: CREATE VIEW, JOIN, SUM(), and GROUP BY.

-- Create a view that calculates discounted revenue for each order.
CREATE VIEW vw_order_revenue AS
SELECT
    o.order_id,  -- Unique order identifier
    o.order_date,  -- Date and time of the order
    o.order_status,  -- Current order status
    o.customer_id,  -- Customer who placed the order

    -- Calculate the total net revenue across the order's items.
    ROUND(
        SUM(
            oi.quantity * oi.unit_price
            * (1 - oi.discount_percent / 100)
        ),
        2
    ) AS order_net_revenue

FROM orders o

-- Connect orders to their order items.
JOIN order_items oi
    ON o.order_id = oi.order_id

-- Produce one row per order.
GROUP BY
    o.order_id,
    o.order_date,
    o.order_status,
    o.customer_id;




-- BUSINESS PURPOSE: Retrieve order revenue from the saved view.
SELECT *
FROM vw_order_revenue
ORDER BY order_date DESC;




-- BUSINESS PURPOSE: Create a reusable customer performance report.
-- CONCEPTS: CREATE VIEW, JOIN, COUNT(DISTINCT), SUM(), and GROUP BY.

CREATE VIEW vw_customer_revenue AS
SELECT
    c.customer_id,  -- Unique customer identifier

    -- Combine first and last names into one readable name.
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,

    -- Count the customer's unique orders.
    COUNT(DISTINCT o.order_id) AS total_orders,

    -- Calculate total discounted revenue across the customer's order items.
    ROUND(
        SUM(
            oi.quantity * oi.unit_price
            * (1 - oi.discount_percent / 100)
        ),
        2
    ) AS total_net_revenue

FROM customers c

-- Match customers with their orders.
JOIN orders o
    ON c.customer_id = o.customer_id

-- Match each order with its items.
JOIN order_items oi
    ON o.order_id = oi.order_id

-- Create one summary row per customer.
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name;




-- BUSINESS PURPOSE: Display the highest-revenue customers first.
SELECT *
FROM vw_customer_revenue
ORDER BY total_net_revenue DESC;




-- BUSINESS PURPOSE: Create an index to support searches by customer.
-- CONCEPTS: CREATE INDEX and database performance optimization.

-- Index the customer_id column in the orders table.
CREATE INDEX idx_orders_customer_id
ON orders (customer_id);




-- BUSINESS PURPOSE: Find orders belonging to customer ID 1.
-- EXPLAIN shows MySQL's planned approach to running this query.

EXPLAIN
SELECT
    order_id,
    order_date,
    order_status
FROM orders
WHERE customer_id = 1;



-- BUSINESS PURPOSE: Inspect indexes already available on the orders table.
-- WHY THIS MATTERS: MySQL may automatically create an index to support
-- the customer_id foreign key, so we should check before adding more.

SHOW INDEX FROM orders;



-- BUSINESS PURPOSE: Compare each order's item value with its completed payments.
-- CONCEPTS: JOIN, GROUP BY, aggregate functions, and data reconciliation.
-- NOTE: This compares completed payments only with the net value of order items.

WITH order_totals AS (
    -- Calculate the net value of items in each order after discounts.
    SELECT
        order_id,
        ROUND(
            SUM(
                quantity * unit_price
                * (1 - discount_percent / 100)
            ),
            2
        ) AS order_item_total
    FROM order_items
    GROUP BY order_id
),
payment_totals AS (
    -- Add up only payments marked as Completed for each order.
    SELECT
        order_id,
        ROUND(SUM(amount), 2) AS completed_payment_total
    FROM payments
    WHERE payment_status = 'Completed'
    GROUP BY order_id
)
SELECT
    o.order_id,
    COALESCE(ot.order_item_total, 0) AS order_item_total,
    COALESCE(pt.completed_payment_total, 0) AS completed_payment_total,
    ROUND(
        COALESCE(pt.completed_payment_total, 0)
        - COALESCE(ot.order_item_total, 0),
        2
    ) AS payment_difference
FROM orders o
LEFT JOIN order_totals ot
    ON o.order_id = ot.order_id
LEFT JOIN payment_totals pt
    ON o.order_id = pt.order_id
ORDER BY o.order_id;



-- BUSINESS PURPOSE: Flag orders that may need payment investigation.
-- CONCEPTS: Common Table Expressions (CTEs), JOIN, and WHERE filtering.
-- A non-zero difference indicates a potential discrepancy to investigate.

WITH order_totals AS (
    -- Calculate each order's net item value after discounts.
    SELECT
        order_id,
        ROUND(
            SUM(
                quantity * unit_price
                * (1 - discount_percent / 100)
            ),
            2
        ) AS order_item_total
    FROM order_items
    GROUP BY order_id
),
payment_totals AS (
    -- Calculate completed payments for each order.
    SELECT
        order_id,
        ROUND(SUM(amount), 2) AS completed_payment_total
    FROM payments
    WHERE payment_status = 'Completed'
    GROUP BY order_id
)
SELECT
    o.order_id,
    COALESCE(ot.order_item_total, 0) AS order_item_total,
    COALESCE(pt.completed_payment_total, 0) AS completed_payment_total,
    ROUND(
        COALESCE(pt.completed_payment_total, 0)
        - COALESCE(ot.order_item_total, 0),
        2
    ) AS payment_difference
FROM orders o
LEFT JOIN order_totals ot
    ON o.order_id = ot.order_id
LEFT JOIN payment_totals pt
    ON o.order_id = pt.order_id
WHERE ROUND(
    COALESCE(pt.completed_payment_total, 0)
    - COALESCE(ot.order_item_total, 0),
    2
) <> 0
ORDER BY o.order_id;



-- BUSINESS PURPOSE: Classify each order for a payment reconciliation report.
-- CONCEPTS: CTEs, LEFT JOIN, COALESCE, and CASE expressions.
-- Separate totals prevent item amounts and payment amounts from being multiplied.

WITH order_totals AS (
    -- Calculate each order's net item value after discounts.
    SELECT
        order_id,
        ROUND(
            SUM(
                quantity * unit_price
                * (1 - discount_percent / 100)
            ),
            2
        ) AS order_item_total
    FROM order_items
    GROUP BY order_id
),
payment_totals AS (
    -- Sum completed payments for each order.
    SELECT
        order_id,
        ROUND(SUM(amount), 2) AS completed_payment_total
    FROM payments
    WHERE payment_status = 'Completed'
    GROUP BY order_id
),
reconciliation AS (
    -- Bring the two totals together and calculate the difference.
    SELECT
        o.order_id,
        COALESCE(ot.order_item_total, 0) AS order_item_total,
        COALESCE(pt.completed_payment_total, 0) AS completed_payment_total,
        ROUND(
            COALESCE(pt.completed_payment_total, 0)
            - COALESCE(ot.order_item_total, 0),
            2
        ) AS payment_difference
    FROM orders o
    LEFT JOIN order_totals ot
        ON o.order_id = ot.order_id
    LEFT JOIN payment_totals pt
        ON o.order_id = pt.order_id
)
SELECT
    order_id,
    order_item_total,
    completed_payment_total,
    payment_difference,
    CASE
        WHEN payment_difference = 0 THEN 'Matched'
        WHEN payment_difference > 0 THEN 'Overpaid'
        ELSE 'Underpaid or unpaid'
    END AS reconciliation_status
FROM reconciliation
ORDER BY order_id;



-- BUSINESS PURPOSE: Summarize payment reconciliation results for management.
-- CONCEPTS: CTEs, CASE, COUNT, and GROUP BY.
-- Each order is assigned one reconciliation status before counting.

WITH order_totals AS (
    -- Calculate the net item value of each order after discounts.
    SELECT
        order_id,
        ROUND(
            SUM(
                quantity * unit_price
                * (1 - discount_percent / 100)
            ),
            2
        ) AS order_item_total
    FROM order_items
    GROUP BY order_id
),
payment_totals AS (
    -- Sum completed payments for each order.
    SELECT
        order_id,
        ROUND(SUM(amount), 2) AS completed_payment_total
    FROM payments
    WHERE payment_status = 'Completed'
    GROUP BY order_id
),
reconciliation AS (
    -- Compare item totals with completed payment totals.
    SELECT
        o.order_id,
        ROUND(
            COALESCE(pt.completed_payment_total, 0)
            - COALESCE(ot.order_item_total, 0),
            2
        ) AS payment_difference
    FROM orders o
    LEFT JOIN order_totals ot
        ON o.order_id = ot.order_id
    LEFT JOIN payment_totals pt
        ON o.order_id = pt.order_id
),
classified_orders AS (
    -- Assign a readable status to every order.
    SELECT
        order_id,
        CASE
            WHEN payment_difference = 0 THEN 'Matched'
            WHEN payment_difference > 0 THEN 'Overpaid'
            ELSE 'Underpaid or unpaid'
        END AS reconciliation_status
    FROM reconciliation
)
-- Count the orders in each reconciliation category.
SELECT
    reconciliation_status,
    COUNT(*) AS number_of_orders
FROM classified_orders
GROUP BY reconciliation_status
ORDER BY number_of_orders DESC;



-- BUSINESS PURPOSE: Measure the percentage of orders with potential payment discrepancies.
-- CONCEPTS: CTEs, conditional aggregation, ROUND, and NULLIF.
-- The discrepancy rate is the number of flagged orders divided by all orders.

WITH order_totals AS (
    -- Calculate each order's net item value after discounts.
    SELECT
        order_id,
        ROUND(
            SUM(
                quantity * unit_price
                * (1 - discount_percent / 100)
            ),
            2
        ) AS order_item_total
    FROM order_items
    GROUP BY order_id
),
payment_totals AS (
    -- Sum only completed payments for each order.
    SELECT
        order_id,
        ROUND(SUM(amount), 2) AS completed_payment_total
    FROM payments
    WHERE payment_status = 'Completed'
    GROUP BY order_id
),
reconciliation AS (
    -- Compare the completed payment total with the item total.
    SELECT
        o.order_id,
        ROUND(
            COALESCE(pt.completed_payment_total, 0)
            - COALESCE(ot.order_item_total, 0),
            2
        ) AS payment_difference
    FROM orders o
    LEFT JOIN order_totals ot
        ON o.order_id = ot.order_id
    LEFT JOIN payment_totals pt
        ON o.order_id = pt.order_id
)
SELECT
    COUNT(*) AS total_orders,
    SUM(
        CASE
            WHEN payment_difference <> 0 THEN 1
            ELSE 0
        END
    ) AS flagged_orders,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN payment_difference <> 0 THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS discrepancy_rate_percent
FROM reconciliation;



-- BUSINESS PURPOSE: Compare completed payment revenue by payment method.
-- CONCEPTS: SUM, COUNT, GROUP BY, and ORDER BY.
-- Only completed payments are included in the revenue comparison.

SELECT
    payment_method,
    COUNT(*) AS completed_payment_transactions,
    ROUND(SUM(amount), 2) AS total_completed_payment_revenue
FROM payments
WHERE payment_status = 'Completed'
GROUP BY payment_method
ORDER BY total_completed_payment_revenue DESC;



-- BUSINESS PURPOSE: Measure the order cancellation rate.
-- CONCEPTS: COUNT, conditional aggregation, ROUND, and NULLIF.
-- The cancellation rate is cancelled orders divided by all orders.

SELECT
    COUNT(*) AS total_orders,

    -- Count orders whose status is Cancelled.
    SUM(
        CASE
            WHEN LOWER(order_status) = 'cancelled' THEN 1
            ELSE 0
        END
    ) AS cancelled_orders,

    -- Calculate the percentage of cancelled orders.
    ROUND(
        100.0 * SUM(
            CASE
                WHEN LOWER(order_status) = 'cancelled' THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS cancellation_rate_percent
FROM orders;



-- BUSINESS PURPOSE: Understand the distribution of orders by status.
-- CONCEPTS: GROUP BY, COUNT, and ORDER BY.
-- Each row represents one order status and its number of orders.

SELECT
    order_status,
    COUNT(*) AS number_of_orders
FROM orders
GROUP BY order_status
ORDER BY number_of_orders DESC;



-- BUSINESS PURPOSE: Calculate the percentage of shipments marked Delivered.
-- CONCEPTS: Conditional aggregation, ROUND, and NULLIF.
-- This measures shipment delivery status, not the overall order completion rate.

SELECT
    COUNT(*) AS total_shipments,

    -- Count shipments whose status is Delivered.
    SUM(
        CASE
            WHEN LOWER(shipment_status) = 'delivered' THEN 1
            ELSE 0
        END
    ) AS delivered_shipments,

    -- Calculate the percentage of shipments delivered.
    ROUND(
        100.0 * SUM(
            CASE
                WHEN LOWER(shipment_status) = 'delivered' THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS delivery_rate_percent
FROM shipments;



-- BUSINESS PURPOSE: Compare delivery performance across courier companies.
-- CONCEPTS: GROUP BY, COUNT, SUM, CASE, and ROUND.
-- Each courier's delivery rate is based on its recorded shipments.

SELECT
    courier_name,
    COUNT(*) AS total_shipments,

    -- Count shipments marked as Delivered for each courier.
    SUM(
        CASE
            WHEN LOWER(shipment_status) = 'delivered' THEN 1
            ELSE 0
        END
    ) AS delivered_shipments,

    -- Calculate the percentage of shipments delivered by each courier.
    ROUND(
        100.0 * SUM(
            CASE
                WHEN LOWER(shipment_status) = 'delivered' THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS delivery_rate_percent
FROM shipments
GROUP BY courier_name
ORDER BY delivery_rate_percent DESC;



-- BUSINESS PURPOSE: Identify couriers with longer delivery delays.
-- CONCEPTS: DATEDIFF, AVG, COUNT, GROUP BY, and HAVING.
-- Only shipments delivered after their estimated date are included.

SELECT
    courier_name,

    -- Count shipments delivered later than their estimated date.
    COUNT(*) AS late_shipments,

    -- Calculate the average number of days past the estimated date.
    ROUND(
        AVG(
            DATEDIFF(
                actual_delivery_date,
                estimated_delivery_date
            )
        ),
        2
    ) AS average_delay_days,

    -- Find the longest recorded delay in days.
    MAX(
        DATEDIFF(
            actual_delivery_date,
            estimated_delivery_date
        )
    ) AS maximum_delay_days
FROM shipments
WHERE actual_delivery_date IS NOT NULL
  AND estimated_delivery_date IS NOT NULL
  AND actual_delivery_date > estimated_delivery_date
GROUP BY courier_name
ORDER BY average_delay_days DESC;



-- BUSINESS PURPOSE: Compare product return rates across categories.
-- CONCEPTS: JOIN, LEFT JOIN, SUM, COALESCE, and NULLIF.
-- Return rate = returned units / sold units * 100.
-- Returns are matched to their original order items to avoid counting
-- unrelated products or categories.

SELECT
    c.category_name,

    -- Calculate the total quantity sold in each category.
    SUM(oi.quantity) AS units_sold,

    -- Calculate the total quantity returned in each category.
    COALESCE(SUM(r.return_quantity), 0) AS units_returned,

    -- Calculate the percentage of sold units that were returned.
    ROUND(
        100.0 * COALESCE(SUM(r.return_quantity), 0)
        / NULLIF(SUM(oi.quantity), 0),
        2
    ) AS return_rate_percent

FROM categories c
JOIN products p
    ON c.category_id = p.category_id
JOIN order_items oi
    ON p.product_id = oi.product_id
LEFT JOIN returns r
    ON oi.order_item_id = r.order_item_id

GROUP BY c.category_id, c.category_name
ORDER BY return_rate_percent DESC;



-- BUSINESS PURPOSE: Identify products with the highest returned quantities.
-- CONCEPTS: JOIN, GROUP BY, SUM, and ORDER BY.
-- Return reasons help identify potential product-quality or customer issues.

SELECT
    p.product_name,
    c.category_name,

    -- Count the number of return records for each product.
    COUNT(DISTINCT r.return_id) AS return_requests,

    -- Calculate the total quantity returned.
    SUM(r.return_quantity) AS units_returned,

    -- Calculate the total refund amount recorded for the product.
    ROUND(SUM(r.refund_amount), 2) AS total_refund_amount

FROM returns r
JOIN order_items oi
    ON r.order_item_id = oi.order_item_id
JOIN products p
    ON oi.product_id = p.product_id
JOIN categories c
    ON p.category_id = c.category_id

GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY units_returned DESC;



-- BUSINESS PURPOSE: Identify the most common reasons for product returns.
-- CONCEPTS: GROUP BY, COUNT, SUM, and ORDER BY.
-- Grouping return records by reason helps identify recurring issues.

SELECT
    COALESCE(return_reason, 'Not specified') AS return_reason,

    -- Count the number of return records for each reason.
    COUNT(*) AS return_requests,

    -- Calculate the total number of units returned for each reason.
    SUM(return_quantity) AS units_returned,

    -- Calculate the total refund amount recorded for each reason.
    ROUND(SUM(refund_amount), 2) AS total_refund_amount

FROM returns
GROUP BY COALESCE(return_reason, 'Not specified')
ORDER BY return_requests DESC;



-- BUSINESS PURPOSE: Measure each return reason's share of total refunds.
-- CONCEPTS: SUM, subqueries, GROUP BY, and percentage calculations.
-- Each reason's refund amount is compared with all recorded refunds.

SELECT
    COALESCE(return_reason, 'Not specified') AS return_reason,

    -- Calculate the refund amount associated with each reason.
    ROUND(SUM(refund_amount), 2) AS reason_refund_amount,

    -- Calculate the percentage of total refunds attributed to this reason.
    ROUND(
        100.0 * SUM(refund_amount)
        / NULLIF(
            (SELECT SUM(refund_amount) FROM returns),
            0
        ),
        2
    ) AS share_of_total_refunds_percent

FROM returns
GROUP BY COALESCE(return_reason, 'Not specified')
ORDER BY reason_refund_amount DESC;



-- BUSINESS PURPOSE: Create a consolidated order-level performance report.
-- CONCEPTS: CTEs, JOIN, LEFT JOIN, and COALESCE.
-- Aggregate each table separately to avoid multiplying revenue or payments.

WITH order_totals AS (
    -- Calculate the net item revenue for each order after discounts.
    SELECT
        order_id,
        ROUND(
            SUM(
                quantity * unit_price
                * (1 - discount_percent / 100)
            ),
            2
        ) AS order_item_revenue
    FROM order_items
    GROUP BY order_id
),
payment_totals AS (
    -- Calculate completed payments for each order.
    SELECT
        order_id,
        ROUND(SUM(amount), 2) AS completed_payment_total
    FROM payments
    WHERE payment_status = 'Completed'
    GROUP BY order_id
)
SELECT
    o.order_id,
    o.order_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    o.order_status,
    COALESCE(ot.order_item_revenue, 0) AS order_item_revenue,
    COALESCE(pt.completed_payment_total, 0) AS completed_payment_total,

    -- Show completed payments minus the net item revenue.
    ROUND(
        COALESCE(pt.completed_payment_total, 0)
        - COALESCE(ot.order_item_revenue, 0),
        2
    ) AS payment_difference

FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN order_totals ot
    ON o.order_id = ot.order_id
LEFT JOIN payment_totals pt
    ON o.order_id = pt.order_id
ORDER BY o.order_date DESC;



-- BUSINESS PURPOSE: Save the consolidated order report for reuse.
-- CONCEPTS: CREATE VIEW, CTEs, and reusable SQL reporting.
-- The view stores the query definition, not a separate copy of the results.

CREATE VIEW vw_order_performance AS
WITH order_totals AS (
    -- Calculate net item revenue for each order after discounts.
    SELECT
        order_id,
        ROUND(
            SUM(
                quantity * unit_price
                * (1 - discount_percent / 100)
            ),
            2
        ) AS order_item_revenue
    FROM order_items
    GROUP BY order_id
),
payment_totals AS (
    -- Calculate completed payments for each order.
    SELECT
        order_id,
        ROUND(SUM(amount), 2) AS completed_payment_total
    FROM payments
    WHERE payment_status = 'Completed'
    GROUP BY order_id
)
SELECT
    o.order_id,
    o.order_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    o.order_status,
    COALESCE(ot.order_item_revenue, 0) AS order_item_revenue,
    COALESCE(pt.completed_payment_total, 0) AS completed_payment_total,
    ROUND(
        COALESCE(pt.completed_payment_total, 0)
        - COALESCE(ot.order_item_revenue, 0),
        2
    ) AS payment_difference
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN order_totals ot
    ON o.order_id = ot.order_id
LEFT JOIN payment_totals pt
    ON o.order_id = pt.order_id;


-- ALREADY CREATED SUCCESSFULLY.
-- Do not rerun this CREATE VIEW statement unless intentionally replacing the view.
-- BUSINESS PURPOSE: Test the existing order performance view.
SELECT *
FROM vw_order_performance
ORDER BY order_date DESC;



-- BUSINESS PURPOSE: Confirm that MySQL recognizes the existing view.
-- This lists the view definition without creating or changing anything.

SHOW CREATE VIEW vw_order_performance;



-- BUSINESS PURPOSE: Identify orders with the largest payment discrepancies.
-- CONCEPTS: SELECT, WHERE, ORDER BY, and LIMIT.
-- The view already calculates the payment difference for each order.

SELECT
    order_id,
    customer_name,
    order_status,
    order_item_revenue,
    completed_payment_total,
    payment_difference
FROM vw_order_performance
WHERE payment_difference <> 0
ORDER BY ABS(payment_difference) DESC
LIMIT 5;



-- BUSINESS PURPOSE: Compare net order-item revenue by order status.
-- CONCEPTS: JOIN, SUM, GROUP BY, and ORDER BY.
-- Revenue is calculated from item quantities, prices, and discounts.

SELECT
    o.order_status,

    -- Count the orders associated with each status.
    COUNT(DISTINCT o.order_id) AS number_of_orders,

    -- Calculate net item revenue after discounts.
    ROUND(
        SUM(
            oi.quantity * oi.unit_price
            * (1 - oi.discount_percent / 100)
        ),
        2
    ) AS total_order_item_revenue

FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_status
ORDER BY total_order_item_revenue DESC;



-- BUSINESS PURPOSE: Compare customers by their average spending per order.
-- CONCEPTS: CTEs, JOIN, COUNT, SUM, and GROUP BY.
-- Calculate each order's value first to avoid counting order items as orders.

WITH order_totals AS (
    -- Calculate net revenue for each order after discounts.
    SELECT
        order_id,
        ROUND(
            SUM(
                quantity * unit_price
                * (1 - discount_percent / 100)
            ),
            2
        ) AS order_net_revenue
    FROM order_items
    GROUP BY order_id
)
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,

    -- Count the customer's orders.
    COUNT(o.order_id) AS total_orders,

    -- Calculate the customer's average order value.
    ROUND(AVG(ot.order_net_revenue), 2) AS average_order_value

FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_totals ot
    ON o.order_id = ot.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY average_order_value DESC;



-- BUSINESS PURPOSE: Track monthly revenue and month-over-month growth.
-- CONCEPTS: CTEs, DATE_FORMAT, GROUP BY, and the LAG window function.
-- Revenue is calculated after discounts using order-item data.

WITH monthly_revenue AS (
    -- Calculate net item revenue for each calendar month.
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
        ROUND(
            SUM(
                oi.quantity * oi.unit_price
                * (1 - oi.discount_percent / 100)
            ),
            2
        ) AS monthly_net_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
),
revenue_comparison AS (
    -- Bring the previous month's revenue alongside the current month.
    SELECT
        order_month,
        monthly_net_revenue,
        LAG(monthly_net_revenue) OVER (
            ORDER BY order_month
        ) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    order_month,
    monthly_net_revenue,
    previous_month_revenue,

    -- Calculate the absolute change in revenue from the previous month.
    ROUND(
        monthly_net_revenue - previous_month_revenue,
        2
    ) AS revenue_change,

    -- Calculate the percentage change from the previous month.
    ROUND(
        100.0 * (monthly_net_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS revenue_growth_percent

FROM revenue_comparison
ORDER BY order_month;



-- BUSINESS PURPOSE: Identify the highest-revenue products in each category.
-- CONCEPTS: CTEs, GROUP BY, and the RANK window function.
-- Revenue is calculated after discounts.

WITH product_revenue AS (
    -- Calculate total net revenue for each product.
    SELECT
        p.product_id,
        p.product_name,
        c.category_name,
        ROUND(
            SUM(
                oi.quantity * oi.unit_price
                * (1 - oi.discount_percent / 100)
            ),
            2
        ) AS total_net_revenue
    FROM products p
    JOIN categories c
        ON p.category_id = c.category_id
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.product_id,
        p.product_name,
        c.category_name
),
category_rankings AS (
    -- Rank products from highest to lowest revenue within each category.
    SELECT
        product_id,
        product_name,
        category_name,
        total_net_revenue,
        RANK() OVER (
            PARTITION BY category_name
            ORDER BY total_net_revenue DESC
        ) AS category_revenue_rank
    FROM product_revenue
)
-- Return the top-ranked product or products from each category.
SELECT
    category_name,
    product_name,
    total_net_revenue,
    category_revenue_rank
FROM category_rankings
WHERE category_revenue_rank = 1
ORDER BY category_name;




-- BUSINESS PURPOSE: Identify repeat customers and measure their spending.
-- CONCEPTS: JOIN, GROUP BY, HAVING, COUNT, and SUM.
-- A repeat customer is defined here as someone with more than one order.

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,

    -- Count the number of orders placed by each customer.
    COUNT(DISTINCT o.order_id) AS total_orders,

    -- Calculate the customer's net item revenue after discounts.
    ROUND(
        SUM(
            oi.quantity * oi.unit_price
            * (1 - oi.discount_percent / 100)
        ),
        2
    ) AS total_net_revenue

FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id

GROUP BY c.customer_id, c.first_name, c.last_name

-- Include only customers with more than one order.
HAVING COUNT(DISTINCT o.order_id) > 1

ORDER BY total_net_revenue DESC;



-- BUSINESS PURPOSE: Compare one-time and repeat customers.
-- CONCEPTS: CTEs, CASE, GROUP BY, and aggregate functions.
-- Calculate each customer's order count and revenue before classifying them.

WITH customer_summary AS (
    -- Summarize order count and net revenue for each customer.
    SELECT
        c.customer_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(
            SUM(
                oi.quantity * oi.unit_price
                * (1 - oi.discount_percent / 100)
            ),
            2
        ) AS total_net_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id
),
customer_segments AS (
    -- Classify customers based on how many orders they placed.
    SELECT
        customer_id,
        total_orders,
        total_net_revenue,
        CASE
            WHEN total_orders = 1 THEN 'One-time customer'
            ELSE 'Repeat customer'
        END AS customer_segment
    FROM customer_summary
)
-- Compare the number and average spending of customers in each group.
SELECT
    customer_segment,
    COUNT(*) AS number_of_customers,
    ROUND(AVG(total_net_revenue), 2) AS average_customer_revenue,
    ROUND(AVG(total_orders), 2) AS average_orders_per_customer
FROM customer_segments
GROUP BY customer_segment
ORDER BY average_customer_revenue DESC;



-- BUSINESS PURPOSE: Identify products that may need restocking.
-- CONCEPTS: JOIN, GROUP BY, SUM, WHERE, and ORDER BY.
-- Compare current stock with units sold to prioritize inventory review.

SELECT
    p.product_id,
    p.product_name,
    p.stock_quantity,
    p.reorder_level,

    -- Calculate total units sold for each product.
    SUM(oi.quantity) AS total_units_sold,

    -- Calculate the difference between current stock and reorder level.
    p.stock_quantity - p.reorder_level AS stock_above_reorder_level

FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id

GROUP BY
    p.product_id,
    p.product_name,
    p.stock_quantity,
    p.reorder_level

-- Focus on products at or below their configured reorder level.
HAVING p.stock_quantity <= p.reorder_level

ORDER BY total_units_sold DESC;



-- BUSINESS PURPOSE: Evaluate supplier delivery reliability.
-- CONCEPTS: JOIN, DATEDIFF, CASE, GROUP BY, and conditional aggregation.
-- Compare actual delivery duration with each supplier's expected lead time.

SELECT
    s.supplier_id,
    s.supplier_name,

    -- Show the supplier's configured expected lead time.
    s.lead_time_days,

    -- Count shipments with both actual and shipment dates available.
    COUNT(sh.shipment_id) AS shipments_with_delivery_data,

    -- Count shipments delivered within the expected lead time.
    SUM(
        CASE
            WHEN DATEDIFF(
                sh.actual_delivery_date,
                DATE(shipment_order.order_date)
            ) <= s.lead_time_days
            THEN 1
            ELSE 0
        END
    ) AS shipments_within_lead_time,

    -- Calculate the percentage delivered within the expected lead time.
    ROUND(
        100.0 * SUM(
            CASE
                WHEN DATEDIFF(
                    sh.actual_delivery_date,
                    DATE(shipment_order.order_date)
                ) <= s.lead_time_days
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(sh.shipment_id), 0),
        2
    ) AS supplier_on_time_rate_percent

FROM suppliers s
JOIN products p
    ON s.supplier_id = p.supplier_id
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders shipment_order
    ON oi.order_id = shipment_order.order_id
JOIN shipments sh
    ON shipment_order.order_id = sh.order_id

WHERE sh.actual_delivery_date IS NOT NULL
  AND sh.shipment_date IS NOT NULL

GROUP BY s.supplier_id, s.supplier_name, s.lead_time_days
ORDER BY supplier_on_time_rate_percent DESC;



-- BUSINESS PURPOSE: Identify orders that have no associated order items.
-- CONCEPTS: LEFT JOIN, IS NULL, and data-quality validation.
-- Orders without items may need investigation before sales reporting.

SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    o.customer_id
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE oi.order_item_id IS NULL
ORDER BY o.order_date DESC;



-- BUSINESS PURPOSE: Check whether customer email addresses are duplicated.
-- CONCEPTS: GROUP BY, COUNT, and HAVING.
-- Email addresses are expected to be unique in the customer dataset.
-- NULL and empty email values are excluded from this duplicate check.

SELECT
    LOWER(TRIM(email)) AS normalized_email,
    COUNT(*) AS duplicate_count
FROM customers
WHERE email IS NOT NULL
  AND TRIM(email) <> ''
GROUP BY LOWER(TRIM(email))
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;



-- STEP 102: Check for missing essential customer information.
-- BUSINESS PURPOSE: Identify customer records that may be incomplete.
-- CONCEPTS: IS NULL, TRIM(), and OR.
-- The query checks for NULL values and empty or space-only names.

SELECT
    customer_id,
    first_name,
    last_name,
    signup_date
FROM customers
WHERE first_name IS NULL
   OR TRIM(first_name) = ''
   OR last_name IS NULL
   OR TRIM(last_name) = ''
   OR signup_date IS NULL;
   
   
   
-- STEP 103: Check for invalid order-item quantities and discounts.
-- BUSINESS PURPOSE: Identify order items that could distort revenue calculations.
-- CONCEPTS: WHERE, OR, and comparison operators.
-- Valid quantities must be greater than zero.
-- Valid discount percentages must be between 0 and 100.

SELECT
    order_item_id,
    order_id,
    product_id,
    quantity,
    discount_percent
FROM order_items
WHERE quantity IS NULL
   OR quantity <= 0
   OR discount_percent IS NULL
   OR discount_percent < 0
   OR discount_percent > 100;
-- STEP 103A: Verify whether order_items contains actual records.
-- BUSINESS PURPOSE: Confirm that the table contains data and inspect its latest rows.
-- COUNT(*) counts all records, while SELECT shows the stored values.

SELECT
    COUNT(*) AS total_order_items
FROM order_items;

SELECT
    order_item_id,
    order_id,
    product_id,
    quantity,
    discount_percent
FROM order_items
LIMIT 5;



	-- STEP 103B: Count order items with invalid quantities or discounts.
	-- BUSINESS PURPOSE: Verify data quality without displaying individual records.
	-- A valid quantity must be greater than zero.
	-- A valid discount must be between 0 and 100 percent.

SELECT
		COUNT(*) AS invalid_order_item_count
	FROM order_items
	WHERE quantity IS NULL
	   OR quantity <= 0
	   OR discount_percent IS NULL
	   OR discount_percent < 0
	   OR discount_percent > 100;
       
       
       
       
-- STEP 104: Check payment records for missing or invalid values.
-- BUSINESS PURPOSE: Identify payment data that may affect financial reporting.
-- CONCEPTS: IS NULL, TRIM(), and comparison operators.
-- Payment methods and statuses should not be empty.
-- Payment amounts must be greater than zero.

SELECT
    payment_id,
    order_id,
    payment_method,
    amount,
    payment_status
FROM payments
WHERE payment_method IS NULL
   OR TRIM(payment_method) = ''
   OR payment_status IS NULL
   OR TRIM(payment_status) = ''
   OR amount IS NULL
   OR amount <= 0;
   
   
   
-- STEP 105: Check for inconsistent shipment and delivery dates.
-- BUSINESS PURPOSE: Identify shipment records with impossible date sequences.
-- CONCEPTS: IS NOT NULL and date comparison.
-- An actual delivery date should not precede the shipment date.

SELECT
    shipment_id,
    order_id,
    shipment_date,
    estimated_delivery_date,
    actual_delivery_date
FROM shipments
WHERE shipment_date IS NOT NULL
  AND actual_delivery_date IS NOT NULL
  AND actual_delivery_date < shipment_date;
   

-- STEP 106: Identify returns exceeding the purchased quantity.
-- BUSINESS PURPOSE: Flag return records that may require investigation.
-- CONCEPTS: JOIN, GROUP BY, SUM(), and HAVING.
-- Return quantities are aggregated per order item before comparison.

SELECT
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    oi.quantity AS purchased_quantity,
    SUM(r.return_quantity) AS total_returned_quantity
FROM order_items AS oi
JOIN returns AS r
    ON oi.order_item_id = r.order_item_id
GROUP BY
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    oi.quantity
HAVING SUM(r.return_quantity) > oi.quantity;



-- STEP 106A: Inspect order items whose total returns exceed the purchased quantity.
-- BUSINESS PURPOSE: Understand which return records triggered the validation check.
-- CONCEPTS: JOIN, GROUP BY, SUM(), and HAVING.
-- This query displays the same flagged items with their total returned quantity.

SELECT
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    oi.quantity AS purchased_quantity,
    SUM(r.return_quantity) AS total_returned_quantity,
    SUM(r.return_quantity) - oi.quantity AS excess_return_quantity
FROM order_items AS oi
JOIN returns AS r
    ON oi.order_item_id = r.order_item_id
GROUP BY
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    oi.quantity
HAVING SUM(r.return_quantity) > oi.quantity
ORDER BY excess_return_quantity DESC;



-- STEP 107: Inspect individual return records for flagged order items.
-- BUSINESS PURPOSE: Determine which return entries contribute to excess quantities.
-- CONCEPTS: JOIN and filtering with a subquery.
-- Only order items whose total recorded returns exceed purchased quantity are shown.

SELECT
    r.return_id,
    r.order_item_id,
    oi.quantity AS purchased_quantity,
    r.return_quantity,
    r.return_status,
    r.return_reason,
    r.return_date
FROM returns AS r
JOIN order_items AS oi
    ON r.order_item_id = oi.order_item_id
WHERE r.order_item_id IN (
    SELECT
        oi2.order_item_id
    FROM order_items AS oi2
    JOIN returns AS r2
        ON oi2.order_item_id = r2.order_item_id
    GROUP BY
        oi2.order_item_id,
        oi2.quantity
    HAVING SUM(r2.return_quantity) > oi2.quantity
)
ORDER BY
    r.order_item_id,
    r.return_id;
    
    
    
-- STEP 108: Summarize return records for each flagged order item.
-- BUSINESS PURPOSE: Check whether multiple return entries explain the excess quantity.
-- CONCEPTS: GROUP BY, COUNT(), and SUM().
-- This query summarizes records without changing the underlying data.

SELECT
    r.order_item_id,
    oi.quantity AS purchased_quantity,
    COUNT(r.return_id) AS return_record_count,
    SUM(r.return_quantity) AS total_returned_quantity,
    GROUP_CONCAT(r.return_status ORDER BY r.return_id SEPARATOR ', ')
        AS return_statuses
FROM returns AS r
JOIN order_items AS oi
    ON r.order_item_id = oi.order_item_id
GROUP BY
    r.order_item_id,
    oi.quantity
HAVING SUM(r.return_quantity) > oi.quantity
ORDER BY r.order_item_id;



-- STEP 109: Count return records by return status.
-- BUSINESS PURPOSE: Understand the status of recorded returns.
-- CONCEPTS: GROUP BY and COUNT().
-- Different statuses may represent different stages of the return process.

SELECT
    return_status,
    COUNT(*) AS return_record_count
FROM returns
GROUP BY return_status
ORDER BY return_record_count DESC;



-- STEP 110: Inspect return statuses for order items with excess return quantities.
-- BUSINESS PURPOSE: Determine whether the excess comes from requested or approved returns.
-- CONCEPTS: JOIN, GROUP BY, and HAVING.
-- This query preserves all return records for the flagged items.

SELECT
    r.order_item_id,
    r.return_id,
    oi.quantity AS purchased_quantity,
    r.return_quantity,
    r.return_status,
    r.return_reason
FROM returns AS r
JOIN order_items AS oi
    ON r.order_item_id = oi.order_item_id
WHERE r.order_item_id IN (
    SELECT
        oi2.order_item_id
    FROM order_items AS oi2
    JOIN returns AS r2
        ON oi2.order_item_id = r2.order_item_id
    GROUP BY
        oi2.order_item_id,
        oi2.quantity
    HAVING SUM(r2.return_quantity) > oi2.quantity
)
ORDER BY
    r.order_item_id,
    r.return_id;
    
    
    
-- STEP 111: Check return quantities using approved returns only.
-- BUSINESS PURPOSE: Avoid counting requested returns as approved returns.
-- CONCEPTS: JOIN, WHERE, GROUP BY, SUM(), and HAVING.
-- Only records with the Approved status are included in the total.

SELECT
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    oi.quantity AS purchased_quantity,
    SUM(r.return_quantity) AS approved_return_quantity
FROM order_items AS oi
JOIN returns AS r
    ON oi.order_item_id = r.order_item_id
WHERE r.return_status = 'Approved'
GROUP BY
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    oi.quantity
HAVING SUM(r.return_quantity) > oi.quantity;



-- STEP 112: Inspect approved return records for over-returned items.
-- BUSINESS PURPOSE: Identify the approved return entries contributing to excess quantities.
-- CONCEPTS: JOIN, filtering, and a subquery.
-- Only approved records associated with flagged order items are displayed.

SELECT
    r.return_id,
    r.order_item_id,
    oi.order_id,
    oi.quantity AS purchased_quantity,
    r.return_quantity,
    r.return_status,
    r.return_reason,
    r.return_date
FROM returns AS r
JOIN order_items AS oi
    ON r.order_item_id = oi.order_item_id
WHERE r.return_status = 'Approved'
  AND r.order_item_id IN (
      SELECT
          oi2.order_item_id
      FROM order_items AS oi2
      JOIN returns AS r2
          ON oi2.order_item_id = r2.order_item_id
      WHERE r2.return_status = 'Approved'
      GROUP BY
          oi2.order_item_id,
          oi2.quantity
      HAVING SUM(r2.return_quantity) > oi2.quantity
  )
ORDER BY
    r.order_item_id,
    r.return_id;
    
    
    
-- STEP 113: Summarize approved return quantities for the flagged items.
-- BUSINESS PURPOSE: Confirm how individual approved records add up to the excess.
-- CONCEPTS: GROUP BY, COUNT(), and SUM().
-- This query summarizes approved records without changing the data.

SELECT
    r.order_item_id,
    oi.quantity AS purchased_quantity,
    COUNT(r.return_id) AS approved_return_records,
    SUM(r.return_quantity) AS approved_return_quantity
FROM returns AS r
JOIN order_items AS oi
    ON r.order_item_id = oi.order_item_id
WHERE r.return_status = 'Approved'
GROUP BY
    r.order_item_id,
    oi.quantity
HAVING SUM(r.return_quantity) > oi.quantity
ORDER BY r.order_item_id;



-- STEP 114: Count distinct order items with excess approved returns.
-- BUSINESS PURPOSE: Quantify a return-data quality issue for project reporting.
-- CONCEPTS: Subquery, GROUP BY, HAVING, and COUNT().
-- Each affected order item is counted once, regardless of its number of return records.

SELECT
    COUNT(*) AS items_with_excess_approved_returns
FROM (
    SELECT
        oi.order_item_id
    FROM order_items AS oi
    JOIN returns AS r
        ON oi.order_item_id = r.order_item_id
    WHERE r.return_status = 'Approved'
    GROUP BY
        oi.order_item_id,
        oi.quantity
    HAVING SUM(r.return_quantity) > oi.quantity
) AS flagged_items;



-- STEP 115: Check for negative return refund amounts.
-- BUSINESS PURPOSE: Identify refund records that could distort financial reporting.
-- CONCEPTS: WHERE and comparison operators.
-- A valid refund amount must be zero or greater.

SELECT
    return_id,
    order_item_id,
    refund_amount,
    return_status
FROM returns
WHERE refund_amount < 0;



-- STEP 116: Summarize return records and refund amounts by status.
-- BUSINESS PURPOSE: Understand refund exposure across different return stages.
-- CONCEPTS: GROUP BY, COUNT(), and SUM().
-- Refund totals are reported by status and are not assumed to be completed payments.

SELECT
    return_status,
    COUNT(*) AS return_record_count,
    SUM(refund_amount) AS total_refund_amount,
    AVG(refund_amount) AS average_refund_amount
FROM returns
GROUP BY return_status
ORDER BY total_refund_amount DESC;



-- STEP 117: Verify return-record counts by status.
-- BUSINESS PURPOSE: Reconcile the status counts from previous analyses.
-- CONCEPTS: GROUP BY and COUNT().
-- This query counts the actual records currently stored in the returns table.

SELECT
    return_status,
    COUNT(*) AS actual_record_count
FROM returns
GROUP BY return_status
ORDER BY return_status;



-- STEP 118: Summarize total refunds and affected order items.
-- BUSINESS PURPOSE: Measure the overall recorded refund amount and return coverage.
-- CONCEPTS: SUM(), COUNT(), and COUNT(DISTINCT).
-- Refund amounts represent recorded values, not necessarily completed payouts.

SELECT
    COUNT(*) AS total_return_records,
    COUNT(DISTINCT order_item_id) AS distinct_order_items_returned,
    SUM(refund_amount) AS total_recorded_refunds,
    AVG(refund_amount) AS average_recorded_refund
FROM returns;



-- STEP 119: Check return records for missing essential fields.
-- BUSINESS PURPOSE: Identify incomplete return records that may affect reporting.
-- CONCEPTS: IS NULL and comparison operators.
-- Return date, quantity, status, and refund amount are checked.

SELECT
    return_id,
    order_item_id,
    return_date,
    return_quantity,
    return_status,
    refund_amount
FROM returns
WHERE return_date IS NULL
   OR return_quantity IS NULL
   OR return_quantity <= 0
   OR return_status IS NULL
   OR TRIM(return_status) = ''
   OR refund_amount IS NULL
   OR refund_amount < 0;
   
   
   
-- STEP 120: Count records in each main project table.
-- BUSINESS PURPOSE: Verify the dataset size before final project documentation.
-- CONCEPTS: UNION ALL and COUNT().
-- Each query counts the records in one table.
-- UNION ALL combines the counts into one result without removing rows.

SELECT 'customers' AS table_name, COUNT(*) AS record_count FROM customers
UNION ALL
SELECT 'categories', COUNT(*) FROM categories
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'shipments', COUNT(*) FROM shipments
UNION ALL
SELECT 'returns', COUNT(*) FROM returns
ORDER BY table_name;