USE ecommerce;

DROP PROCEDURE IF EXISTS retrieveUserTransactionsById;

DELIMITER //

CREATE PROCEDURE retrieveUserTransactionsById(
    IN input_uuid CHAR(36)
)
BEGIN

    SELECT * FROM transactions
    WHERE user_id = input_uuid
    ORDER BY created_at DESC;

END//

DROP PROCEDURE IF EXISTS retrieveTransactionsByOrderId;

CREATE PROCEDURE retrieveTransactionsByOrderId(
    IN input_order_id INT UNSIGNED
)

BEGIN

    SELECT * FROM transactions
    WHERE order_id = input_order_id
    ORDER BY created_at DESC;

end //

DELIMITER ;