
-- ============================================================
-- PROJECT: Retail Order Analytics
-- FILE: 04_advanced_analysis.sql
-- PURPOSE: Perform advanced business and operational analysis.
-- SOURCE: Advanced queries from the original project SQL script.
-- ============================================================

USE retail_order_analytics;


-- ============================================================
-- SECTION 1: ADVANCED REVENUE ANALYSIS
-- ============================================================

-- BUSINESS QUESTION: What is the revenue rank of each product?
-- CONCEPTS: CTE, SUM(), GROUP BY, and RANK() window function.

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

    JOIN order_items oi
        ON p.product_id = oi.product_id

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

ORDER BY revenue_rank ASC;


-- BUSINESS QUESTION: How does cumulative net revenue grow each month?
-- CONCEPTS: CTE, DATE_FORMAT(), SUM(), GROUP BY, and window functions.

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

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)

-- Step 2: Calculate cumulative revenue month by month.
SELECT
    order_month,
    total_net_revenue,

    -- Add each month's revenue to the previous cumulative total.
    ROUND(
        SUM(total_net_revenue) OVER (
            ORDER BY order_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS cumulative_net_revenue

FROM monthly_revenue

ORDER BY order_month ASC;


-- BUSINESS QUESTION: Track monthly revenue and month-over-month growth.
-- CONCEPTS: CTEs, DATE_FORMAT(), GROUP BY, and LAG() window function.

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

    -- Calculate the absolute change from the previous month.
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


-- BUSINESS QUESTION: Which products generate the highest revenue
-- within their respective categories?
-- CONCEPTS: CTEs, GROUP BY, PARTITION BY, and RANK().

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
    -- Rank products by revenue within each category.
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

-- Return the highest-revenue product or products in each category.
SELECT
    category_name,
    product_name,
    total_net_revenue,
    category_revenue_rank

FROM category_rankings

WHERE category_revenue_rank = 1

ORDER BY category_name;


-- ============================================================
-- SECTION 2: CUSTOMER SEGMENTATION AND ORDER VALUE
-- ============================================================

-- BUSINESS QUESTION: What is the average net value of an order?
-- CONCEPTS: CTE, SUM(), GROUP BY, AVG(), and ROUND().

-- Step 1: Calculate the net revenue for each order.
WITH order_totals AS (
    SELECT
        o.order_id,

        -- Add discounted revenue across all items in this order.
        SUM(
            oi.quantity * oi.unit_price
            * (1 - oi.discount_percent / 100)
        ) AS order_net_revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY o.order_id
)

-- Step 2: Calculate the average order value.
SELECT
    ROUND(AVG(order_net_revenue), 2) AS average_order_value

FROM order_totals;


-- BUSINESS QUESTION: Compare customers by their average spending per order.
-- CONCEPTS: CTEs, JOIN, COUNT(), AVG(), and GROUP BY.

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

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name

ORDER BY average_order_value DESC;


-- BUSINESS QUESTION: Identify repeat customers and measure their spending.
-- CONCEPTS: JOIN, GROUP BY, HAVING, COUNT(), and SUM().

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

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name

-- Include only customers with more than one order.
HAVING COUNT(DISTINCT o.order_id) > 1

ORDER BY total_net_revenue DESC;


-- BUSINESS QUESTION: Compare one-time and repeat customers.
-- CONCEPTS: CTEs, CASE, GROUP BY, and aggregate functions.

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


-- ============================================================
-- SECTION 3: SHIPMENT AND DELIVERY PERFORMANCE
-- ============================================================

-- BUSINESS QUESTION: Which shipments arrived later than expected?
-- CONCEPTS: JOIN, WHERE, DATEDIFF(), and ORDER BY.

SELECT
    s.shipment_id,
    s.order_id,
    s.courier_name,
    s.estimated_delivery_date,
    s.actual_delivery_date,

    -- Calculate the number of calendar days the shipment was late.
    DATEDIFF(
        s.actual_delivery_date,
        s.estimated_delivery_date
    ) AS days_late

FROM shipments s

JOIN orders o
    ON s.order_id = o.order_id

-- Keep shipments delivered after their estimated delivery date.
WHERE s.actual_delivery_date > s.estimated_delivery_date

ORDER BY days_late DESC;


-- BUSINESS QUESTION: What percentage of completed deliveries were on time?
-- CONCEPTS: COUNT(), SUM(), CASE, NULLIF(), and percentage calculation.

SELECT
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

-- Exclude records without an estimated delivery date.
AND estimated_delivery_date IS NOT NULL;


-- ============================================================
-- SECTION 4: INVENTORY AND RESTOCKING ANALYSIS
-- ============================================================

-- BUSINESS QUESTION: Which products need restocking?
-- CONCEPTS: WHERE, comparison operators, and ORDER BY.

SELECT
    product_id,
    product_name,
    stock_quantity,
    reorder_level,

    -- Calculate the additional units needed to reach the reorder level.
    reorder_level - stock_quantity AS units_to_reorder

FROM products

-- Find products whose stock is at or below the reorder threshold.
WHERE stock_quantity <= reorder_level

ORDER BY stock_quantity ASC;


-- BUSINESS QUESTION: Identify products that may need restocking
-- and compare their stock with units sold.
-- CONCEPTS: JOIN, GROUP BY, SUM(), HAVING, and ORDER BY.

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


-- ============================================================
-- SECTION 5: RETURN ANALYSIS AND DATA QUALITY
-- ============================================================

-- BUSINESS QUESTION: What percentage of ordered units were returned
-- for each product?
-- CONCEPTS: CTE, LEFT JOIN, SUM(), COALESCE(), and percentage calculation.
-- Return quantities are first aggregated by order item to avoid
-- multiplying purchased quantities when multiple return records exist.

WITH return_totals AS (
    -- Calculate total returned quantity for each order item.
    SELECT
        order_item_id,
        SUM(return_quantity) AS total_returned_quantity
    FROM returns
    GROUP BY order_item_id
)

SELECT
    p.product_id,
    p.product_name,

    -- Calculate the total number of units ordered for this product.
    SUM(oi.quantity) AS total_units_ordered,

    -- Add returned quantities, using zero when no return exists.
    COALESCE(SUM(rt.total_returned_quantity), 0) AS total_units_returned,

    -- Calculate the returned quantity as a percentage of ordered units.
    ROUND(
        100.0 * COALESCE(SUM(rt.total_returned_quantity), 0)
        / NULLIF(SUM(oi.quantity), 0),
        2
    ) AS return_rate_pct

FROM products p

JOIN order_items oi
    ON p.product_id = oi.product_id

LEFT JOIN return_totals rt
    ON oi.order_item_id = rt.order_item_id

GROUP BY
    p.product_id,
    p.product_name

ORDER BY return_rate_pct DESC;


-- BUSINESS QUESTION: Identify order items whose total recorded
-- return quantity exceeds the purchased quantity.
-- CONCEPTS: JOIN, GROUP BY, SUM(), and HAVING.

SELECT
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    oi.quantity AS purchased_quantity,
    SUM(r.return_quantity) AS total_returned_quantity

FROM order_items oi

JOIN returns r
    ON oi.order_item_id = r.order_item_id

GROUP BY
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    oi.quantity

HAVING SUM(r.return_quantity) > oi.quantity;


-- BUSINESS QUESTION: Check approved returns that exceed the
-- purchased quantity.
-- CONCEPTS: JOIN, WHERE, GROUP BY, SUM(), and HAVING.

SELECT
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    oi.quantity AS purchased_quantity,
    SUM(r.return_quantity) AS approved_return_quantity

FROM order_items oi

JOIN returns r
    ON oi.order_item_id = r.order_item_id

WHERE r.return_status = 'Approved'

GROUP BY
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    oi.quantity

HAVING SUM(r.return_quantity) > oi.quantity;


-- BUSINESS QUESTION: Count distinct order items with excess approved returns.
-- CONCEPTS: Subquery, GROUP BY, HAVING, and COUNT().

SELECT
    COUNT(*) AS items_with_excess_approved_returns

FROM (
    SELECT
        oi.order_item_id

    FROM order_items oi

    JOIN returns r
        ON oi.order_item_id = r.order_item_id

    WHERE r.return_status = 'Approved'

    GROUP BY
        oi.order_item_id,
        oi.quantity

    HAVING SUM(r.return_quantity) > oi.quantity

) AS flagged_items;


-- BUSINESS QUESTION: Summarize return records and refund amounts by status.
-- CONCEPTS: GROUP BY, COUNT(), SUM(), and AVG().

SELECT
    return_status,
    COUNT(*) AS return_record_count,
    SUM(refund_amount) AS total_refund_amount,
    AVG(refund_amount) AS average_refund_amount

FROM returns

GROUP BY return_status

ORDER BY total_refund_amount DESC;


-- ============================================================
-- END OF ADVANCED ANALYSIS
-- ============================================================
