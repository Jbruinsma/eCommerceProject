USE ecommerce;

DELIMITER //

CREATE PROCEDURE retrieveAllBrands()
BEGIN

    SELECT *
    FROM brands
    ORDER BY brand_name;

END//

DELIMITER ;