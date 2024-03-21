SET SERVEROUTPUT ON;
DECLARE
    CNT NUMBER;
BEGIN
    -- CATEGORY
    SELECT COUNT(*) INTO CNT FROM USER_TABLES WHERE TABLE_NAME = 'CATEGORY';
    IF cnt = 0 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE category (
            ID VARCHAR2(10) CONSTRAINT category_pk PRIMARY KEY,
            name VARCHAR2(20) Unique NOT NULL,
            return_by_days NUMBER(2) NOT NULL CHECK (return_by_days > 0 AND return_by_days < 100)
        )';
    ELSE
        DBMS_OUTPUT.PUT_LINE('Table category already exists.');
    END IF;

    -- CUSTOMER
    SELECT COUNT(*) INTO CNT FROM USER_TABLES WHERE TABLE_NAME = 'CUSTOMER';
    IF CNT = 0 THEN
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
    SELECT COUNT(*) INTO CNT FROM USER_TABLES WHERE TABLE_NAME = 'SELLER';
    IF CNT = 0 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE seller (
            id VARCHAR2(10) CONSTRAINT seller_pk PRIMARY KEY,
            name       VARCHAR(20) NOT NULL,
            contact_no NUMBER(10) Unique NOT NULL
        )';
    ELSE
        DBMS_OUTPUT.PUT_LINE('Table seller already exists.');
    END IF;

    -- PRODUCT
    SELECT COUNT(*) INTO CNT FROM USER_TABLES WHERE TABLE_NAME = 'PRODUCT';
    IF CNT = 0 THEN
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
        end_date_later_than_start_date_CK CHECK (mfg_date < exp_date)'; 
    ELSE
        DBMS_OUTPUT.PUT_LINE('Table product already exists.');
    END IF;

    -- ORDER (CUSTOMER_ORDER to avoid SQL keyword conflict)
    SELECT COUNT(*) INTO CNT FROM USER_TABLES WHERE TABLE_NAME = 'CUSTOMER_ORDER';
    IF CNT = 0 THEN
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
    SELECT COUNT(*) INTO CNT FROM USER_TABLES WHERE TABLE_NAME = 'ORDER_PRODUCT';
    IF CNT = 0 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE order_product (
            id VARCHAR2(10) CONSTRAINT order_product_pk PRIMARY KEY,
            customer_order_id VARCHAR2(10) NOT NULL,
            product_id VARCHAR2(10) NOT NULL,
            quantity NUMBER(3) NOT NULL  CHECK (quantity > 0 ),
            CONSTRAINT fk_order_product_order FOREIGN KEY (customer_order_id) REFERENCES customer_order(id),
            CONSTRAINT fk_order_product_product FOREIGN KEY (product_id) REFERENCES product(id)
        )';
    ELSE
        DBMS_OUTPUT.PUT_LINE('Table order_product already exists.');
    END IF;

    -- DISCOUNT
    SELECT COUNT(*) INTO CNT FROM USER_TABLES WHERE TABLE_NAME = 'DISCOUNT';
    IF CNT = 0 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE discount (
            id VARCHAR2(10) CONSTRAINT discount_pk PRIMARY KEY,
            category_id VARCHAR2(10) NOT NULL,
            discount_rate NUMBER(3,1) NOT NULL CHECK (discount_rate > 0 AND discount_rate < 100),
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
    SELECT COUNT(*) INTO CNT FROM USER_TABLES WHERE TABLE_NAME = 'STORE';
    IF CNT = 0 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE store (
            id VARCHAR2(10) CONSTRAINT store_pk PRIMARY KEY,
            name              VARCHAR(20) NOT NULL,
            contact_no        NUMBER(10)unique NOT NULL,
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
    SELECT COUNT(*) INTO CNT FROM USER_TABLES WHERE TABLE_NAME = 'FEEDBACK';
    IF CNT = 0 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE feedback (
            id VARCHAR2(10) CONSTRAINT feedback_pk PRIMARY KEY,
            customer_id VARCHAR2(10) NOT NULL,
            store_id VARCHAR2(10) NOT NULL,
            customer_rating NUMBER(2,1) NOT NULL CHECK (customer_rating >= 1.0 AND customer_rating <= 5.0),
            Review VARCHAR2(500) NOT NULL,
            CONSTRAINT fk_feedback_customer FOREIGN KEY (customer_id) REFERENCES customer(id),
            CONSTRAINT fk_feedback_order FOREIGN KEY (store_id) REFERENCES store(id)
        )';
    ELSE
        DBMS_OUTPUT.PUT_LINE('Table feedback already exists.');
    END IF;

    -- RETURN
    SELECT COUNT(*) INTO CNT FROM USER_TABLES WHERE TABLE_NAME = 'RETURN';
    IF CNT = 0 THEN
      EXECUTE IMMEDIATE 'CREATE TABLE return (
        id VARCHAR2(10) CONSTRAINT return_pk PRIMARY KEY,
        reason VARCHAR(500) NOT NULL,
        return_date DATE NOT NULL,
        refund_status VARCHAR(20) CHECK (refund_status IN (''IN_PROGRESS'', ''SUCCESSFUL'')),
        quantity_returned NUMBER(3) NOT NULL CHECK (quantity_returned > 0 ),
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

COMMENT ON COLUMN return.id IS 'Unique identifier for each return record(PK)';
COMMENT ON COLUMN return.reason IS 'Description of the reason for the return';
COMMENT ON COLUMN return.return_date IS 'Date when the return was requested';
COMMENT ON COLUMN return.refund_status IS 'Current status of the refund, can be IN_PROGRESS or SUCCESSFUL';
COMMENT ON COLUMN return.quantity_returned IS 'Number of items returned';
COMMENT ON COLUMN return.processing_fee IS 'Fee charged for processing the return, if applicable';
COMMENT ON COLUMN return.request_accepted IS 'Indicates if the return request has been accepted (1) or not (0)';
COMMENT ON COLUMN return.seller_refund IS 'Indicates if the seller agrees to refund (1) or not (0)';
COMMENT ON COLUMN return.store_id IS 'Identifier of the store from which the item was purchased(FK)';
COMMENT ON COLUMN return.order_product_id IS 'Identifier of the ordered product being returned(FK)';




COMMENT ON COLUMN feedback.id IS 'Unique identifier for each feedback record(PK)';
COMMENT ON COLUMN feedback.customer_id IS 'Identifier of the customer providing feedback';
COMMENT ON COLUMN feedback.store_id IS 'Identifier of the store to which the feedback is directed(FK)';
COMMENT ON COLUMN feedback.customer_rating IS 'Numerical rating given by the customer, ranging from 1.0 to 5.0';
COMMENT ON COLUMN feedback.Review IS 'Textual review provided by the customer describing their experience';



COMMENT ON COLUMN store.id IS 'Unique identifier for each store(PK)';
COMMENT ON COLUMN store.name IS 'Name of the store';
COMMENT ON COLUMN store.contact_no IS 'Contact number for the store, must be unique';
COMMENT ON COLUMN store.address_line IS 'Address line for the store location';
COMMENT ON COLUMN store.city IS 'City where the store is located';
COMMENT ON COLUMN store.state IS 'State where the store is located';
COMMENT ON COLUMN store.zip_code IS 'ZIP code for the store location';
COMMENT ON COLUMN store.accepting_returns IS 'Indicates if the store accepts returns (1) or not (0)';



COMMENT ON COLUMN discount.id IS 'Unique identifier for each discount record(PK)';
COMMENT ON COLUMN discount.category_id IS 'Identifier of the category to which the discount applies(FK)';
COMMENT ON COLUMN discount.discount_rate IS 'Percentage rate of the discount, must be more than 0 and less than 100';
COMMENT ON COLUMN discount.start_date IS 'The start date from which the discount is applicable';
COMMENT ON COLUMN discount.end_date IS 'The end date until which the discount is applicable';
COMMENT ON TABLE discount IS 'Constraints: disend_date_later_than_start_date_CK ensures that the start date is on or before the end date.';


COMMENT ON COLUMN product.id IS 'Unique identifier for each product(PK)';
COMMENT ON COLUMN product.name IS 'Name of the product';
COMMENT ON COLUMN product.price IS 'Price of the product';
COMMENT ON COLUMN product.mfg_date IS 'Manufacturing date of the product';
COMMENT ON COLUMN product.exp_date IS 'Expiration date of the product, if applicable';
COMMENT ON COLUMN product.category_id IS 'Identifier for the category of the product(FK)';
COMMENT ON COLUMN product.seller_id IS 'Identifier for the seller of the product(FK)';
COMMENT ON COLUMN product.exp_date IS 'Ensures the expiration date is later than the manufacturing date, if expiration date is specified';



COMMENT ON COLUMN category.ID IS 'Unique identifier for each category(PK)';
COMMENT ON COLUMN category.name IS 'Name of the category, must be unique';
COMMENT ON COLUMN category.return_by_days IS 'Number of days within which items of this category can be returned, must be between 1 and 99';



COMMENT ON COLUMN customer.id IS 'Unique identifier for each customer(PK)';
COMMENT ON COLUMN customer.name IS 'Full name of the customer';
COMMENT ON COLUMN customer.contact_no IS 'Contact number of the customer, must be unique';
COMMENT ON COLUMN customer.date_of_birth IS 'Date of birth of the customer';
COMMENT ON COLUMN customer.email_id IS 'Email address of the customer, must be unique';
COMMENT ON COLUMN customer.joined_date IS 'Date when the customer joined or was registered';
COMMENT ON COLUMN customer.address_line IS 'Address line for the customers residence';
COMMENT ON COLUMN customer.city IS 'City part of the customers address';
COMMENT ON COLUMN customer.state IS 'State part of the customers address';
COMMENT ON COLUMN customer.zip_code IS 'ZIP code part of the customers address';


COMMENT ON COLUMN seller.id IS 'Unique identifier for each seller(PK)';
COMMENT ON COLUMN seller.name IS 'Name of the seller';
COMMENT ON COLUMN seller.contact_no IS 'Contact number of the seller, must be unique';

COMMENT ON COLUMN customer_order.id IS 'Unique identifier for each customer order(PK)';
COMMENT ON COLUMN customer_order.customer_id IS 'Reference to the customer who placed the order(FK)';
COMMENT ON COLUMN customer_order.order_date IS 'Date when the order was placed';
COMMENT ON COLUMN customer_order.status IS 'Current status of the order, which can be DELIVERED, IN_TRANSIT, SHIPPED, or ORDER_PLACED';


COMMENT ON COLUMN order_product.id IS 'Unique identifier for each order-product relation record(PK)';
COMMENT ON COLUMN order_product.customer_order_id IS 'Reference to the customer order this product is part of(FK)';
COMMENT ON COLUMN order_product.product_id IS 'Reference to the product included in the order(FK)';
COMMENT ON COLUMN order_product.quantity IS 'Quantity of the product ordered';
-----------------------------------------------------------------------------------------------------------------
BEGIN
    BEGIN
        INSERT INTO customer (id, name, contact_no, date_of_birth, email_id, joined_date, address_line, city, state, zip_code)
        VALUES ('C001', 'Alice Michel', '9100000001', TO_DATE('1992-06-01', 'YYYY-MM-DD'), 'alice@gmail.com', TO_DATE('2022-01-10', 'YYYY-MM-DD'), '123 Harvard Ave', 'Boston', 'MA', '12345');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate entry for Alice Michel or phone number or email already in use.');
    END;

    BEGIN
        INSERT INTO customer (id, name, contact_no, date_of_birth, email_id, joined_date, address_line, city, state, zip_code)
        VALUES ('C002', 'Bob Santos', '9200000002', TO_DATE('1988-08-15', 'YYYY-MM-DD'), 'bob@gmail.com', TO_DATE('2022-02-20', 'YYYY-MM-DD'), '456 Brokkline Rd', 'New York', 'NY', '23456');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate entry for Bob Santos or phone number or email already in use.');
    END;

    BEGIN
        INSERT INTO customer (id, name, contact_no, date_of_birth, email_id, joined_date, address_line, city, state, zip_code)
        VALUES ('C003', 'Charlie Heisenberg', '9300000003', TO_DATE('1990-12-25', 'YYYY-MM-DD'), 'charlie@gmail.com', TO_DATE('2022-03-15', 'YYYY-MM-DD'), '789 Cocoa St', 'Chicago', 'IL', '34567');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate entry for Charlie Heisenberg or phone number or email already in use..');
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
            DBMS_OUTPUT.PUT_LINE('Duplicate seller Apple Inc or phone number in use, not inserted.');
    END;
    
    BEGIN
        INSERT INTO seller (id, name, contact_no)
        VALUES ('NIK', 'Nike', 8008066453);
    EXCEPTION 
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate seller Nike Inc. not inserted or phone number in use, not inserted..');
    END;
    
    BEGIN
        INSERT INTO seller (id, name, contact_no)
        VALUES ('VIC', 'Vicks', 8003621683);
    EXCEPTION 
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate seller Nike. not inserted or phone number in use, not inserted..');
    END;
    
    BEGIN
        INSERT INTO seller (id, name, contact_no)
        VALUES ('WHO', 'Whole Foods', 8005551212);
    EXCEPTION 
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate seller Whole Foodsor phone number in use, not inserted.');
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
        DBMS_OUTPUT.PUT_LINE('Duplicate product PROD001-Milk not inserted.');
    END;
    
    -- Inserting Bread with mfg_date and exp_date
    BEGIN
        INSERT INTO product (id, name, price, category_id, seller_id, mfg_date, exp_date)
        VALUES ('PROD002', 'Bread', 3.49, 'SM001', 'WHO', TO_DATE('2023-03-10', 'YYYY-MM-DD'), TO_DATE('2023-03-25', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate product PROD002-Bread not inserted.');
    END;
    
    -- Inserting Cake with mfg_date and exp_date
    BEGIN
            INSERT INTO product (id, name, price, category_id, seller_id, mfg_date, exp_date)
            VALUES ('PROD003', 'Cake', 15.00, 'SM001', 'WHO', TO_DATE('2023-03-11', 'YYYY-MM-DD'), TO_DATE('2023-03-25', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate product PROD003-Cake not inserted.');
    END;
END;
/


BEGIN
    -- Electronics Products
    BEGIN
        INSERT INTO product (id, name, price, category_id, seller_id, mfg_date)
        VALUES ('PROD004', 'iPhone', 999.00, 'SM002', 'APL', TO_DATE('2024-02-15', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate product PROD004-iPhone not inserted.');
    END;
    
    BEGIN
        INSERT INTO product (id, name, price, category_id, seller_id, mfg_date)
        VALUES ('PROD005', 'Laptop', 1300.00, 'SM002', 'APL', TO_DATE('2024-01-10', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate product PROD005-Laptop not inserted.');
    END;
    
    BEGIN
        INSERT INTO product (id, name, price, category_id, seller_id, mfg_date)
        VALUES ('PROD006', 'Watches', 250.00, 'SM002', 'APL', TO_DATE('2024-02-05', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate product PROD006-Watches not inserted.');
    END;
    
    -- Clothing/Apparel Products
    BEGIN
        INSERT INTO product (id, name, price, category_id, seller_id, mfg_date)
        VALUES ('PROD007', 'Shoes', 120.00, 'SM003', 'NIK', TO_DATE('2024-03-01', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate product PROD007-Shoes not inserted.');
    END;
    
    BEGIN
        INSERT INTO product (id, name, price, category_id, seller_id, mfg_date)
        VALUES ('PROD008', 'Jacket', 250.00, 'SM003', 'NIK', TO_DATE('2024-02-20', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate product PROD008-Jacket not inserted.');
    END;
    
    BEGIN
        INSERT INTO product (id, name, price, category_id, seller_id, mfg_date)
        VALUES ('PROD009', 'Trousers', 85.00, 'SM003', 'NIK', TO_DATE('2024-01-25', 'YYYY-MM-DD'));
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate product PROD009-Trousers not inserted.');
    END;
END;
/


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
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0001', 'ORD001', 'PROD001', 3);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0001 not inserted.');
    END;
    
    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0002', 'ORD001', 'PROD002', 1);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0002 not inserted.');
    END;
    
    -- Order 2 Product Associations
    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0003', 'ORD002', 'PROD003', 2);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0003 not inserted.');
    END;
    
    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0004', 'ORD002', 'PROD004', 2);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0004 not inserted.');
    END;
    
    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0005', 'ORD003', 'PROD005', 1);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0005 not inserted.');
    END;
    
    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0006', 'ORD003', 'PROD006', 3);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0006 not inserted.');
    END;

    -- Order 4 Product Associations
    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0007', 'ORD004', 'PROD007', 2);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0007 not inserted.');
    END;
    
    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0008', 'ORD004', 'PROD008', 1);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0008 not inserted.');
    END;

    -- Order 5 Product Associations
    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0009', 'ORD005', 'PROD009', 2);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0009 not inserted.');
    END;
    
    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0010', 'ORD005', 'PROD001', 3);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0010 not inserted.');
    END;
    
    -- Order 6 Product Associations
    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0011', 'ORD006', 'PROD005', 2);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0011 not inserted.');
    END;

    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0012', 'ORD006', 'PROD006', 3);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0012 not inserted.');
    END;

    -- Order 7 Product Associations
    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0013', 'ORD007', 'PROD001', 1);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0013 not inserted.');
    END;

    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0014', 'ORD007', 'PROD002', 2);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0014 not inserted.');
    END;

    -- Order 8 Product Associations
    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0015', 'ORD008', 'PROD003', 3);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0015 not inserted.');
    END;

    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0016', 'ORD008', 'PROD004', 1);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0016 not inserted.');
    END;

    -- Order 9 Product Associations
    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0017', 'ORD009', 'PROD005', 2);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0017 not inserted.');
    END;

    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0018', 'ORD009', 'PROD006', 3);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0018 not inserted.');
    END;

    -- Order 10 Product Associations
    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
        VALUES ('OP0019', 'ORD010', 'PROD001', 1);
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate entry for OP0019 not inserted.');
    END;

    BEGIN
        INSERT INTO order_product (id, customer_order_id, product_id, quantity)
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
            DBMS_OUTPUT.PUT_LINE('Duplicate store ST001-UPS or phone number in use, not inserted.');
        
    END;

    -- Inserting FedEx in New York
    BEGIN
        INSERT INTO store (id, name, contact_no, address_line, city, state, zip_code, accepting_returns)
        VALUES ('ST002', 'FedEx', 8004633339, '2 FedEx Plaza', 'New York', 'NY', '10001', 1);
    EXCEPTION 
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate store ST002-FedEx or phone number in use, not inserted.');
       
    END;

    -- Inserting Five Guys in Chicago
    BEGIN
        INSERT INTO store (id, name, contact_no, address_line, city, state, zip_code, accepting_returns)
        VALUES ('ST003', 'Five Guys', 8005551234, '3 Burger Blvd', 'Chicago', 'IL', '60606', 1);
    EXCEPTION 
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Duplicate store ST003-Five Guys or phone number in use, not inserted.');
        
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
        VALUES ('RET004', 'Late delivery.', TO_DATE('2023-03-22', 'YYYY-MM-DD'), 'SUCCESSFUL', 1, 10.00, 1, 1, 'ST001', 'OP0006');
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
        VALUES ('FB002', 'C002', 'ST002', 3.0, 'Staffs not helpful.');
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
        VALUES ('FB004', 'C001', 'ST003', 4.0, 'Very-helpful and friendly staff.');
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicate feedback FB004 not inserted.');
    END;
END;
/



