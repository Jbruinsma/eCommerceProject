USE ecommerce;

DELIMITER //

DROP PROCEDURE IF EXISTS retrieveAllListingsByUserId;

CREATE PROCEDURE retrieveAllListingsByUserId(
    IN input_user_id CHAR(36)
)

BEGIN

    SELECT
        l.*,
        p.name AS product_name,
        p.image_url AS product_image_url,
        s.size_value
    FROM
        listings l
            JOIN
            products p ON l.product_id = p.product_id
            JOIN
            sizes s ON l.size_id = s.size_id
    WHERE
        l.user_id = input_user_id
    ORDER BY
        l.created_at DESC;

end //

DROP PROCEDURE IF EXISTS retrieveListingById;

CREATE PROCEDURE retrieveListingById(
    IN input_listing_id INT UNSIGNED,
    IN input_user_id CHAR(36)
)

BEGIN

    SELECT
        l.*,
        p.name AS product_name,
        p.image_url AS product_image_url,
        s.size_value
    FROM
        listings l
            JOIN
            products p ON l.product_id = p.product_id
            JOIN
            sizes s ON l.size_id = s.size_id
    WHERE
        l.listing_id = input_listing_id
        AND l.user_id = input_user_id;

end //

DROP PROCEDURE IF EXISTS createListing;

CREATE PROCEDURE createListing(
    IN input_user_id CHAR(36),
    IN input_product_id INT UNSIGNED,
    IN input_size_id INT UNSIGNED,
    IN input_listing_type ENUM('ask', 'bid'),
    IN input_price DECIMAL(10,2),
    IN input_condition ENUM('new', 'used', 'worn')
)
BEGIN

    INSERT INTO listings(
                         listing_id,
                         user_id,
                         product_id,
                         size_id,
                         listing_type,
                         price,
                         item_condition,
                         status,
                         created_at,
                         updated_at
                        )
    VALUES (
            DEFAULT,
            input_user_id,
            input_product_id,
            input_size_id,
            input_listing_type,
            input_price,
            input_condition,
            'active',
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
           );

    SELECT * FROM listings WHERE listing_id = LAST_INSERT_ID();

end //

DELIMITER ;