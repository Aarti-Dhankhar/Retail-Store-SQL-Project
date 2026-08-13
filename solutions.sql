-- Level 1: Basics
-- Q1: Retrieve customer names and emails for email marketing
SELECT name , email from customers;
-- Q2: View complete product catalog with all available details
SELECT * FROM products;
-- Q3: List all unique product categories
SELECT DISTINCT category FROM products;
-- Q4: Show all products priced above 1000
SELECT name , price FROM products WHERE price > 1000;
-- Q5: Display products within a mid-range price bracket (2000 to 5000)
SELECT name , price FROM products WHERE price BETWEEN 2000 AND 5000;
-- Q6: Fetch data for specific customer IDs (e.g., from loyalty program list)
SELECT * FROM customers WHERE customer_id IN (1, 3 ,5 , 9 );
-- Q7: Identify customers whose names start with the letter 'A' (Wildcard match)
SELECT * FROM customers WHERE name LIKE "A%";
-- Q8: List electronics products priced under 3000
SELECT name , price FROM products WHERE category = "Electronics" AND price < 3000;
-- Q9: Display product names and prices in descending order of price
SELECT name , price FROM products ORDER BY price DESC;
-- Q10: Display product names and prices , sorted by price and then by name
SELECT name , price FROM products ORDER BY price DESC , name ASC;

-- Level 2 : Filtering and Formatting
-- Q1: Retrieve orders where customer information is missing (possibly due to data migration and deletion)
SELECT * FROM orders WHERE customer_id IS NULL;
-- Q2: Display customer names and emails using column aliases for fronted readability
SELECT name AS Customer_name, email AS email_ADD FROM customers ;
-- Q3: Calculate total value per item ordered by multiplying quantity and item price
SELECT  quantity , item_price , quantity * item_price AS total_value FROM order_items;
-- Q4: Combine customer name and phone number in a single column
SELECT CONCAT(name, "-", phone) as cust_details FROM customers;
-- Q5: Extact only the date part from order timestamps for date-wise reporting
SELECT  DATE(order_date) AS order_date FROM orders;
-- Q6: List products that do not have any stock left
SELECT name FROM products WHERE stock_quantity = 0;

-- Level 3 : Aggregations
-- Q1: Count the toal number of orders placed
SELECT count(*) AS total_orders FROM orders;
-- Q2: Calculate the toal revenue collected from all orders
SELECT sum(total_amount) AS total_revenue FROM orders;
-- Q3: Calculate the average order value
SELECT avg(total_amount) as avg_order_value FROM orders;
-- Q4: Count the number of customers who have placed at least one order
SELECT count(distinct customer_id) as customer_placed_order FROM orders;
-- Q5: Find the number of orders placed by each customer
SELECT customer_id , count(order_id) as total_orders FROM orders GROUP BY customer_id;
-- Q6: Find toal sales amount made by each customer
SELECT customer_id, sum(total_amount) as total_sales FROM orders GROUP BY customer_id;
-- Q7: List the number of products sold per category
SELECT p.category , SUM(oi.quantity) as sold_products FROM products p JOIN order_items oi 
ON p.product_id = oi.product_id GROUP BY p.category;
-- Q8: Find the average item price per category
SELECT p.category , avg(oi.item_price) as avg_price FROM products p join order_items oi
 on p.product_id = oi.product_id GROUP BY p.category;
 -- Q9: Show number of orders placed per day
 SELECT date(order_date) as order_date, count(order_id) as total_orders FROM orders GROUP BY DATE(order_date);
 -- Q10: List total payments received per payment method
 SELECT method , sum(amount_paid) as total_paid FROM payments GROUP BY method;
 
 -- Level 4 : Multi-Table Queries (JOINS)
 -- Q1: Retreive order details along with customer name (INNER JOIN)
SELECT c.name , o.order_id FROM customers c INNER JOIN orders o 
ON c.customer_id = o.customer_id;
-- Q2: Get list of products that have been sold (INNER JOIN with order_items)
SELECT p.name FROM products p INNER JOIN order_items oi 
ON p.product_id  = oi.product_id;
-- Q3: List all orders with their payment method (INNER JOIN)
SELECT o.order_id , p.method FROM orders o INNER JOIN payments p ON o.order_id = p.order_id;
-- Q4: Get list of customers and their orders (LEFT JOIN)
SELECT c.name , o.order_id FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id;
-- Q5: List all products along with order item quantity (LEFT JOIN)
SELECT p.name , oi.quantity FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id;
-- Q6: List all payments including those with no matching orders (RIGHT JOIN)
SELECT p.payment_id , o.order_id FROM orders o RIGHT JOIN payments p ON o.order_id = p.order_id;
-- Q7: Combine data from three tables: customer , order and payment
SELECT * FROM customers c JOIN orders o ON c.customer_id = o.customer_id JOIN payments p ON o.order_id = p.order_id;

-- Level 5 : Subqueries (INNER queries)
-- Q1: List all products priced above the average product price
SELECT name, price FROM products WHERE price > (SELECT avg(price) as avg_price FROM products);
-- Q2: Find customers who have placed at least one order 
SELECT name FROM customers WHERE customer_id in (SELECT customer_id FROM orders);
-- Q3: Show orders whose total amount is above the average for that customer
 SELECT o.order_id , o.customer_id , o.total_amount FROM orders o WHERE o.total_amount > (
 SELECT avg(o2.total_amount) FROM orders o2 WHERE o2.customer_id = o.customer_id);
 -- Q4: Display customers who haven't placed any orders
 SELECT name FROM customers WHERE customer_id NOT IN (SELECT customer_id FROM orders WHERE customer_id IS NOT NULL);
 -- Q5: Show products that were never ordered 
 SELECT name FROM products WHERE product_id NOT IN (SELECT product_id FROM order_items);
 -- Q6: Show highest value order per customer
 SELECT o.order_id , o.customer_id , o.total_amount FROM orders o WHERE o.total_amount = (
 SELECT MAX(o2.total_amount) FROM orders o2 WHERE o2.customer_id = o.customer_id);
 -- Q7: Highest order per customer (Including names)
 SELECT c.name, o.order_id , o.total_amount FROM customers c JOIN orders o on c.customer_id = o.customer_id
 WHERE o.total_amount = (SELECT max(o2.total_amount) FROM orders o2 WHERE o2.customer_id = o.customer_id);
 
 -- Level 6 : Set Operations
 -- Q1: List all customers who have eithe placed an order or written a product review 
 SELECT customer_id FROM orders UNION SELECT customer_id FROM product_reviews;
 -- Q2: List all customers who have placed an order as well as reviewed a product
 SELECT DISTINCT o.customer_id FROM orders o WHERE exists (SELECT 1 FROM product_reviews r WHERE r.customer_id =o.customer_id);

-- MIXED Practice
-- Find the top 5 customers based on their total spending (including names)
WITH customer_spending AS (SELECT c.name , o.customer_id , SUM(o.total_amount) AS total_spending FROM customers c JOIN orders o 
ON c.customer_id = o.customer_id GROUP BY o.customer_id , c.name ORDER BY total_spending DESC LIMIT 5) SELECT * FROM customer_spending;
-- Find the average order value for each customer (including names)
SELECT c.name , c.customer_id , AVG(o.total_amount) as avg_spending FROM customers c JOIN orders o ON c.customer_id = o.customer_id 
GROUP BY c.customer_id ORDER BY avg_spending DESC;
-- Find the category-wise total sales and sort categoies
--  from highest to lowest sales
SELECT p.category , SUM(oi.quantity * oi.item_price) AS total_sales FROM products p JOIN order_items oi
 On p.product_id = oi.product_id GROUP BY p.category ORDER BY total_sales DESC;
 -- Find the best selling product based on quantity sold
 SELECT p.name AS best_selling_product , SUM(oi.quantity) AS quantity_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id
 GROUP BY best_selling_product ORDER BY quantity_sold DESC LIMIT 1;
 -- Find products that have been never ordered
 SELECT p.name , p.product_id FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id WHERE oi.product_id is null;
 -- Find customers who have placed more orders than the average number of orders per customers
 SELECT c.name , c.customer_id ,COUNT(o.order_id) AS total_orders FROM customers c JOIN orders o
 ON c.customer_id = o.customer_id GROUP BY c.customer_id , c.name HAVING  COUNT(o.order_id)
 > (SELECT AVG(order_count) FROM (SELECT customer_id , COUNT(order_id) AS order_count FROM orders o GROUP BY customer_id) AS customer_orders );
 -- total average order count
SELECT COUNT(order_id) / COUNT( DISTINCT customer_id ) AS avg_order_count FROM orders;
-- Second-highest selling product based on total sales amount
 SELECT p.name , SUM(oi.quantity * oi.item_price) AS total_sales FROM products p 
JOIN order_items oi  ON p.product_id = oi.product_id GROUP BY p.product_id , p.name 
ORDER BY total_sales  DESC LIMIT 1 OFFSET 1;
-- First and most recent order date of each customer
SELECT c.name , c.customer_id , MIN(order_date) as first_order_date , MAX(o.order_date) AS most_recent_order_date
FROM customers c JOIN orders o ON c.customer_id = o.customer_id 
GROUP BY c.customer_id , c.name;
-- Month with the highest total sales
SELECT MONTH(order_date) AS month , SUM(total_amount) AS total_sales FROM orders
GROUP BY MONTH(order_date) ORDER BY total_sales DESC LIMIT 1;
-- Customers whose total spending is greater than average customer spending
SELECT c.customer_id , c.name , SUM(total_amount) AS total_spending FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_id , c.name 
HAVING total_spending > (SELECT AVG(total_spending) FROM (SELECT customer_id , SUM(total_amount) AS total_spending 
FROM orders GROUP BY customer_id) x );
-- TOP 3 products within each category based on total_sales
WITH product_sales AS ( SELECT p.category , p.name , SUM(oi.quantity * oi.item_price ) AS total_sales 
FROM products p JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.category , p.product_id , p.name) ,
ranked_products AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_sales DESC) as rn FROM product_sales)
SELECT category , name , total_sales FROM ranked_products WHERE rn <=3;
-- Running total of sales by order date
SELECT order_date , total_amount , SUM(total_amount) OVER (ORDER BY order_date )
AS running_total FROM orders;
-- Percentage contribution of each category to total sales
SELECT p.category , SUM(oi.quantity * oi.item_price) AS category_sales, ROUND(SUM(oi.quantity *  oi.item_price) * 100 /
(SELECT SUM(quantity * item_price) FROM order_items ), 2 ) AS sales_percentage FROM products p 
JOIN order_items oi ON p.product_id = oi.product_id GROUP BY p.category ORDER BY sales_percentage DESC;
-- Customers who purchased products from more than one category
SELECT o.customer_id , c.name , COUNT(DISTINCT p.category) AS category_count  FROM orders o 
JOIN order_items oi ON o.order_id = oi.order_id JOIN products p ON oi.product_id = p.product_id JOIN customers c 
ON o.customer_id = c.customer_id GROUP BY o.customer_id , c.name HAVING COUNT(DISTINCT p.category) > 1;
