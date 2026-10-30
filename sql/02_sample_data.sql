-- ============================================================
-- PROJECT: Retail Order Analytics
-- FILE: 02_sample_data.sql
-- PURPOSE: Insert the sample records into all nine tables.
-- NOTE: The dataset contains synthetic sample data.
-- ============================================================

-- Select the existing project database.
USE retail_order_analytics;


-- ============================================================
-- 1. INSERT CATEGORY RECORDS
-- Categories are inserted before products because products
-- reference category_id through a foreign key.
-- ============================================================

INSERT INTO categories (category_name, description)
VALUES
    ('Electronics', 'Electronic devices and accessories'),
    ('Clothing', 'Apparel and fashion products'),
    ('Home & Kitchen', 'Home appliances and kitchen essentials'),
    ('Beauty', 'Beauty and personal care products'),
    ('Sports', 'Sports and fitness equipment');


-- ============================================================
-- 2. INSERT SUPPLIER RECORDS
-- Suppliers are inserted before products because products
-- reference supplier_id through a foreign key.
-- ============================================================

INSERT INTO suppliers
    (supplier_name, contact_email, city, supplier_region, lead_time_days)
VALUES
    ('TechSource India', 'sales@techsource.example', 'Pune', 'West', 4),
    ('FashionHub Supplies', 'contact@fashionhub.example', 'Mumbai', 'West', 6),
    ('HomeEssentials Co', 'orders@homeessentials.example', 'Delhi', 'North', 8),
    ('BeautyWorld Distributors', 'sales@beautyworld.example', 'Bengaluru', 'South', 5),
    ('ActiveGear Wholesale', 'info@activegear.example', 'Hyderabad', 'South', 7),
    ('Global Retail Supply', 'support@globalretail.example', 'Kolkata', 'East', 10);


-- ============================================================
-- 3. INSERT PRODUCT RECORDS
-- Each product is linked to an existing category and supplier.
-- ============================================================

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


-- ============================================================
-- 4. INSERT CUSTOMER RECORDS
-- Customer records are inserted before orders because
-- orders reference customer_id.
-- ============================================================

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


-- ============================================================
-- 5. INSERT ORDER RECORDS
-- Each order is linked to an existing customer.
-- ============================================================

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


-- ============================================================
-- 6. INSERT ORDER ITEM RECORDS
-- Each order item references an existing order and product.
-- ============================================================

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


-- ============================================================
-- 7. INSERT PAYMENT RECORDS
-- Each payment is linked to an existing order.
-- ============================================================

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


-- ============================================================
-- 8. INSERT SHIPMENT RECORDS
-- Each shipment is linked to an existing order.
-- NULL actual_delivery_date means the shipment has not
-- yet been recorded as delivered.
-- ============================================================

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


-- ============================================================
-- 9. INSERT RETURN RECORDS
-- Each return references an existing order_item_id.
-- ============================================================

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


-- ============================================================
-- END OF SAMPLE DATA INSERTION SCRIPT
-- ============================================================