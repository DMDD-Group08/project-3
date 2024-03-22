
-- Frequency of returned products 
-- This view displays how many times the product has been returned by all the customers

CREATE OR REPLACE VIEW RETURNED_PRODUCTS_DETAILS AS
SELECT 
    MAX(p.name) AS PRODUCT_NAME,
    op.product_id AS PRODUCT_ID,
    COUNT(r.id) AS RETURN_FREQUENCY,
    MAX(r.reason) AS REASON
FROM 
    "RETURN" r
JOIN 
    "ORDER_PRODUCT" op ON r.order_product_id = op.id
JOIN 
    "PRODUCT" p ON op.product_id = p.id
GROUP BY 
    op.product_id;
    


-- Customer Reliability Index 
-- 1. We first calculate the total number of orders for each customer and the total number of returned orders for each customer using subqueries.
-- 2. We then left join these subqueries with the customer table to get the Customer_Name, Customer_ID, total_orders, and returned_orders.
-- 3. We calculate the reliability index as a percentage by subtracting the percentage of returned orders from 100. If total_orders is zero (to handle division by zero), we assume 100% reliability.
-- 4. This query provides the customer's name, ID, and reliability index as a percentage.

CREATE OR REPLACE VIEW Customer_Reliability_Index AS
SELECT 
    c.name AS Customer_Name,
    c.id AS Customer_ID,
 ROUND(
        CASE 
            WHEN total_orders = 0 THEN 100  -- Handle division by zero
            ELSE (1 - (returned_orders / total_orders)) * 100  -- Calculate reliability index as a percentage
        END,
        2  -- Round to two decimal places
    ) AS Reliability_Index
FROM 
    customer c
LEFT JOIN 
    (
        SELECT 
            o.customer_id,
            COUNT(*) AS total_orders
        FROM 
            "CUSTOMER_ORDER" o
        JOIN 
            "ORDER_PRODUCT" op ON o.id = op.order_id
        GROUP BY 
            o.customer_id
    ) total ON c.id = total.customer_id
LEFT JOIN 
    (
        SELECT 
            o.customer_id,
            COUNT(*) AS returned_orders
        FROM 
            "RETURN" r
        JOIN 
            "ORDER_PRODUCT" op ON r.order_product_id = op.id
        JOIN 
            "CUSTOMER_ORDER" o ON op.order_id = o.id
        GROUP BY 
            o.customer_id
    ) returned ON c.id = returned.customer_id;



-- No of returnable days
-- It shows the customer how many days are remaining to return the product
-- If the product crosses the returnable date, then it shows as 0

CREATE OR REPLACE VIEW NUMBER_OF_RETURNABLE_DAYS AS
SELECT 
    op.order_id AS ORDER_ID,
    p.name AS PRODUCT_NAME,
    TO_DATE(o.delivery_date + c.return_by_days) AS RETURN_BY_DATE,
    CASE 
        WHEN (o.delivery_date + c.return_by_days - SYSDATE) < 0 THEN 0
        ELSE (o.delivery_date + c.return_by_days - SYSDATE)
    END AS DAYS_REMAINING_TO_RETURN
FROM 
    Order_Delivery_Date o
JOIN 
    "ORDER_PRODUCT" op ON o.Order_ID = op.order_id
JOIN 
    "PRODUCT" p ON op.product_id = p.id
JOIN 
    "CATEGORY" c ON p.category_id = c.id;
    


-- Delivery Date of the order : 

CREATE OR REPLACE VIEW Order_Delivery_Date AS
SELECT 
    o.id AS Order_ID,
    o.customer_id AS Customer_ID,  -- Include the customer ID
    op.product_id AS Product_ID,
    p.name AS Product_Name,
    CASE 
        WHEN c.name = 'Food/Beverages' THEN o.order_date + INTERVAL '2' DAY
        WHEN c.name = 'Electronics' THEN o.order_date + INTERVAL '5' DAY
        WHEN c.name = 'Clothing/Apparel' THEN o.order_date + INTERVAL '7' DAY
        ELSE NULL
    END AS Delivery_Date
FROM 
    CUSTOMER_ORDER o
JOIN 
    order_product op ON o.id = op.order_id
JOIN 
    product p ON op.product_id = p.id
JOIN 
    category c ON p.category_id = c.id
JOIN 
    customer cu ON o.customer_id = cu.id; 

