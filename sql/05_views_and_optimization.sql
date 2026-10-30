
-- ============================================================
-- PROJECT: Retail Order Analytics
-- FILE: 05_views_and_optimization.sql
-- PURPOSE: Document reusable SQL views and database optimization.
--
-- IMPORTANT:
-- The three views and the index below have already been created
-- successfully in the project database.
--
-- Their CREATE statements are kept inside block comments so
-- they are documented but are not accidentally executed again.
-- The verification queries below are safe to execute.
-- ============================================================

USE retail_order_analytics;


-- ============================================================
-- SECTION 1: ORDER REVENUE VIEW
-- ============================================================

-- BUSINESS PURPOSE:
-- Create a reusable view that calculates discounted revenue
-- for each order.
--
-- NOTE:
-- This view has already been created in the database.
-- Do not remove the block comment and execute it again.

/*
CREATE VIEW vw_order_revenue AS
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    o.customer_id,

    -- Calculate total net revenue across the order's items.
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
*/


-- Retrieve order revenue from the existing view.
SELECT *
FROM vw_order_revenue
ORDER BY order_date DESC;


-- ============================================================
-- SECTION 2: CUSTOMER REVENUE VIEW
-- ============================================================

-- BUSINESS PURPOSE:
-- Create a reusable customer performance report.
-- The view summarizes order counts and net revenue by customer.
--
-- NOTE:
-- This view has already been created in the database.
-- Do not remove the block comment and execute it again.

/*
CREATE VIEW vw_customer_revenue AS
SELECT
    c.customer_id,

    -- Combine first and last names into one readable name.
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,

    -- Count the customer's unique orders.
    COUNT(DISTINCT o.order_id) AS total_orders,

    -- Calculate total discounted revenue across order items.
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
*/


-- Display the highest-revenue customers first.
SELECT *
FROM vw_customer_revenue
ORDER BY total_net_revenue DESC;


-- ============================================================
-- SECTION 3: ORDER PERFORMANCE VIEW
-- ============================================================

-- BUSINESS PURPOSE:
-- Create a consolidated order-level performance report.
--
-- The view brings together:
-- 1. Order details
-- 2. Customer name
-- 3. Net order-item revenue
-- 4. Completed payment total
-- 5. Difference between payments and item revenue
--
-- NOTE:
-- This view has already been created in the database.
-- Do not remove the block comment and execute it again.

/*
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

    -- Calculate the difference between completed payments
    -- and net order-item revenue.
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
*/


-- Display the existing order performance report.
SELECT *
FROM vw_order_performance
ORDER BY order_date DESC;


-- Identify orders with the largest payment discrepancies.
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


-- ============================================================
-- SECTION 4: INDEXING AND QUERY OPTIMIZATION
-- ============================================================

-- BUSINESS PURPOSE:
-- Create an index to support searches using customer_id
-- in the orders table.
--
-- NOTE:
-- This index has already been created successfully.
-- Do not execute this statement again.

/*
CREATE INDEX idx_orders_customer_id
ON orders (customer_id);
*/


-- ============================================================
-- SECTION 5: QUERY PERFORMANCE ANALYSIS
-- ============================================================

-- BUSINESS PURPOSE:
-- Inspect how MySQL plans to execute a query.
--
-- EXPLAIN helps identify the access method and possible indexes
-- MySQL may use when searching for a customer's orders.

EXPLAIN
SELECT
    order_id,
    order_date,
    order_status

FROM orders

WHERE customer_id = 1;


-- ============================================================
-- SECTION 6: INDEX VERIFICATION
-- ============================================================

-- BUSINESS PURPOSE:
-- Inspect the indexes available on the orders table.
--
-- This helps verify whether the customer_id index exists.

SHOW INDEX FROM orders;


-- ============================================================
-- END OF FILE
-- ============================================================
