-- VIEWS START FROM HERE 

-- Category list

CREATE OR REPLACE VIEW category_view AS
SELECT id, name
FROM category;



-- store list

CREATE OR REPLACE VIEW store_for_feedback AS
SELECT r.store_id, p.name AS product_name, op.customer_order_id
FROM return r
JOIN order_product op ON r.order_product_id = op.id
JOIN product p ON op.product_id = p.id;


-- Store Rating

CREATE OR REPLACE VIEW store_average_rating_view AS
SELECT store_id,
       AVG(customer_rating) AS avg_rating
FROM feedback
GROUP BY store_id;


-- Price Charged

CREATE OR REPLACE VIEW product_discount_association AS
SELECT distinct p.id AS product_id,
       p.category_id,
       p.price,
       NVL(d.discount_rate, 0) AS discount_rate
FROM product p
 JOIN discount d ON p.category_id = d.category_id
 JOIN order_product op ON p.id = op.product_id
                       JOIN customer_order o ON op.customer_order_id = o.id where o.order_date BETWEEN d.start_date AND d.end_date;
                      
 -- view for per unit product
CREATE OR REPLACE VIEW order_product_actual_price_per_unit AS
SELECT op.id AS order_product_id,
       op.customer_order_id,
       op.product_id,
       op.quantity,
       CASE
           WHEN pda.discount_rate > 0 THEN (pda.price - (pda.price * pda.discount_rate / 100))
           ELSE pda.price
       END AS price_charged
FROM order_product op
JOIN customer_order o ON op.customer_order_id = o.id
JOIN product_discount_association pda ON op.product_id = pda.product_id;


-- total price for all units
CREATE OR REPLACE VIEW order_total_price_per_unit AS
SELECT customer_order_id,
       SUM(price_charged * quantity) AS total_price
FROM order_product_actual_price_per_unit
GROUP BY customer_order_id;

-- Refund Amount

CREATE OR REPLACE VIEW refund_amount_view AS
SELECT distinct op.customer_order_id,op.product_id,(op.price_charged * r1.quantity_returned) - NVL(r1.processing_fee, 0) as refund_amount
                                       FROM order_product_actual_price_per_unit op join return r1
                                       on op.order_product_id = r1.order_product_id where r1.seller_refund > 0 ;