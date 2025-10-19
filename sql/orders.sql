USE ecommerce;

DELIMITER //

DROP PROCEDURE IF EXISTS retrieveRawOrdersByProductId;

CREATE PROCEDURE retrieveRawOrdersByProductId(
    IN input_product_id INT UNSIGNED
)
BEGIN

    SELECT *
    FROM orders
    WHERE product_id = input_product_id;

end //

CREATE PROCEDURE retrieveOrderIdsByProductId(
    IN input_product_id INT UNSIGNED
)

BEGIN

    SELECT order_id
    FROM orders
    WHERE product_id = input_product_id;

end //

DELIMITER ;