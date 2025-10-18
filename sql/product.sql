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