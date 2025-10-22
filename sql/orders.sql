USE ecommerce;

DELIMITER //

DROP PROCEDURE IF EXISTS retrieveAllOrdersByUserId;

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

end //

DELIMITER ;