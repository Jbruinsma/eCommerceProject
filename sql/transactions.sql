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

DELIMITER ;