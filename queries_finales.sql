-- E-commerce & Seller Performance Analytics
-- SQL Project – Olist Dataset
-- Tools: SQLite / DB Browser for SQLite


-- 1. Sales amount by seller
SELECT 
    sellers.seller_id,
    SUM(order_items.price) AS montant_ventes
FROM order_items
JOIN sellers
ON order_items.seller_id = sellers.seller_id
GROUP BY sellers.seller_id
ORDER BY montant_ventes DESC;


-- 2. Seller performance KPIs
SELECT 
    sellers.seller_id,
    SUM(order_items.price) AS montant_ventes,
    COUNT(DISTINCT order_items.order_id) AS nombre_commandes,
    ROUND(
        SUM(order_items.price) / COUNT(DISTINCT order_items.order_id),
        2
    ) AS panier_moyen
FROM order_items
JOIN sellers
ON order_items.seller_id = sellers.seller_id
GROUP BY sellers.seller_id
ORDER BY montant_ventes DESC;


-- 3. Top 10 sellers
SELECT 
    sellers.seller_id,
    SUM(order_items.price) AS montant_ventes
FROM order_items
JOIN sellers
ON order_items.seller_id = sellers.seller_id
GROUP BY sellers.seller_id
ORDER BY montant_ventes DESC
LIMIT 10;


-- 4. Best seller by product category
WITH performance_vendeurs AS (
    SELECT 
        products.product_category_name,
        sellers.seller_id,
        SUM(order_items.price) AS montant_ventes
    FROM order_items
    JOIN sellers
    ON order_items.seller_id = sellers.seller_id
    JOIN products
    ON order_items.product_id = products.product_id
    GROUP BY products.product_category_name,
             sellers.seller_id
),
classement AS (
    SELECT 
        product_category_name,
        seller_id,
        montant_ventes,
        RANK() OVER (
            PARTITION BY product_category_name
            ORDER BY montant_ventes DESC
        ) AS rang_vendeur
    FROM performance_vendeurs
)
SELECT 
    product_category_name,
    seller_id,
    montant_ventes
FROM classement
WHERE rang_vendeur = 1
ORDER BY montant_ventes DESC;


-- 5. Customers with multiple orders
SELECT 
    customers.customer_unique_id,
    COUNT(DISTINCT orders.order_id) AS nombre_commandes
FROM customers
JOIN orders
ON customers.customer_id = orders.customer_id
GROUP BY customers.customer_unique_id
HAVING COUNT(DISTINCT orders.order_id) >= 2
ORDER BY nombre_commandes DESC;


-- 6. Monthly sales performance
SELECT 
    strftime('%Y-%m', orders.order_purchase_timestamp) AS mois,
    SUM(order_items.price) AS montant_ventes
FROM orders
JOIN order_items
ON orders.order_id = order_items.order_id
GROUP BY mois
ORDER BY mois;


-- 7. Monthly seller performance
SELECT 
    sellers.seller_id,
    strftime('%Y-%m', orders.order_purchase_timestamp) AS mois,
    SUM(order_items.price) AS montant_ventes
FROM order_items
JOIN sellers
ON order_items.seller_id = sellers.seller_id
JOIN orders
ON order_items.order_id = orders.order_id
GROUP BY sellers.seller_id,
         mois
ORDER BY sellers.seller_id,
         mois;