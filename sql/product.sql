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

DELIMITER ;

DROP PROCEDURE IF EXISTS retrieveProductPreviewById;

DELIMITER //

CREATE PROCEDURE retrieveProductPreviewById(
    IN input_product_id INT UNSIGNED
)
BEGIN

    CALL retrieveProductById(input_product_id);

END//

DELIMITER ;

DROP PROCEDURE IF EXISTS retrieveProductByBrandId;

DELIMITER //

CREATE PROCEDURE retrieveProductByBrandId(
    IN input_brand_id INT UNSIGNED
)

BEGIN

    SELECT product_id, name, sku, colorway, retail_price, release_date, image_url
    FROM products
    WHERE brand_id = input_brand_id
    ORDER BY release_date DESC;

END //

DELIMITER ;

DROP PROCEDURE IF EXISTS ProductSearch;

DELIMITER //

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
            p.image_url
        FROM
            products p
        WHERE
            p.name LIKE @product_pattern
            AND p.brand_id = input_brand_id;

    ELSEIF input_brand_name IS NOT NULL AND input_brand_name != '' THEN
        SELECT
            p.product_id,
            p.name,
            p.brand_id,
            p.image_url
        FROM
            products p
        INNER JOIN
            brands b ON p.brand_id = b.brand_id
        WHERE
            p.name LIKE @product_pattern
            AND b.brand_name LIKE @brand_pattern;
    ELSE
        SELECT
            product_id,
            name,
            brand_id,
            image_url
        FROM
            products
        WHERE
            name LIKE @product_pattern;
    END IF;

END //

DELIMITER ;