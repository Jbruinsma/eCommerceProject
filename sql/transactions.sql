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

DROP PROCEDURE IF EXISTS recordTransaction;

CREATE PROCEDURE recordTransaction(
    IN input_user_id CHAR(36),
    IN input_order_id INT UNSIGNED,
    IN input_amount DECIMAL(15,2),
    IN input_transaction_status ENUM('pending', 'completed', 'failed'),
    IN input_payment_origin ENUM('account_balance', 'credit_card', 'other'),
    IN input_payment_destination ENUM('account_balance', 'bank_transfer', 'other'),
    IN input_payment_purpose ENUM('sale_proceeds', 'purchase_funds', 'refund', 'fee')
)

BEGIN

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
    VALUES (
            input_user_id,
            input_order_id,
            input_amount,
            input_transaction_status,
            input_payment_origin,
            input_payment_destination,
            input_payment_purpose,
            CURRENT_TIMESTAMP
    );

    SELECT * FROM transactions WHERE transaction_id = LAST_INSERT_ID();

end //

DELIMITER ;