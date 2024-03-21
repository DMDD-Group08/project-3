-- No of returnable days

CREATE OR REPLACE VIEW NUMBER_OF_RETURNABLE_DAYS AS
SELECT op.order_id AS ORDER_ID,
       p.name AS PRODUCT_NAME,
       TO_DATE(op.order_date + c.return_by_days) AS RETURN_BY_DATE,
       (op.order_date + c.return_by_days - SYSDATE) AS DAYS_REMAINING_TO_RETURN
FROM "Order" o
JOIN order_product op ON o.id = op.order_id
JOIN product p ON op.product_id = p.id
JOIN category c ON p.category_id = c.id;


-- Frequency of returned products 

CREATE OR REPLACE VIEW RETURNED_PRODUCTS_DETAILS AS
SELECT p.name AS PRODUCT_NAME,
       op.product_id AS PRODUCT_ID,
       COUNT(r.id) AS PRODUCT_QUANTITY,
       r.reason AS REASON
FROM "return" r
JOIN order_product op ON r.order_product_id = op.id
JOIN product p ON op.product_id = p.id
GROUP BY op.product_id,p.name;


-- Customer Reliability Index 

CREATE OR REPLACE VIEW Customer_Reliability_Index AS
SELECT c.name AS Customer_Name,
       c.id AS Customer_ID,
       (c.reliability_index - COALESCE((
           SELECT COUNT(*)
           FROM "return" r2
           JOIN order_product op2 ON r2.order_product_id = op2.id
           JOIN "Order" o2 ON op2.order_id = o2.id
           WHERE o2.customer_id = c.id
       ), 0)) AS Reliability_Index
FROM customer c;


-- Total Sum of the order : 

CREATE OR REPLACE VIEW Total_Sum_Of_The_Order AS
SELECT 
    o.customer_id AS Customer_ID,
    c.name AS Customer_Name,
    o.status AS Status,
    o.order_date AS Order_Date,
    (
        SELECT SUM(op.price_charged * op.quantity) 
        FROM order_product op 
        WHERE op.order_id = o.id
    ) AS Total_Sum
FROM 
    "Order" o
JOIN 
    customer c ON o.customer_id = c.id;


-- Delivery Date of the order : 

CREATE OR REPLACE VIEW Order_Delivery_Date AS
SELECT 
    o.id AS Order_ID,
    op.product_id AS Product_ID,
    p.name AS Product_Name,
    CASE 
        WHEN c.name = 'diary' THEN o.order_date + INTERVAL '2' DAY
        WHEN c.name = 'electronics' THEN o.order_date + INTERVAL '5' DAY
        ELSE NULL
    END AS Delivery_Date
FROM 
    "Order" o
JOIN 
    order_product op ON o.id = op.order_id
JOIN 
    product p ON op.product_id = p.id
JOIN 
    category c ON p.category_id = c.id;
