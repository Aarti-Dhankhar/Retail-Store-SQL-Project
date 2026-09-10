-- CREATE DATABASE
CREATE DATABASE ecommerce_sql_project;
USE ecommerce_sql_project;

-- CREATE TABLES
-- 1. CUSTOMERS
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

-- 2. ORDERS
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

-- 3. ORDER ITEMS
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

-- 4. ORDER PAYMENTS
CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);

-- 5. ORDER REVIEWS
CREATE TABLE order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);

-- 6. PRODUCTS
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g DECIMAL(10,2),
    product_length_cm DECIMAL(10,2),
    product_height_cm DECIMAL(10,2),
    product_width_cm DECIMAL(10,2)
);

-- 7. SELLERS
CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

-- 8. GEOLOCATION
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat DECIMAL(10,7),
    geolocation_lng DECIMAL(10,7),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);

-- 9. PRODUCT CATEGORY TRANSLATION
CREATE TABLE product_category_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);
-- LOAD DATA

-- 1.CUSTOMERS
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_customers_dataset.csv'
INTO TABLE ecommerce_sql_project.customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state);
SELECT COUNT(*) AS total_customer_rows FROM customers;

-- 2.GEOLOCATION
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_geolocation_dataset.csv'
INTO TABLE ecommerce_sql_project.geolocation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
);
SELECT COUNT(*) AS total_geolocation_rows FROM geolocation;

-- 3.ORDER_ITEMS
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv'
INTO TABLE ecommerce_sql_project.order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
);
SELECT COUNT(*) AS order_items_rows FROM order_items;

-- 4.ORDERS
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv'
INTO TABLE ecommerce_sql_project.orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    customer_id,
    order_status,
    @purchase,
    @approved,
    @carrier,
    @delivered,
    @estimated
)
SET
    order_purchase_timestamp = NULLIF(@purchase, ''),
    order_approved_at = NULLIF(@approved, ''),
    order_delivered_carrier_date = NULLIF(@carrier, ''),
    order_delivered_customer_date = NULLIF(@delivered, ''),
    order_estimated_delivery_date = NULLIF(@estimated, '');
SELECT COUNT(*) AS total_order_rows FROM orders;

-- 5.ORDER_PAYMENTS
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_payments_dataset.csv'
INTO TABLE ecommerce_sql_project.order_payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
);
SELECT COUNT(*) AS total_payment_rows FROM order_payments;
ALTER TABLE products
CONVERT TO CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- 6.SELLERS
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_sellers_dataset.csv'
INTO TABLE ecommerce_sql_project.sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
);
SELECT COUNT(*) AS total_sellers_rows FROM sellers;

-- 7.PRODUCT_CATEGORY_NAME_TRANSLATION
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product_category_name_translation.csv'
INTO TABLE ecommerce_sql_project.product_category_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    product_category_name,
    product_category_name_english
);
SELECT COUNT(*) AS total_translation_rows FROM product_category_translation;

-- 8.PRODUCTS
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products_utf8.csv'
INTO TABLE ecommerce_sql_project.products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    product_id,
    product_category_name,
    @name_length,
    @description_length,
    @photos_qty,
    @weight,
    @length,
    @height,
    @width
)
SET
product_name_lenght =
    IF(TRIM(@name_length) REGEXP '^[0-9]+$', CAST(TRIM(@name_length) AS UNSIGNED), NULL),

product_description_lenght =
    IF(TRIM(@description_length) REGEXP '^[0-9]+$', CAST(TRIM(@description_length) AS UNSIGNED), NULL),

product_photos_qty =
    IF(TRIM(@photos_qty) REGEXP '^[0-9]+$', CAST(TRIM(@photos_qty) AS UNSIGNED), NULL),

product_weight_g =
    IF(TRIM(@weight) REGEXP '^[0-9]+([.][0-9]+)?$', CAST(TRIM(@weight) AS DECIMAL(10,2)), NULL),

product_length_cm =
    IF(TRIM(@length) REGEXP '^[0-9]+([.][0-9]+)?$', CAST(TRIM(@length) AS DECIMAL(10,2)), NULL),

product_height_cm =
    IF(TRIM(@height) REGEXP '^[0-9]+([.][0-9]+)?$', CAST(TRIM(@height) AS DECIMAL(10,2)), NULL),

product_width_cm =
    IF(TRIM(@width) REGEXP '^[0-9]+([.][0-9]+)?$', CAST(TRIM(@width) AS DECIMAL(10,2)), NULL);
SELECT COUNT(*) AS total_products_rows FROM products;

-- REVIEW DATA STAGING/ CLEANING
CREATE TABLE reviews_temp (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score VARCHAR(10),
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date VARCHAR(50),
    review_answer_timestamp VARCHAR(50)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_reviews_dataset.csv'
INTO TABLE reviews_temp
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
);
SELECT COUNT(*) AS total_review_rows FROM reviews_temp;

-- TRANSFER CLEANED DATA INTO FINAL TABLE
-- 9.ORDER_REVIEWS
INSERT INTO order_reviews
(
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
)
SELECT
    review_id,
    order_id,
    CAST(review_score AS UNSIGNED),
    NULLIF(review_comment_title, ''),
    NULLIF(review_comment_message, ''),
    STR_TO_DATE(review_creation_date, '%Y-%m-%d %H:%i:%s'),
    STR_TO_DATE(review_answer_timestamp, '%Y-%m-%d %H:%i:%s')
FROM reviews_temp;
SELECT COUNT(*) AS total_review_rows FROM order_reviews;

-- TEMPORARY TABLE NO LONGER REQUIRED
DROP TABLE reviews_temp;
SHOW TABLES;

-- FOREIGN KEY RELATIONSHIPS
-- 1. Orders → Customers
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

-- 2. Order Items → Orders
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

-- 3.Order Items → Products
ALTER TABLE order_items
MODIFY product_id VARCHAR(50)
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_product
FOREIGN KEY (product_id)
REFERENCES products(product_id);

-- 4. Order Items → Sellers
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_seller
FOREIGN KEY (seller_id)
REFERENCES sellers(seller_id);

-- 5. Order Payments → Orders
ALTER TABLE order_payments
ADD CONSTRAINT fk_order_payments_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

-- 6. Order Reviews → Orders
ALTER TABLE order_reviews
ADD CONSTRAINT fk_order_reviews_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);