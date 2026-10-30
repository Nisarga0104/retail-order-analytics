
-- ============================================================
-- PROJECT: Retail Order Analytics
-- FILE: 06_data_quality_and_reconciliation.sql
-- PURPOSE: Financial reconciliation, operational analysis,
--          and data-quality validation.
--
-- DATASET: Synthetic retail dataset.
-- DATABASE: MySQL 8.0
-- ============================================================

USE retail_order_analytics;


-- ============================================================
-- SECTION 1: PAYMENT RECONCILIATION
-- ============================================================

-- BUSINESS PURPOSE:
-- Compare each order's net item value with its completed payments.
--
-- IMPORTANT:
-- Order item revenue is calculated after discounts.
-- Only payments marked as Completed are included.
-- Differences are potential discrepancies, not automatically errors.


-- QUERY 1: Compare order-item totals with completed payments.

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

    -- Add up only completed payments for each order.
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

    COALESCE(pt.completed_payment_total, 0)
        AS completed_payment_total,

    -- Calculate the difference between completed payments
    -- and the net value of the order items.
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


-- QUERY 2: Identify orders with potential payment discrepancies.

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

    COALESCE(pt.completed_payment_total, 0)
        AS completed_payment_total,

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

-- Show only orders where the two totals do not match.
WHERE ROUND(
    COALESCE(pt.completed_payment_total, 0)
    - COALESCE(ot.order_item_total, 0),
    2
) <> 0

ORDER BY o.order_id;


-- QUERY 3: Classify orders by their reconciliation status.

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

    -- Bring both totals together and calculate the difference.
    SELECT
        o.order_id,

        COALESCE(ot.order_item_total, 0) AS order_item_total,

        COALESCE(pt.completed_payment_total, 0)
            AS completed_payment_total,

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

    -- Assign a readable reconciliation category.
    CASE
        WHEN payment_difference = 0 THEN 'Matched'
        WHEN payment_difference > 0 THEN 'Overpaid'
        ELSE 'Underpaid or unpaid'
    END AS reconciliation_status

FROM reconciliation

ORDER BY order_id;


-- QUERY 4: Summarize the number of orders in each reconciliation category.

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


-- QUERY 5: Calculate the percentage of orders with payment discrepancies.

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

    -- Compare completed payment totals with item totals.
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

    -- Count orders with a non-zero payment difference.
    SUM(
        CASE
            WHEN payment_difference <> 0 THEN 1
            ELSE 0
        END
    ) AS flagged_orders,

    -- Calculate the percentage of flagged orders.
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


-- ============================================================
-- SECTION 2: PAYMENT METHOD ANALYSIS
-- ============================================================

-- BUSINESS PURPOSE:
-- Compare completed payment revenue across payment methods.
-- Only payments marked as Completed are included.

SELECT
    payment_method,

    COUNT(*) AS completed_payment_transactions,

    ROUND(SUM(amount), 2) AS total_completed_payment_revenue

FROM payments

WHERE payment_status = 'Completed'

GROUP BY payment_method

ORDER BY total_completed_payment_revenue DESC;


-- ============================================================
-- SECTION 3: ORDER CANCELLATION ANALYSIS
-- ============================================================

-- BUSINESS PURPOSE:
-- Calculate the percentage of orders that were cancelled.
-- Cancellation rate = cancelled orders / all orders * 100.

SELECT
    COUNT(*) AS total_orders,

    -- Count orders whose status is Cancelled.
    SUM(
        CASE
            WHEN LOWER(order_status) = 'cancelled' THEN 1
            ELSE 0
        END
    ) AS cancelled_orders,

    -- Calculate the cancellation percentage.
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


-- ============================================================
-- SECTION 4: SHIPMENT AND COURIER PERFORMANCE
-- ============================================================

-- QUERY 1: Calculate the percentage of shipments marked Delivered.

SELECT
    COUNT(*) AS total_shipments,

    -- Count shipments whose status is Delivered.
    SUM(
        CASE
            WHEN LOWER(shipment_status) = 'delivered' THEN 1
            ELSE 0
        END
    ) AS delivered_shipments,

    -- Calculate the percentage of delivered shipments.
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


-- QUERY 2: Compare delivery performance across courier companies.

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

FROM shipments

GROUP BY courier_name

ORDER BY delivery_rate_percent DESC;


-- QUERY 3: Identify couriers with longer delivery delays.

SELECT
    courier_name,

    -- Count shipments delivered later than estimated.
    COUNT(*) AS late_shipments,

    -- Calculate the average delay in calendar days.
    ROUND(
        AVG(
            DATEDIFF(
                actual_delivery_date,
                estimated_delivery_date
            )
        ),
        2
    ) AS average_delay_days,

    -- Find the longest recorded delivery delay.
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


-- ============================================================
-- SECTION 5: DATA QUALITY VALIDATION
-- ============================================================

-- QUERY 1: Identify orders without associated order items.
-- Such orders may require investigation before sales reporting.

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


-- QUERY 2: Check whether customer email addresses are duplicated.
-- NULL and empty email values are excluded from this check.

SELECT
    LOWER(TRIM(email)) AS normalized_email,

    COUNT(*) AS duplicate_count

FROM customers

WHERE email IS NOT NULL
  AND TRIM(email) <> ''

GROUP BY LOWER(TRIM(email))

HAVING COUNT(*) > 1

ORDER BY duplicate_count DESC;


-- QUERY 3: Check for missing essential customer information.
-- Names and signup dates are checked for missing values.

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


-- QUERY 4: Check for invalid order-item quantities and discounts.
-- Valid quantities must be greater than zero.
-- Valid discounts must be between 0 and 100 percent.

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


-- QUERY 5: Check payment records for missing or invalid values.
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


-- QUERY 6: Check for inconsistent shipment and delivery dates.
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


-- QUERY 7: Check return records for missing essential fields.
-- Valid return quantities must be greater than zero.
-- Refund amounts must be zero or greater.

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


-- ============================================================
-- SECTION 6: FINAL DATASET RECORD COUNTS
-- ============================================================

-- BUSINESS PURPOSE:
-- Count records in all nine project tables.
-- This provides a final overview of the dataset size.

SELECT 'customers' AS table_name, COUNT(*) AS record_count
FROM customers

UNION ALL

SELECT 'categories', COUNT(*)
FROM categories

UNION ALL

SELECT 'suppliers', COUNT(*)
FROM suppliers

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'payments', COUNT(*)
FROM payments

UNION ALL

SELECT 'shipments', COUNT(*)
FROM shipments

UNION ALL

SELECT 'returns', COUNT(*)
FROM returns

ORDER BY table_name;


-- ============================================================
-- END OF FILE
-- ============================================================
