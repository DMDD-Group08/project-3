Set serveroutput ON;
DECLARE
    cnt NUMBER;
BEGIN
    -- CATEGORY
    SELECT COUNT(*) INTO cnt FROM user_tables WHERE table_name = 'CATEGORY';
    IF cnt = 0 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE category (
            id VARCHAR2(10) CONSTRAINT category_pk PRIMARY KEY,
            name VARCHAR2(20) Unique NOT NULL,
            return_by_days NUMBER(2) NOT NULL CHECK (return_by_days >= 0 AND return_by_days < 100)
        )';
    ELSE
        DBMS_OUTPUT.PUT_LINE('Table category already exists.');
    END IF;

    -- CUSTOMER
    SELECT COUNT(*) INTO cnt FROM user_tables WHERE table_name = 'CUSTOMER';
    IF cnt = 0 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE customer (
            id VARCHAR2(10) CONSTRAINT customer_pk PRIMARY KEY,
            name VARCHAR2(50) NOT NULL,
            contact_no NUMBER(10) Unique NOT NULL,
            date_of_birth DATE NOT NULL,
            email_id VARCHAR2(30) Unique NOT NULL,
            joined_date DATE NOT NULL,
            address_line VARCHAR2(100) NOT NULL,
            city VARCHAR2(30) NOT NULL,
            state VARCHAR2(30) NOT NULL,
            zip_code VARCHAR2(5) NOT NULL
        )';
    ELSE
        DBMS_OUTPUT.PUT_LINE('Table customer already exists.');
    END IF;

    -- SELLER
    SELECT COUNT(*) INTO cnt FROM user_tables WHERE table_name = 'SELLER';
    IF cnt = 0 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE seller (
            id VARCHAR2(10) CONSTRAINT seller_pk PRIMARY KEY,
            name       VARCHAR(20) NOT NULL,
            contact_no NUMBER(10) Unique NOT NULL
        )';
    ELSE
        DBMS_OUTPUT.PUT_LINE('Table seller already exists.');
    END IF;

    -- PRODUCT
    SELECT COUNT(*) INTO cnt FROM user_tables WHERE table_name = 'PRODUCT';
    IF cnt = 0 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE product (
            id VARCHAR2(10) CONSTRAINT product_pk PRIMARY KEY,
            name VARCHAR2(20) NOT NULL,
            price NUMBER(10,2) NOT NULL,
            mfg_date DATE NOT NULL,
            exp_date DATE,
            category_id VARCHAR2(10) NOT NULL,
            seller_id VARCHAR2(10) NOT NULL,
            CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES category(id),
            CONSTRAINT fk_product_seller FOREIGN KEY (seller_id) REFERENCES seller(id)
        )';
        EXECUTE IMMEDIATE 'ALTER TABLE product
        ADD CONSTRAINT 
        end_date_later_than_start_date_CK CHECK (mfg_date <= exp_date)'; 
    ELSE
        DBMS_OUTPUT.PUT_LINE('Table product already exists.');
    END IF;

    -- ORDER (CUSTOMER_ORDER to avoid SQL keyword conflict)
    SELECT COUNT(*) INTO cnt FROM user_tables WHERE table_name = 'CUSTOMER_ORDER';
    IF cnt = 0 THEN
       EXECUTE IMMEDIATE 'CREATE TABLE customer_order (
        id VARCHAR2(10) CONSTRAINT order_pk PRIMARY KEY,
        customer_id VARCHAR2(10) NOT NULL,
        order_date DATE NOT NULL,
        status VARCHAR(20) NOT NULL CHECK (status IN (''DELIVERED'', ''IN_TRANSIT'', ''SHIPPED'', ''ORDER_PLACED'')),
        CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES customer(id)
    )';
    ELSE
        DBMS_OUTPUT.PUT_LINE('Table customer_order already exists.');
    END IF;

    -- ORDER_PRODUCT
    SELECT COUNT(*) INTO cnt FROM user_tables WHERE table_name = 'ORDER_PRODUCT';
    IF cnt = 0 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE order_product (
            id VARCHAR2(10) CONSTRAINT order_product_pk PRIMARY KEY,
            order_id VARCHAR2(10) NOT NULL,
            product_id VARCHAR2(10) NOT NULL,
            quantity NUMBER(3) NOT NULL,
            CONSTRAINT fk_order_product_order FOREIGN KEY (order_id) REFERENCES customer_order(id),
            CONSTRAINT fk_order_product_product FOREIGN KEY (product_id) REFERENCES product(id)
        )';
    ELSE
        DBMS_OUTPUT.PUT_LINE('Table order_product already exists.');
    END IF;

    -- DISCOUNT
    SELECT COUNT(*) INTO cnt FROM user_tables WHERE table_name = 'DISCOUNT';
    IF cnt = 0 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE discount (
            id VARCHAR2(10) CONSTRAINT discount_pk PRIMARY KEY,
            category_id VARCHAR2(10) NOT NULL,
            discount_rate NUMBER(3,1) NOT NULL CHECK (discount_rate >= 0 AND discount_rate < 100),
            start_date DATE NOT NULL,
            end_date DATE NOT NULL,
            CONSTRAINT fk_discount_category FOREIGN KEY (category_id) REFERENCES category(id)
        )';
         EXECUTE IMMEDIATE 'ALTER TABLE DISCOUNT
         ADD CONSTRAINT 
        disend_date_later_than_start_date_CK CHECK (start_date <= end_date)';
    ELSE
        DBMS_OUTPUT.PUT_LINE('Table discount already exists.');
    END IF;
    
    -- STORE
    SELECT COUNT(*) INTO cnt FROM user_tables WHERE table_name = 'STORE';
    IF cnt = 0 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE store (
            id VARCHAR2(10) CONSTRAINT store_pk PRIMARY KEY,
            name              VARCHAR(20) NOT NULL,
            contact_no        NUMBER(10) Unique NOT NULL,
            address_line      VARCHAR(30) NOT NULL,
            city              VARCHAR(30) NOT NULL,
            state             VARCHAR(30) NOT NULL,
            zip_code          VARCHAR(5) NOT NULL,
            accepting_returns NUMBER(1) NOT NULL
        )';
    ELSE
        DBMS_OUTPUT.PUT_LINE('Table store already exists.');
    END IF;

    -- FEEDBACK
    SELECT COUNT(*) INTO cnt FROM user_tables WHERE table_name = 'FEEDBACK';
    IF cnt = 0 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE feedback (
            id VARCHAR2(10) CONSTRAINT feedback_pk PRIMARY KEY,
            customer_id VARCHAR2(10) NOT NULL,
            store_id VARCHAR2(10) NOT NULL,
            customer_rating NUMBER(2,1) NOT NULL CHECK (customer_rating >= 0 AND customer_rating < 100),
            Review VARCHAR2(500) NOT NULL,
            CONSTRAINT fk_feedback_customer FOREIGN KEY (customer_id) REFERENCES customer(id),
            CONSTRAINT fk_feedback_order FOREIGN KEY (store_id) REFERENCES store(id)
        )';
    ELSE
        DBMS_OUTPUT.PUT_LINE('Table feedback already exists.');
    END IF;

    -- RETURN
    SELECT COUNT(*) INTO cnt FROM user_tables WHERE table_name = 'RETURN';
    IF cnt = 0 THEN
      EXECUTE IMMEDIATE 'CREATE TABLE return (
        id VARCHAR2(10) CONSTRAINT return_pk PRIMARY KEY,
        reason VARCHAR(500) NOT NULL,
        return_date DATE NOT NULL,
        refund_status VARCHAR(20) CHECK (refund_status IN (''IN_PROGRESS'', ''SUCCESSFUL'')),
        quantity_returned NUMBER(3) NOT NULL,
        processing_fee NUMBER(5, 2), -- not all returns will be successful so I put not, null,
        request_accepted NUMBER(1) CHECK (request_accepted IN (0, 1)),
        seller_refund NUMBER(1) CHECK (seller_refund IN (0, 1)),
        store_id VARCHAR(10) NOT NULL,
        order_product_id VARCHAR(10) NOT NULL,
        CONSTRAINT fk_return_order_product FOREIGN KEY (order_product_id) REFERENCES order_product(id),
        CONSTRAINT return_store_fk FOREIGN KEY (store_id) REFERENCES store(id)
    )';

    ELSE
        DBMS_OUTPUT.PUT_LINE('Table return already exists.');
    END IF;


END;
/

--------------------------------------------------------------------------


BEGIN
    BEGIN
        INSERT INTO customer (id, name, contact_no, date_of_birth, email_id, joined_date, address_line, city, state, zip_code)
        VALUES ('C001', 'Alice Michel', '9100000001', TO_DATE('1992-06-01', 'YYYY-MM-DD'), 'alice@gmail.com', TO_DATE('2022-01-10', 'YYYY-MM-DD'), '123 Harvard Ave', 'Boston', 'MA', '12345');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate entry for Alice Michel.');
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                DBMS_OUTPUT.PUT_LINE('Duplicate phone number or email for Alice Michel.');
            ELSE
                RAISE;
            END IF;
    END;

    BEGIN
        INSERT INTO customer (id, name, contact_no, date_of_birth, email_id, joined_date, address_line, city, state, zip_code)
        VALUES ('C002', 'Bob Santos', '9200000002', TO_DATE('1988-08-15', 'YYYY-MM-DD'), 'bob@gmail.com', TO_DATE('2022-02-20', 'YYYY-MM-DD'), '456 Brokkline Rd', 'New York', 'NY', '23456');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate entry for Bob Santos.');
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                DBMS_OUTPUT.PUT_LINE('Duplicate phone number or email for Bob Santos.');
            ELSE
                RAISE;
            END IF;
    END;

    BEGIN
        INSERT INTO customer (id, name, contact_no, date_of_birth, email_id, joined_date, address_line, city, state, zip_code)
        VALUES ('C003', 'Charlie Heisenberg', '9300000003', TO_DATE('1990-12-25', 'YYYY-MM-DD'), 'charlie@gmail.com', TO_DATE('2022-03-15', 'YYYY-MM-DD'), '789 Cocoa St', 'Chicago', 'IL', '34567');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate entry for Charlie Heisenberg.');
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                DBMS_OUTPUT.PUT_LINE('Duplicate phone number or email for Charlie Heisenberg.');
            ELSE
                RAISE;
            END IF;
    END;
END;
/

-------------------------------------------------------------------
BEGIN
    BEGIN
        INSERT INTO category (id, name, return_by_days)
        VALUES ('SM001', 'Food/Beverages', 7);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate entry for Food/Beverages.');
    END;

    BEGIN
        INSERT INTO category (id, name, return_by_days)
        VALUES ('SM002', 'Electronics', 30);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate entry for Electronics.');
    END;

    BEGIN
        INSERT INTO category (id, name, return_by_days)
        VALUES ('SM003', 'Clothing/Apparel', 15);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate entry for Clothing/Apparel.');
    END;

    BEGIN
        INSERT INTO category (id, name, return_by_days)
        VALUES ('SM004', 'Healthcare', 10);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate entry for Healthcare.');
    END;

    
END;
/


--------------------------------------------------------------------------------------------------------

BEGIN
    BEGIN
        INSERT INTO discount (id, category_id, discount_rate, start_date, end_date)
        VALUES ('DSC001', 'SM001', 10.00, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-31', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate discount DSC001 not inserted.');
    END;

    BEGIN
        INSERT INTO discount (id, category_id, discount_rate, start_date, end_date)
        VALUES ('DSC002', 'SM001', 15.00, TO_DATE('2024-03-01', 'YYYY-MM-DD'), TO_DATE('2024-03-15', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate discount DSC002 not inserted.');
    END;

    BEGIN
        INSERT INTO discount (id, category_id, discount_rate, start_date, end_date)
        VALUES ('DSC003', 'SM001', 20.00, TO_DATE('2024-06-01', 'YYYY-MM-DD'), TO_DATE('2024-06-30', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate discount DSC003 not inserted.');
    END;

    BEGIN
        INSERT INTO discount (id, category_id, discount_rate, start_date, end_date)
        VALUES ('DSC004', 'SM002', 5.00, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-28', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate discount DSC004 not inserted.');
    END;

    BEGIN
        INSERT INTO discount (id, category_id, discount_rate, start_date, end_date)
        VALUES ('DSC005', 'SM002', 10.00, TO_DATE('2024-05-01', 'YYYY-MM-DD'), TO_DATE('2024-05-15', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate discount DSC005 not inserted.');
    END;

    BEGIN
        INSERT INTO discount (id, category_id, discount_rate, start_date, end_date)
        VALUES ('DSC006', 'SM002', 15.00, TO_DATE('2024-11-01', 'YYYY-MM-DD'), TO_DATE('2024-11-30', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate discount DSC006 not inserted.');
    END;

    BEGIN
        INSERT INTO discount (id, category_id, discount_rate, start_date, end_date)
        VALUES ('DSC007', 'SM003', 10.00, TO_DATE('2024-04-01', 'YYYY-MM-DD'), TO_DATE('2024-04-30', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate discount DSC007 not inserted.');
    END;

    BEGIN
        INSERT INTO discount (id, category_id, discount_rate, start_date, end_date)
        VALUES ('DSC008', 'SM003', 20.00, TO_DATE('2024-07-01', 'YYYY-MM-DD'), TO_DATE('2024-07-31', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate discount DSC008 not inserted.');
    END;

    BEGIN
        INSERT INTO discount (id, category_id, discount_rate, start_date, end_date)
        VALUES ('DSC009', 'SM003', 25.00, TO_DATE('2024-10-01', 'YYYY-MM-DD'), TO_DATE('2024-10-31', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate discount DSC009 not inserted.');
    END;
END;
/


-----------------------------------------------------------------------------------------------------------------------------------------


BEGIN
    -- Inserting sellers with handling for potential duplicates
    BEGIN
        INSERT INTO seller (id, name, contact_no)
        VALUES ('APL', 'Apple Inc.', 8006927753);
    EXCEPTION 
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate seller Apple Inc. not inserted.');
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                DBMS_OUTPUT.PUT_LINE('Duplicate phone number for Apple Inc. not inserted.');
            ELSE
                RAISE;
            END IF;
    END;
    
    BEGIN
        INSERT INTO seller (id, name, contact_no)
        VALUES ('NIK', 'Nike', 8008066453);
    EXCEPTION 
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate seller Nike Inc. not inserted.');
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                DBMS_OUTPUT.PUT_LINE('Duplicate phone number for Nike. not inserted.');
            ELSE
                RAISE;
            END IF;
    END;
    
    BEGIN
        INSERT INTO seller (id, name, contact_no)
        VALUES ('VIC', 'Vicks', 8003621683);
    EXCEPTION 
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate seller Nike. not inserted.');
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                DBMS_OUTPUT.PUT_LINE('Duplicate phone number for Nike. not inserted.');
            ELSE
                RAISE;
            END IF;
    END;
    
    BEGIN
        INSERT INTO seller (id, name, contact_no)
        VALUES ('WHO', 'Whole Foods', 8005551212);
    EXCEPTION 
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate seller Whole Foods. not inserted.');
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                DBMS_OUTPUT.PUT_LINE('Duplicate phone number for Whole Foods. not inserted.');
            ELSE
                RAISE;
            END IF;
    END;

END;
/


-------------------------------------------------------------------------------------------------------


BEGIN
    -- Inserting Milk with mfg_date and exp_date
    BEGIN
        INSERT INTO product (id, name, price, category_id, seller_id, mfg_date, exp_date)
        VALUES ('PROD001', 'Milk', 2.99, 'SM001', 'WHO', TO_DATE('2023-03-10', 'YYYY-MM-DD'), TO_DATE('2023-03-29', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate product Milk not inserted.');
    END;
    
    -- Inserting Bread with mfg_date and exp_date
    BEGIN
        INSERT INTO product (id, name, price, category_id, seller_id, mfg_date, exp_date)
        VALUES ('PROD002', 'Bread', 3.49, 'SM001', 'WHO', TO_DATE('2023-03-10', 'YYYY-MM-DD'), TO_DATE('2023-03-25', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate product Bread not inserted.');
    END;
    
    -- Inserting Cake with mfg_date and exp_date
    BEGIN
            INSERT INTO product (id, name, price, category_id, seller_id, mfg_date, exp_date)
            VALUES ('PROD003', 'Cake', 15.00, 'SM001', 'WHO', TO_DATE('2023-03-11', 'YYYY-MM-DD'), TO_DATE('2023-03-25', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate product Cake not inserted.');
    END;
END;
/


BEGIN
    -- Electronics Products
    BEGIN
        INSERT INTO product (id, name, price, category_id, seller_id, mfg_date)
        VALUES ('PROD004', 'iPhone', 999.00, 'SM002', 'APL', TO_DATE('2024-02-15', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate product iPhone not inserted.');
    END;
    
    BEGIN
        INSERT INTO product (id, name, price, category_id, seller_id, mfg_date)
        VALUES ('PROD005', 'Laptop', 1300.00, 'SM002', 'APL', TO_DATE('2024-01-10', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate product Laptop not inserted.');
    END;
    
    BEGIN
        INSERT INTO product (id, name, price, category_id, seller_id, mfg_date)
        VALUES ('PROD006', 'Watches', 250.00, 'SM002', 'APL', TO_DATE('2024-02-05', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate product Watches not inserted.');
    END;
    
    -- Clothing/Apparel Products
    BEGIN
        INSERT INTO product (id, name, price, category_id, seller_id, mfg_date)
        VALUES ('PROD007', 'Shoes', 120.00, 'SM003', 'NIK', TO_DATE('2024-03-01', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate product Shoes not inserted.');
    END;
    
    BEGIN
        INSERT INTO product (id, name, price, category_id, seller_id, mfg_date)
        VALUES ('PROD008', 'Jacket', 250.00, 'SM003', 'NIK', TO_DATE('2024-02-20', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate product Jacket not inserted.');
    END;
    
    BEGIN
        INSERT INTO product (id, name, price, category_id, seller_id, mfg_date)
        VALUES ('PROD009', 'Trousers', 85.00, 'SM003', 'NIK', TO_DATE('2024-01-25', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate product Trousers not inserted.');
    END;
END;
/

SELECT* FROM PRODUCT;

-------------------------------------------------------------------------------------------------------------------------







BEGIN
    -- Assigning "Delivered" status to 7 orders
    BEGIN
        INSERT INTO customer_order (id, customer_id, order_date, status)
        VALUES ('ORD001', 'C001', TO_DATE('2023-03-11', 'YYYY-MM-DD'), 'DELIVERED');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate order ORD001 not inserted.');
    END;

    BEGIN
        INSERT INTO customer_order (id, customer_id, order_date, status)
        VALUES ('ORD002', 'C002', TO_DATE('2023-03-12', 'YYYY-MM-DD'), 'DELIVERED');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate order ORD002 not inserted.');
    END;

    BEGIN
        INSERT INTO customer_order (id, customer_id, order_date, status)
        VALUES ('ORD003', 'C003', TO_DATE('2023-03-13', 'YYYY-MM-DD'), 'DELIVERED');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate order ORD003 not inserted.');
    END;

    BEGIN
        INSERT INTO customer_order (id, customer_id, order_date, status)
        VALUES ('ORD004', 'C001', TO_DATE('2023-03-14', 'YYYY-MM-DD'), 'DELIVERED');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate order ORD004 not inserted.');
    END;

    BEGIN
        INSERT INTO customer_order (id, customer_id, order_date, status)
        VALUES ('ORD005', 'C002', TO_DATE('2023-03-18', 'YYYY-MM-DD'), 'DELIVERED');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate order ORD005 not inserted.');
    END;

    BEGIN
        INSERT INTO customer_order (id, customer_id, order_date, status)
        VALUES ('ORD006', 'C003', TO_DATE('2023-03-11', 'YYYY-MM-DD'), 'DELIVERED');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate order ORD006 not inserted.');
    END;

    BEGIN
        INSERT INTO customer_order (id, customer_id, order_date, status)
        VALUES ('ORD007', 'C001', TO_DATE('2023-03-17', 'YYYY-MM-DD'), 'DELIVERED');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate order ORD007 not inserted.');
    END;

    -- Assigning "Shipped" status to 3 orders
    BEGIN
        INSERT INTO customer_order (id, customer_id, order_date, status)
        VALUES ('ORD008', 'C002', TO_DATE('2023-03-16', 'YYYY-MM-DD'), 'SHIPPED');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate order ORD008 not inserted.');
    END;

    BEGIN
        INSERT INTO customer_order (id, customer_id, order_date, status)
        VALUES ('ORD009', 'C003', TO_DATE('2023-03-15', 'YYYY-MM-DD'), 'SHIPPED');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate order ORD009 not inserted.');
    END;

    BEGIN
        INSERT INTO customer_order (id, customer_id, order_date, status)
        VALUES ('ORD010', 'C001', TO_DATE('2023-03-16', 'YYYY-MM-DD'), 'SHIPPED');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate order ORD010 not inserted.');
    END;
END;
/

---------------------------------------------------------------------------------











BEGIN
    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0001', 'ORD001', 'PROD001', 3);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0001 not inserted.');
    END;
    
    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0002', 'ORD001', 'PROD002', 1);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0002 not inserted.');
    END;
    
    -- Order 2 Product Associations
    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0003', 'ORD002', 'PROD003', 2);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0003 not inserted.');
    END;
    
    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0004', 'ORD002', 'PROD004', 2);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0004 not inserted.');
    END;
    
    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0005', 'ORD003', 'PROD005', 1);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0005 not inserted.');
    END;
    
    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0006', 'ORD003', 'PROD006', 3);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0006 not inserted.');
    END;

    -- Order 4 Product Associations
    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0007', 'ORD004', 'PROD007', 2);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0007 not inserted.');
    END;
    
    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0008', 'ORD004', 'PROD008', 1);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0008 not inserted.');
    END;

    -- Order 5 Product Associations
    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0009', 'ORD005', 'PROD009', 2);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0009 not inserted.');
    END;
    
    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0010', 'ORD005', 'PROD001', 3);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0010 not inserted.');
    END;
    
    -- Order 6 Product Associations
    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0011', 'ORD006', 'PROD005', 2);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0011 not inserted.');
    END;

    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0012', 'ORD006', 'PROD006', 3);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0012 not inserted.');
    END;

    -- Order 7 Product Associations
    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0013', 'ORD007', 'PROD001', 1);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0013 not inserted.');
    END;

    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0014', 'ORD007', 'PROD002', 2);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0014 not inserted.');
    END;

    -- Order 8 Product Associations
    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0015', 'ORD008', 'PROD003', 3);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0015 not inserted.');
    END;

    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0016', 'ORD008', 'PROD004', 1);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0016 not inserted.');
    END;

    -- Order 9 Product Associations
    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0017', 'ORD009', 'PROD005', 2);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0017 not inserted.');
    END;

    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0018', 'ORD009', 'PROD006', 3);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0018 not inserted.');
    END;

    -- Order 10 Product Associations
    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0019', 'ORD010', 'PROD001', 1);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0019 not inserted.');
    END;

    BEGIN
        INSERT INTO order_product (id, order_id, product_id, quantity)
        VALUES ('OP0020', 'ORD010', 'PROD002', 2);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0020 not inserted.');
    END;
    
END;
/





--------------------------------------------------------------------------------------------------------------------

BEGIN
    -- Inserting UPS in Boston
    BEGIN
        INSERT INTO store (id, name, contact_no, address_line, city, state, zip_code, accepting_returns)
        VALUES ('ST001', 'UPS', 8007425877, '1 UPS Way', 'Boston', 'MA', '02101', 1);
    EXCEPTION 
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate store UPS not inserted.');
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                DBMS_OUTPUT.PUT_LINE('Duplicate contact number for store UPS not inserted.');
            ELSE
                RAISE;
            END IF;
    END;

    -- Inserting FedEx in New York
    BEGIN
        INSERT INTO store (id, name, contact_no, address_line, city, state, zip_code, accepting_returns)
        VALUES ('ST002', 'FedEx', 8004633339, '2 FedEx Plaza', 'New York', 'NY', '10001', 1);
    EXCEPTION 
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate store FedEx not inserted.');
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                DBMS_OUTPUT.PUT_LINE('Duplicate contact number for store FedEx not inserted.');
            ELSE
                RAISE;
            END IF;
    END;

    -- Inserting Five Guys in Chicago
    BEGIN
        INSERT INTO store (id, name, contact_no, address_line, city, state, zip_code, accepting_returns)
        VALUES ('ST003', 'Five Guys', 8005551234, '3 Burger Blvd', 'Chicago', 'IL', '60606', 1);
    EXCEPTION 
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate store Five Guys not inserted.');
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                DBMS_OUTPUT.PUT_LINE('Duplicate contact number for store Five Guys not inserted.');
            ELSE
                RAISE;
            END IF;
    END;
END;
/

BEGIN
    -- Inserting UPS in Boston
    BEGIN
        INSERT INTO store (id, name, contact_no, address_line, city, state, zip_code, accepting_returns)
        VALUES ('ST005', 'UPS1', 8007425877, '1 UPS Way', 'Boston', 'MA', '02101', 1);
    EXCEPTION 
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate store UPS not inserted.');
        WHEN OTHERS THEN
            IF SQLCODE = -1 THEN
                DBMS_OUTPUT.PUT_LINE('Duplicate contact number for store UPS not inserted.');
            ELSE
                RAISE;
            END IF;
    END;

    
END;
/


---------------------------------------------------------------------------------------------------------------------




BEGIN
    BEGIN
        INSERT INTO return (id, reason, return_date, refund_status, quantity_returned, processing_fee, request_accepted, seller_refund, store_id, order_product_id)
        VALUES ('RET001', 'Alegeric to the product', TO_DATE('2023-03-22', 'YYYY-MM-DD'), 'SUCCESSFUL', 2, 5.00, 1, 1, 'ST001', 'OP0010');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate return RET001 not inserted.');
    END;
    
    BEGIN
        INSERT INTO return (id, reason, return_date, refund_status, quantity_returned, processing_fee, request_accepted, seller_refund, store_id, order_product_id)
        VALUES ('RET002', 'Changed mind', TO_DATE('2023-03-22', 'YYYY-MM-DD'), 'SUCCESSFUL', 1, 0, 1, 1, 'ST002', 'OP0004');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate return RET002 not inserted.');
    END;
    
     BEGIN
        INSERT INTO return (id, reason, return_date, refund_status, quantity_returned, processing_fee, request_accepted, seller_refund, store_id, order_product_id)
        VALUES ('RET003', 'Product defect', TO_DATE('2023-03-21', 'YYYY-MM-DD'), 'SUCCESSFUL', 1, 0, 1, 1, 'ST003', 'OP0002');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate return RET003 not inserted.');
    END;
    
    BEGIN
        INSERT INTO return (id, reason, return_date, refund_status, quantity_returned, processing_fee, request_accepted, seller_refund, store_id, order_product_id)
        VALUES ('RET004', 'Late delivery', TO_DATE('2023-03-22', 'YYYY-MM-DD'), 'SUCCESSFUL', 1, 10.00, 1, 1, 'ST001', 'OP0006');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate return RET004 not inserted.');
    END;
    
   
END;
/



--------------------------------------------------------------------------------------------------------------------------------------------------------------


BEGIN
    -- Feedback 1
    BEGIN
        INSERT INTO feedback (id, customer_id, store_id, customer_rating, Review)
        VALUES ('FB001', 'C001', 'ST001', 4.5, 'Great service and quick delivery.');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate feedback FB001 not inserted.');
    END;

    -- Feedback 2
    BEGIN
        INSERT INTO feedback (id, customer_id, store_id, customer_rating, Review)
        VALUES ('FB002', 'C002', 'ST002', 3.0, 'Product was okay, but shipping was slow.');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate feedback FB002 not inserted.');
    END;

    -- Feedback 3
    BEGIN
        INSERT INTO feedback (id, customer_id, store_id, customer_rating, Review)
        VALUES ('FB003', 'C003', 'ST001', 5.0, 'Absolutely love it! Highly recommend.');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate feedback FB003 not inserted.');
    END;

    -- Feedback 4
    BEGIN
        INSERT INTO feedback (id, customer_id, store_id, customer_rating, Review)
        VALUES ('FB004', 'C001', 'ST003', 4.0, 'Great prices and friendly staff.');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate feedback FB004 not inserted.');
    END;
END;
/








--------------------------------------------------------------------------------------------------------------------------







SELECT * FROM store;

SELECT * FROM order_product;

SELECT * FROM CUSTOMER;

SELECT * FROM CATEGORY;

SELECT * FROM CUSTOMER_ORDER;

SELECT * FROM DISCOUNT;

SELECT * FROM FEEDBACK;

SELECT * FROM PRODUCT;

SELECT * FROM RETURN;

SELECT * FROM SELLER;



----------------------------------------------------------------------------------------------------------------------------------------






-----------------------------------------------------------DROP TABLES----------------------------------------------------------------------

BEGIN
    -- STORE Table
    EXECUTE IMMEDIATE 'DROP TABLE store CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    -- SELLER Table
    EXECUTE IMMEDIATE 'DROP TABLE seller CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    -- RETURN Table
    EXECUTE IMMEDIATE 'DROP TABLE return CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    -- PRODUCT Table
    EXECUTE IMMEDIATE 'DROP TABLE product CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    -- ORDER_PRODUCT Table
    EXECUTE IMMEDIATE 'DROP TABLE order_product CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    -- "Order" Table
    EXECUTE IMMEDIATE 'DROP TABLE CUSTOMER_ORDER CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    -- FEEDBACK Table
    EXECUTE IMMEDIATE 'DROP TABLE feedback CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    -- DISCOUNT Table
    EXECUTE IMMEDIATE 'DROP TABLE discount CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    -- CUSTOMER Table
    EXECUTE IMMEDIATE 'DROP TABLE customer CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    -- CATEGORY Table
    EXECUTE IMMEDIATE 'DROP TABLE category CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/
