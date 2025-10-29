USE ecommerce;

DELIMITER //

DROP PROCEDURE IF EXISTS retrieveAllOrdersByUserId;

CREATE PROCEDURE retrieveAllOrdersByUserId(
    IN input_user_id CHAR(36)
)
BEGIN

    SELECT
        o.order_id,
        o.sale_price,
        o.order_status,
        o.created_at,
        p.name AS product_name,
        p.image_url AS product_image_url,
        b.brand_name,
        s.size_value,
        CASE
            WHEN o.seller_id = input_user_id THEN 'sell'
            ELSE 'buy'
        END AS user_role,
        CASE
            WHEN o.seller_id = input_user_id THEN o.seller_final_payout
            ELSE o.buyer_final_price
        END AS user_net_amount
    FROM
        orders o
    JOIN
        products p ON o.product_id = p.product_id
    JOIN
        brands b ON p.brand_id = b.brand_id
    JOIN
        sizes s ON o.size_id = s.size_id
    WHERE
        o.buyer_id = input_user_id OR o.seller_id = input_user_id
    ORDER BY
        o.created_at DESC;

END //


DROP PROCEDURE IF EXISTS retrieveRawOrdersByProductId;

CREATE PROCEDURE retrieveRawOrdersByProductId(
    IN input_product_id INT UNSIGNED
)
BEGIN

    SELECT *
    FROM orders
    WHERE product_id = input_product_id;

END //

DROP PROCEDURE IF EXISTS retrieveOrderIdsByProductId;

CREATE PROCEDURE retrieveOrderIdsByProductId(
    IN input_product_id INT UNSIGNED
)

BEGIN

    SELECT order_id
    FROM orders
    WHERE product_id = input_product_id;


END //

DROP PROCEDURE IF EXISTS retrieveOrderById;

CREATE PROCEDURE retrieveOrderById(
    IN input_order_id CHAR(36)
)

BEGIN

    SELECT
        o.order_id AS order_id,
        o.buyer_id AS buyer_id,
        o.seller_id AS seller_id,
        o.order_status AS order_status,

        o.buyer_transaction_fee AS buyer_transaction_fee,
        o.buyer_final_price AS buyer_final_price,
        o.seller_transaction_fee AS seller_transaction_fee,
        o.seller_final_payout AS seller_final_payout,

        o.product_id AS product_id,
        o.size_id AS size_id,
        s.size_value AS size,
        p.brand_id AS brand_id,
        b.brand_name AS brand_name,
        p.name AS product_name,
        p.sku AS product_sku,
        p.colorway AS product_colorway,
        p.image_url AS product_image_url,
        p.retail_price AS product_retail_price,

        a.name AS address_name,
        a.address_line_1 AS address_line_1,
        a.address_line_2 AS address_line_2,
        a.city AS city,
        a.state AS state,
        a.zip_code AS zip_code,
        a.country AS country,

        o.created_at AS created_at,
        o.updated_at AS updated_at

    FROM orders o
    JOIN ecommerce.sizes s ON o.size_id = s.size_id
    JOIN ecommerce.products p ON o.product_id = p.product_id
    JOIN ecommerce.brands b ON p.brand_id = b.brand_id
    JOIN ecommerce.addresses a ON o.order_id = a.order_id
    WHERE o.order_id = input_order_id;

END //

DROP PROCEDURE IF EXISTS createNewOrder;

CREATE PROCEDURE createNewOrder(
    IN input_buyer_id CHAR(36),
    IN input_listing_id INT UNSIGNED,
    IN input_buyer_transaction_fee_structure_id INT UNSIGNED
)

BEGIN

    DECLARE new_order_id CHAR(36);
    DECLARE calculated_seller_id CHAR(36);
    DECLARE calculated_product_id INT UNSIGNED;
    DECLARE calculated_size_id INT UNSIGNED;
    DECLARE calculated_sale_price DECIMAL(10,2);

    DECLARE calculated_buyer_transaction_fee_percentage DECIMAL(10,4);
    DECLARE calculated_buyer_transaction_fee DECIMAL(10,2);
    DECLARE calculated_final_buyer_price DECIMAL(10,2);

    DECLARE calculated_seller_fee_structure_id INT UNSIGNED;
    DECLARE calculated_seller_transaction_fee_percentage DECIMAL(10,4);
    DECLARE calculated_seller_transaction_fee DECIMAL(10,2);
    DECLARE calculated_seller_final_payout DECIMAL(10,2);

    SET new_order_id = UUID();

    SELECT user_id INTO calculated_seller_id
    FROM listings
    WHERE listing_id = input_listing_id;

    SELECT product_id INTO calculated_product_id
    FROM listings
    WHERE listing_id = input_listing_id;

    SELECT size_id INTO calculated_size_id
    FROM listings
    WHERE listing_id = input_listing_id;

    SELECT price INTO calculated_sale_price
    FROM listings
    WHERE listing_id = input_listing_id;

    SELECT buyer_fee_percentage INTO calculated_buyer_transaction_fee_percentage
    FROM fee_structures
    WHERE id = input_buyer_transaction_fee_structure_id;

    SET calculated_buyer_transaction_fee = ROUND((calculated_sale_price * calculated_buyer_transaction_fee_percentage), 2);

    SET calculated_final_buyer_price = calculated_sale_price + calculated_buyer_transaction_fee;

    SELECT fee_structure_id INTO calculated_seller_fee_structure_id
    FROM listings
    WHERE listing_id = input_listing_id;

    SELECT seller_fee_percentage INTO calculated_seller_transaction_fee_percentage
    FROM fee_structures
    WHERE id = calculated_seller_fee_structure_id;

    SET calculated_seller_transaction_fee = ROUND((calculated_sale_price * calculated_seller_transaction_fee_percentage), 2);
    SET calculated_seller_final_payout = ROUND((calculated_sale_price - calculated_seller_transaction_fee), 2);

    INSERT INTO orders(
                       order_id,
                       buyer_id,
                       seller_id,
                       product_id,
                       size_id,
                       sale_price,
                       buyer_transaction_fee,
                       buyer_fee_structure_id,
                       buyer_final_price,
                       seller_transaction_fee,
                       seller_fee_structure_id,
                       seller_final_payout,
                       order_status,
                       created_at,
                       updated_at
        )
        VALUES(
               new_order_id,
                input_buyer_id,
                calculated_seller_id,
                calculated_product_id,
               calculated_size_id,
                calculated_sale_price,
               calculated_buyer_transaction_fee,
               input_buyer_transaction_fee_structure_id,
                calculated_final_buyer_price,
                calculated_seller_transaction_fee,
                calculated_seller_fee_structure_id,
                calculated_seller_final_payout,
                'pending',
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP
              );

    SELECT * FROM orders WHERE order_id = new_order_id;

END //

DROP PROCEDURE IF EXISTS updateOrderStatus;

CREATE PROCEDURE updateOrderStatus(
    IN input_order_id CHAR(36),
    IN input_new_status ENUM('pending', 'completed', 'canceled', 'failed')
)

BEGIN

    UPDATE orders
    SET
        order_status = input_new_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE order_id = input_order_id;

    SELECT * FROM orders WHERE order_id = input_order_id;

end //

DELIMITER ;