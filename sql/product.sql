USE ecommerce;

DROP PROCEDURE IF EXISTS retrieveProductById;

DELIMITER //

CREATE PROCEDURE retrieveProductById(
    IN input_product_id INT UNSIGNED
)
BEGIN

    SELECT brand_name, name, sku, colorway, retail_price, release_date, image_url
    FROM products p
    JOIN brands ON p.brand_id = brands.brand_id
    WHERE product_id = input_product_id;

END//

DROP PROCEDURE IF EXISTS retrieveProductPreviewById;

CREATE PROCEDURE retrieveProductPreviewById(
    IN input_product_id INT UNSIGNED
)
BEGIN

    CALL retrieveProductById(input_product_id);

END//

DROP PROCEDURE IF EXISTS retrieveProductByBrandId;

CREATE PROCEDURE retrieveProductByBrandId(
    IN input_brand_id INT UNSIGNED
)

BEGIN

    SELECT product_id, name, sku, colorway, retail_price, release_date, image_url
    FROM products
    WHERE brand_id = input_brand_id
    ORDER BY release_date DESC;

END //

DROP PROCEDURE IF EXISTS ProductSearch;

CREATE PROCEDURE ProductSearch(
    IN input_brand_id INT UNSIGNED,
    IN input_brand_name VARCHAR(255),
    IN input_product_name VARCHAR(255)
)
BEGIN
    SET @product_pattern = CONCAT('%', input_product_name, '%');
    SET @brand_pattern = CONCAT('%', input_brand_name, '%');

    IF input_brand_id IS NOT NULL THEN
        SELECT
            p.product_id,
            p.name,
            p.brand_id,
            p.image_url,
            p.retail_price,
            JSON_ARRAYAGG(
                JSON_OBJECT('size_id', s.size_id, 'size_value', s.size_value)
            ) AS sizes
        FROM
            products p
        LEFT JOIN products_sizes ps ON p.product_id = ps.product_id
        LEFT JOIN sizes s ON ps.size_id = s.size_id
        WHERE
            p.name LIKE @product_pattern
            AND p.brand_id = input_brand_id
        GROUP BY
            p.product_id;

    ELSEIF input_brand_name IS NOT NULL AND input_brand_name != '' THEN
        SELECT
            p.product_id,
            p.name,
            p.brand_id,
            p.image_url,
            p.retail_price,
            JSON_ARRAYAGG(
                JSON_OBJECT('size_id', s.size_id, 'size_value', s.size_value)
            ) AS sizes
        FROM
            products p
        INNER JOIN
            brands b ON p.brand_id = b.brand_id
        LEFT JOIN products_sizes ps ON p.product_id = ps.product_id
        LEFT JOIN sizes s ON ps.size_id = s.size_id
        WHERE
            p.name LIKE @product_pattern
            AND b.brand_name LIKE @brand_pattern
        GROUP BY
            p.product_id;

    ELSE
        SELECT
            p.product_id,
            p.name,
            p.brand_id,
            p.image_url,
            p.retail_price,
            JSON_ARRAYAGG(
                JSON_OBJECT('size_id', s.size_id, 'size_value', s.size_value)
            ) AS sizes
        FROM
            products p
        LEFT JOIN products_sizes ps ON p.product_id = ps.product_id
        LEFT JOIN sizes s ON ps.size_id = s.size_id
        WHERE
            p.name LIKE @product_pattern
        GROUP BY
            p.product_id;
    END IF;

END //

DROP PROCEDURE IF EXISTS addListing;

CREATE PROCEDURE addListing(
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