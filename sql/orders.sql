USE ecommerce;

DELIMITER //

DROP PROCEDURE IF EXISTS retrieveAllOrdersByUserId;

CREATE PROCEDURE retrieveAllOrdersByUserId(
    IN input_user_id CHAR(36)
)

BEGIN

    SELECT *
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    JOIN sizes ON o.size_id = sizes.size_id
    JOIN listings l ON o.seller_id = l.user_id AND o.product_id = l.product_id AND o.size_id = l.size_id
    WHERE buyer_id = input_user_id;

end //

DROP PROCEDURE IF EXISTS retrieveRawOrdersByProductId;

CREATE PROCEDURE retrieveRawOrdersByProductId(
    IN input_product_id INT UNSIGNED
)
BEGIN

    SELECT *
    FROM orders
    WHERE product_id = input_product_id;

end //

DROP PROCEDURE IF EXISTS retrieveOrderIdsByProductId;

CREATE PROCEDURE retrieveOrderIdsByProductId(
    IN input_product_id INT UNSIGNED
)

BEGIN

    SELECT order_id
    FROM orders
    WHERE product_id = input_product_id;


end //

DROP PROCEDURE IF EXISTS newOrder;

CREATE PROCEDURE newOrder(
    IN input_buyer_id CHAR(36),
    IN input_listing_id INT UNSIGNED,
    IN input_transaction_fee DECIMAL(10,2),
    IN input_payment_method ENUM('account_balance', 'credit_card', 'other')
)

BEGIN

    DECLARE new_order_id CHAR(36);
    SET new_order_id = UUID();

    INSERT INTO orders(
                       order_id,
                       buyer_id,
                       seller_id,
                       product_id,
                       size_id,
                       sale_price,
                       transaction_fee,
                       total_price,
                       order_status,
                       created_at,
                       updated_at
                      )
        VALUES (
                new_order_id,
                input_buyer_id,
                (SELECT user_id
                 FROM listings
                 WHERE listing_id = input_listing_id
                 ),
                (SELECT product_id
                 FROM listings
                 WHERE listing_id = input_listing_id
                 ),
                (
                SELECT size_id
                FROM listings
                WHERE listing_id = input_listing_id
                ),
                (SELECT price
                 FROM listings
                 WHERE listing_id = input_listing_id),
                input_transaction_fee,
                (SELECT price + input_transaction_fee
                 FROM listings
                 WHERE listing_id = input_listing_id
                 ),
                'pending',
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP
               );

    UPDATE listings
    SET status = 'pending'
    WHERE listing_id = input_listing_id;

    INSERT INTO transactions(
                             user_id,
                             order_id,
                             amount,
                             transaction_status,
                             payment_origin,
                             payment_destination,
                             payment_purpose,
                             created_at
    )

    VALUES(
           input_buyer_id,
              new_order_id,
              (SELECT price + input_transaction_fee
                FROM listings
                WHERE listing_id = input_listing_id
              ),
              'pending',
              input_payment_method,
              'other',
              'purchase_funds',
              CURRENT_TIMESTAMP
          );

    SELECT *
    FROM orders
    WHERE order_id = new_order_id;

end //

DROP PROCEDURE IF EXISTS createOrder;

CREATE PROCEDURE createOrder(
    IN input_buyer_id CHAR(36),
    IN input_seller_id CHAR(36),
    IN input_product_id INT UNSIGNED,
    IN input_size_id INT UNSIGNED,
    IN input_sale_price DECIMAL(10,2),
    IN input_transaction_fee DECIMAL(10,2),
    IN input_total_amount DECIMAL(10,2),
    IN input_order_status ENUM('pending', 'completed', 'cancelled', 'failed')
)

BEGIN

    DECLARE new_order_id CHAR(36);
    SET new_order_id = UUID();

    INSERT INTO orders(
                       order_id,
                       buyer_id,
                       seller_id,
                       product_id,
                       size_id,
                       sale_price,
                       transaction_fee,
                       total_price,
                       order_status,
                       created_at,
                       updated_at
        )

        VALUES (
                new_order_id,
                input_buyer_id,
                input_seller_id,
                input_product_id,
                input_size_id,
                input_sale_price,
                input_transaction_fee,
                input_total_amount,
                input_order_status,
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP
               );

end //

DELIMITER ;