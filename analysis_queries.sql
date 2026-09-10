-- Overall Business Analysis
-- Q1. What is total number of orders , customers , products and sellers?
SELECT (SELECT COUNT(order_id) FROM orders) AS total_orders,
(SELECT COUNT(customer_id) FROM customers) AS total_customers , 
(SELECT COUNT(product_id) FROM products) AS total_products ,
(SELECT COUNT(seller_id) FROM sellers) AS total_sellers;

-- Q2. What is total revenue and average order value?
SELECT SUM(payment_value) AS total_revenue,
AVG(payment_value) AS average_order_value FROM order_payments;

-- Q3. What are the different order statuses and how many orders are in each status?
SELECT order_status , COUNT(order_id) AS total_orders FROM orders 
GROUP BY order_status ORDER BY total_orders DESC;

-- Q4. What is monthly revenue trend?
SELECT YEAR(o.order_purchase_timestamp) AS year ,
MONTH(o.order_purchase_timestamp) AS month ,
SUM(p.payment_value) AS monthly_revenue FROM orders o JOIN order_payments p ON o.order_id = p.order_id 
GROUP BY YEAR(o.order_purchase_timestamp) , MONTH(o.order_purchase_timestamp) 
ORDER BY year , month ;

-- Customer Analysis
-- Q5. What are the top 10 customers by total_spending?
SELECT o.customer_id , SUM(p.payment_value) AS total_spending FROM orders o JOIN order_payments p 
On o.order_id = p.order_id GROUP BY o.customer_id ORDER BY total_spending DESC LIMIT 5;

-- Q6. Find the top 5 product categories based on total sales revenue?
SELECT p.product_category_name , SUM(oi.price) AS total_revenue 
FROM order_items oi JOIN products p  on oi.product_id = p.product_id 
GROUP BY p.product_category_name 
ORDER BY total_revenue DESC LIMIT 5;

-- Q7. Which customers have placed more than one order?
SELECT customer_id , COUNT(order_id) as total_orders FROM orders
GROUP BY customer_id HAVING COUNT(order_id) > 1 ORDER BY total_orders DESC;

-- Q8. What is average spending per customer?
SELECT AVG(total_spending) AS average_customer_spending FROM
(SELECT o.customer_id , SUM(p.payment_value) AS total_spending 
FROM orders o JOIN order_payments p ON o.order_id = p.order_id 
GROUP BY o.customer_id ) AS customer_spending;

-- Q9. Find the customers whose spending is above the average customer spending?
SELECT o.customer_id , SUM(p.payment_value) AS total_spending
FROM orders o JOIN order_payments p ON o.order_id = p.order_id GROUP BY
o.customer_id HAVING SUM(p.payment_value) > (SELECT AVG(payment_value) FROM order_payments)
ORDER BY total_spending DESC;

-- Product & Category Analysis
-- Q10. What are the top 10 best-selling products by quantity?
SELECT p.product_id , p.product_category_name , COUNT(*) AS total_sold 
FROM order_items oi JOIN products p ON oi.product_id = p.product_id 
GROUP BY p.product_id , p.product_category_name 
ORDER BY total_sold DESC LIMIT 10;

-- Q11. Which product categories generate the highest revenue?
SELECT p.product_category_name , SUM(oi.price) as total_revenue 
FROM products p JOIN order_items oi ON p.product_id = oi.product_id 
GROUP BY p.product_category_name ORDER BY total_revenue DESC LIMIT 1;

-- Q12. Which product categories have the highest average product price?
SELECT p.product_category_name , AVG(oi.price) as average_price
FROM products p JOIN order_items oi ON p.product_id = oi.product_id 
GROUP BY p.product_category_name ORDER BY average_price DESC LIMIT 1;

-- Q13. Which categories have the highest average product price?
SELECT p.product_category_name , AVG(oi.price) AS average_price 
FROM order_items oi JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name ORDER BY average_price DESC LIMIT 1;

-- Q14. Find the best-selling product in each category?
SELECT product_category_name , product_id , total_sold FROM
(SELECT p.product_category_name , oi.product_id , COUNT(*) AS total_sold ,
RANK() OVER (PARTITION BY p.product_category_name ORDER BY COUNT(*) DESC) AS product_rank 
FROM order_items oi JOIN products p ON oi.product_id = p.product_id
 GROUP BY p.product_category_name , oi.product_id ) AS ranked_products 
 WHERE product_rank = 1 ORDER BY product_category_name;
 
 -- Seller Analysis
 -- Q15.  Find the top 10 sellers by revenue?
SELECT seller_id , SUM(price) as total_revenue FROM order_items 
GROUP BY seller_id ORDER BY total_revenue DESC LIMIT 10;

-- Q16. Which sellers have sold the highest number of products?
SELECT seller_id , COUNT(*) AS products_sold FROM order_items
GROUP BY seller_id ORDER BY products_sold DESC LIMIT 10;
 
-- Q17. What is the average order-item value for each seller?
SELECT seller_id , AVG(price) AS average_item_value FROM order_items 
GROUP BY seller_id ORDER BY average_item_value DESC;

-- Q18. Find the top 3 sellers in each customer state?
SELECT * FROM (SELECT c.customer_state , oi.seller_id , SUM(oi.price) AS total_revenue,
DENSE_RANK() OVER (PARTITION BY c.customer_state ORDER BY SUM(oi.price) DESC) AS seller_rank
FROM order_items oi JOIN orders o ON oi.order_id = o.order_id 
JOIN customers c ON c.customer_id = o.customer_id GROUP BY c.customer_state , oi.seller_id) AS ranked_sellers
WHERE seller_rank <= 3 ORDER BY customer_state , seller_rank;

-- Payment & Review Analysis
-- Q19. What is the total payment amount by payment method?
SELECT payment_type , SUM(payment_value) AS total_payment FROM order_payments 
GROUP BY payment_type ORDER BY total_payment DESC;

-- Q20. What percentage of total payments comes from each payment method?
SELECT payment_type , SUM(payment_value) AS total_payment ,
ROUND(SUM(payment_value) * 100 / (SELECT SUM(payment_value) FROM order_payments),2) AS percentage 
FROM order_payments GROUP BY payment_type ORDER BY percentage DESC;

-- Q21. What is the distribution of review scores?
SELECT review_score , COUNT(*) AS total_reviews FROM order_reviews
GROUP BY review_score 
ORDER BY review_score;

-- Q22. What is the number of reviews for each review score ?
SELECT review_score, COUNT(*) AS total_reviews FROM order_reviews 
GROUP BY review_score ORDER BY review_score;

-- Q23. Compare average order value for different payment methods. 
SELECT payment_type , AVG(payment_value) AS average_order_value FROM order_payments
GROUP BY payment_type ORDER BY average_order_value DESC;

-- Delivery/ Operational Analysis
-- Q24. What is the average delivery time for order?
SELECT AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)) AS average_delivery_days
FROM orders WHERE order_delivered_customer_date IS NOT NULL;

-- Q25. Which customer states have the longest average delivery time?
SELECT c.customer_state, AVG(TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS average_delivery_days
FROM orders o JOIN CUSTOMERS C on o.customer_id = c.customer_id WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state 
ORDER BY average_delivery_days DESC;

-- Q26. What percentage of orders were delivered late?
SELECT ROUND(SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date 
THEN 1 ELSE 0 END) * 100.0 / COUNT(order_id),2) AS late_delivery_percentage FROM orders
WHERE order_delivered_customer_date IS NOT NULL; 


-- Advance Level
-- Q27. Rank customers based on their total spending using RANK(). 
SELECT o.customer_id , SUM(p.payment_value) AS total_spending,
RANK() OVER (ORDER BY SUM(p.payment_value) DESC) AS customer_rank FROM orders o JOIN order_payments p 
ON o.order_id = p.order_id GROUP BY o.customer_id 
ORDER BY customer_rank;

-- Q28. Identify high-value customers-customers whosw spending is above the 99th percentile?
SELECT customer_id , total_spending FROM (SELECT o.customer_id  , SUM(p.payment_value) AS total_spending , 
PERCENT_RANK() OVER ( ORDER BY SUM(p.payment_value)) AS spending_percentile
FROM orders o JOIN order_payments p ON o.order_id = p.order_id GROUP BY o.customer_id)
AS customer_spending WHERE spending_percentile >= 0.99 
ORDER BY total_spending DESC;