-- ============================================
-- RETAILPULSE | 04_intermediate_queries.sql
-- Phase 3 — JOINs, Subqueries & Aggregations
-- ============================================


-- -----------------------------------------------
-- SECTION 1: BASIC JOINs
-- -----------------------------------------------

-- Q1: Show all orders with the customer's full name
-- Why it matters: Raw order data has no names — analysts always join to humanise the data
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name  AS customer_name,
    c.country,
    o.order_date,
    o.status,
    o.payment_method
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date DESC;


-- Q2: Show every order item with product name and category
-- Why it matters: Tells you WHAT people are actually buying
SELECT
    oi.order_id,
    p.product_name,
    cat.category_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price  AS line_total
FROM order_items oi
JOIN products  p   ON oi.product_id  = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
ORDER BY oi.order_id;


-- Q3: Total revenue per order (with customer name)
-- Why it matters: Every business tracks order values
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name      AS customer_name,
    o.order_date,
    o.status,
    SUM(oi.quantity * oi.unit_price)         AS items_total,
    o.shipping_cost,
    SUM(oi.quantity * oi.unit_price)
        + o.shipping_cost                    AS order_total
FROM orders o
JOIN customers   c  ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
GROUP BY
    o.order_id, c.first_name, c.last_name,
    o.order_date, o.status, o.shipping_cost
ORDER BY order_total DESC;


-- -----------------------------------------------
-- SECTION 2: LEFT JOIN — catch missing data
-- -----------------------------------------------

-- Q4: Find customers who have NEVER placed an order
-- Why it matters: These are churned or inactive users — marketing needs this list
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name  AS customer_name,
    c.email,
    c.country,
    c.registration_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY c.registration_date;


-- Q5: All products and how many times they've been ordered (include unsold)
-- Why it matters: Inventory teams need to know what's not selling
SELECT
    p.product_name,
    cat.category_name,
    p.price,
    p.stock_qty,
    COUNT(oi.item_id)            AS times_ordered,
    COALESCE(SUM(oi.quantity), 0) AS total_units_sold
FROM products p
JOIN categories cat  ON p.category_id  = cat.category_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, cat.category_name, p.price, p.stock_qty
ORDER BY total_units_sold DESC;


-- -----------------------------------------------
-- SECTION 3: GROUP BY + HAVING
-- -----------------------------------------------

-- Q6: Total revenue by product category
-- Why it matters: Shows which category drives the most money
SELECT
    cat.category_name,
    COUNT(DISTINCT oi.order_id)          AS total_orders,
    SUM(oi.quantity)                     AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price)::NUMERIC, 2)  AS total_revenue
FROM order_items oi
JOIN products   p   ON oi.product_id  = p.product_id
JOIN categories cat ON p.category_id  = cat.category_id
GROUP BY cat.category_name
ORDER BY total_revenue DESC;


-- Q7: Customers who have spent more than $500 in total
-- Why it matters: These are your VIP customers — retention priority
SELECT
    c.first_name || ' ' || c.last_name  AS customer_name,
    c.country,
    COUNT(DISTINCT o.order_id)           AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price)::NUMERIC, 2)  AS total_spent
FROM customers c
JOIN orders      o  ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
HAVING SUM(oi.quantity * oi.unit_price) > 500
ORDER BY total_spent DESC;


-- Q8: Revenue by payment method
-- Why it matters: Finance teams track this to negotiate processing fees
SELECT
    payment_method,
    COUNT(*)                                              AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price)::NUMERIC, 2)  AS total_revenue,
    ROUND(AVG(oi.quantity * oi.unit_price)::NUMERIC, 2)  AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY payment_method
ORDER BY total_revenue DESC;


-- -----------------------------------------------
-- SECTION 4: SUBQUERIES
-- -----------------------------------------------

-- Q9: Products priced above the average product price
-- Why it matters: Pricing analysis — knowing your premium tier
SELECT
    product_name,
    category_id,
    price,
    ROUND((price - (SELECT AVG(price) FROM products))::NUMERIC, 2)
        AS above_avg_by
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;


-- Q10: The single highest value order
-- Why it matters: Useful for anomaly detection and VIP identification
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name  AS customer_name,
    o.order_date,
    SUM(oi.quantity * oi.unit_price)    AS order_total
FROM orders o
JOIN customers   c  ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
GROUP BY o.order_id, c.first_name, c.last_name, o.order_date
HAVING SUM(oi.quantity * oi.unit_price) = (
    SELECT MAX(order_total)
    FROM (
        SELECT SUM(quantity * unit_price) AS order_total
        FROM order_items
        GROUP BY order_id
    ) sub
)
ORDER BY order_total DESC;


-- Q11: Customers who ordered in 2023 but NOT in 2024
-- Why it matters: Classic churn detection query — who did we lose this year?
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name  AS customer_name,
    c.email,
    c.country
FROM customers c
WHERE c.customer_id IN (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE EXTRACT(YEAR FROM order_date) = 2023
)
AND c.customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE EXTRACT(YEAR FROM order_date) = 2024
)
ORDER BY c.customer_id;


-- -----------------------------------------------
-- SECTION 5: CASE WHEN — business segmentation
-- -----------------------------------------------

-- Q12: Segment customers by total spending
-- Why it matters: Customer tiering is used in every retail business
SELECT
    c.first_name || ' ' || c.last_name          AS customer_name,
    c.country,
    ROUND(SUM(oi.quantity * oi.unit_price)::NUMERIC, 2)  AS total_spent,
    CASE
        WHEN SUM(oi.quantity * oi.unit_price) >= 1000 THEN 'Platinum'
        WHEN SUM(oi.quantity * oi.unit_price) >= 500  THEN 'Gold'
        WHEN SUM(oi.quantity * oi.unit_price) >= 200  THEN 'Silver'
        ELSE                                               'Bronze'
    END  AS customer_tier
FROM customers c
JOIN orders      o  ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
ORDER BY total_spent DESC;


-- Q13: Order status breakdown with % share
-- Why it matters: Operations teams monitor fulfilment health daily
SELECT
    status,
    COUNT(*)                                         AS order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1)  AS pct_share
FROM orders
GROUP BY status
ORDER BY order_count DESC;