Olist Brazilian Ecommerce SQL Analysis
Student project using real public dataset from Kaggle

Dataset link
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

How to use
Load the CSV files into your database first.
Use these table names: orders, order_items, customers, products, order_payments, order_reviews, sellers, category_translation
Then run each query below one by one.


1. Check how many rows are in each table

SELECT 'orders' AS table_name, COUNT(*) AS row_count FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'category_translation', COUNT(*) FROM category_translation;


2. See the different order statuses

SELECT order_status, COUNT(*) AS cnt,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) AS pct
FROM orders
GROUP BY order_status
ORDER BY cnt DESC;


3. Overall business numbers for delivered orders only

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    COUNT(DISTINCT oi.product_id) AS unique_products_sold,
    ROUND(SUM(oi.price), 2) AS total_product_revenue,
    ROUND(SUM(oi.freight_value), 2) AS total_freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_gmv,
    ROUND(AVG(oi.price), 2) AS avg_item_price,
    ROUND(SUM(oi.price + oi.freight_value) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';


4. Monthly sales trend

SELECT 
    strftime('%Y-%m', order_purchase_timestamp) AS month,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS product_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1;


5. Revenue by customer state

SELECT 
    c.customer_state AS state,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    ROUND(SUM(oi.price), 2) AS product_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue,
    ROUND(SUM(oi.price + oi.freight_value) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


6. Top product categories in English

SELECT 
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
    COUNT(*) AS items_sold,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN category_translation t 
    ON p.product_category_name = t.product_category_name
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY revenue DESC
LIMIT 20;


7. Delivery performance by state

SELECT 
    c.customer_state,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(
        julianday(o.order_delivered_customer_date) - julianday(o.order_estimated_delivery_date)
    ), 2) AS avg_delay_days,
    ROUND(AVG(
        julianday(o.order_delivered_customer_date) - julianday(o.order_purchase_timestamp)
    ), 1) AS avg_delivery_days_from_purchase,
    SUM(CASE WHEN julianday(o.order_delivered_customer_date) > julianday(o.order_estimated_delivery_date) THEN 1 ELSE 0 END) AS late_orders,
    ROUND(100.0 * SUM(CASE WHEN julianday(o.order_delivered_customer_date) > julianday(o.order_estimated_delivery_date) THEN 1 ELSE 0 END) / COUNT(*), 1) AS late_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delay_days DESC;


8. Review score distribution

SELECT 
    r.review_score,
    COUNT(*) AS review_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM order_reviews), 2) AS pct
FROM order_reviews r
GROUP BY r.review_score
ORDER BY r.review_score;


9. Payment methods used

SELECT 
    payment_type,
    COUNT(*) AS payment_count,
    ROUND(SUM(payment_value), 2) AS total_value,
    ROUND(AVG(payment_installments), 1) AS avg_installments
FROM order_payments
GROUP BY payment_type
ORDER BY total_value DESC;


10. One time customers versus repeat customers

WITH customer_orders AS (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT 
    CASE 
        WHEN order_count = 1 THEN 'One time'
        WHEN order_count = 2 THEN 'Two orders'
        ELSE 'Three or more orders'
    END AS customer_type,
    COUNT(*) AS customers,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer_orders), 2) AS pct
FROM customer_orders
GROUP BY 1
ORDER BY 1;


11. Freight cost compared to product price by state

SELECT 
    c.customer_state,
    ROUND(AVG(oi.freight_value / NULLIF(oi.price, 0) * 100), 1) AS avg_freight_pct_of_price,
    ROUND(SUM(oi.freight_value), 2) AS total_freight,
    ROUND(SUM(oi.price), 2) AS total_product_revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND oi.price > 0
GROUP BY c.customer_state
ORDER BY avg_freight_pct_of_price DESC;
