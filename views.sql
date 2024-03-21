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

CREATE VIEW product_discount_association AS
SELECT p.id AS product_id,
       p.category_id,
       p.price,
       NVL(d.discount_rate, 0) AS discount_rate
FROM product p
LEFT JOIN discount d ON p.category_id = d.category_id
LEFT JOIN customer_order o ON p.id = o.id
                      AND o.order_date BETWEEN d.start_date AND d.end_date;

 
CREATE OR REPLACE VIEW order_product_actual_price_per_unit AS
SELECT op.id AS order_product_id,
       op.customer_order_id,
       op.product_id,
       op.quantity,
       CASE
           WHEN pda.discount_rate > 0 THEN (pda.price - (pda.price * pda.discount_rate / 100)) / op.quantity
           ELSE pda.price
       END AS price_per_unit
FROM order_product op
JOIN customer_order o ON op.customer_order_id = o.id
JOIN product_discount_association pda ON op.product_id = pda.product_id;

CREATE VIEW order_total_price_per_unit AS
SELECT customer_order_id,
       SUM(price_per_unit * quantity) AS total_price
FROM order_product_actual_price_per_unit
GROUP BY customer_order_id;


-- Refund Amount

CREATE OR REPLACE VIEW refund_amount_view AS
SELECT CASE 
           WHEN seller_refund = 1 THEN (SELECT op.price_per_unit * r.quantity_returned - NVL(r.processing_fee, 0)
                                       FROM order_product_actual_price_per_unit op
                                       WHERE op.order_product_id = r.order_product_id)
           ELSE 0
       END AS refund_amount
FROM return r;
