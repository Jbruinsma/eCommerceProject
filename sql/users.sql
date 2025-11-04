USE ecommerce;

DELIMITER //

DROP PROCEDURE IF EXISTS createNewUser;

CREATE PROCEDURE createNewUser(
    IN input_email VARCHAR(225),
    IN input_hashed_password VARCHAR(255),
    IN input_role ENUM('user', 'admin')
)
BEGIN

    DECLARE new_user_uuid CHAR(36);
    SET new_user_uuid = UUID();

    INSERT INTO users (uuid, email, password, role)
    VALUES (new_user_uuid, input_email, input_hashed_password, input_role);

    INSERT INTO account_balance (user_id, balance)
    VALUES (new_user_uuid, 0.00);

    SELECT
        uuid,
        email,
        first_name,
        last_name,
        location,
        birth_date,
        role,
        created_at,
        updated_at
    FROM users
    WHERE uuid = new_user_uuid;

END //

DROP PROCEDURE IF EXISTS deleteUser;

CREATE PROCEDURE deleteUser(
    IN input_uuid CHAR(36),
    IN input_email VARCHAR(225)
)

BEGIN

    DECLARE target_user_uuid CHAR(36);

    IF input_uuid IS NOT NULL THEN
        SET target_user_uuid = input_uuid;
    END IF;

    IF input_email IS NOT NULL THEN
        SELECT uuid INTO target_user_uuid
        FROM users
        WHERE email = input_email;
    END IF;

    DELETE FROM account_balance
    WHERE user_id = target_user_uuid;

    DELETE FROM users
    WHERE uuid = target_user_uuid;

    SET FOREIGN_KEY_CHECKS = 1;

END //

DROP PROCEDURE IF EXISTS updateUser;

CREATE PROCEDURE updateUser(
    IN input_uuid CHAR(36),
    IN input_email VARCHAR(225),
    IN input_first_name VARCHAR(100),
    IN input_last_name VARCHAR(100),
    IN input_location VARCHAR(255),
    IN input_birth_date DATE,
    IN input_role ENUM('user', 'admin')
)

BEGIN

  UPDATE users
  SET
    email = IF(input_email IS NULL, email, input_email),
    first_name = IF(input_first_name IS NULL, first_name, input_first_name),
    last_name = IF(input_last_name IS NULL, last_name, input_last_name),
    location = IF(input_location IS NULL, location, input_location),
    birth_date = IF(input_birth_date IS NULL, birth_date, input_birth_date),
    role = IF(input_role IS NULL, role, input_role)
  WHERE uuid = input_uuid;

  SELECT
    uuid,
    email,
    first_name,
    last_name,
    location,
    birth_date,
    role,
    created_at,
    updated_at
  FROM users
  WHERE uuid = input_uuid;

END//

DROP PROCEDURE IF EXISTS retrieveUserBalanceById;

CREATE PROCEDURE retrieveUserBalanceById(
    IN input_uuid CHAR(36)
)

BEGIN

    SELECT balance
    FROM account_balance
    WHERE user_id = input_uuid;

end //

DROP PROCEDURE IF EXISTS updateBalance;

CREATE PROCEDURE updateBalance(
    IN input_uuid CHAR(36),
    IN input_email VARCHAR(225),
    IN input_balance_adjustment_amount DECIMAL(10, 2)
)

BEGIN

    UPDATE account_balance
    SET balance = balance + input_balance_adjustment_amount
    WHERE
        (input_uuid IS NOT NULL AND user_id = input_uuid)
        OR
        (input_email IS NOT NULL AND user_id = (SELECT uuid FROM users WHERE email = input_email));

    SELECT balance
    FROM account_balance
    WHERE
        (input_uuid IS NOT NULL AND user_id = input_uuid)
        OR
        (input_email IS NOT NULL AND user_id = (SELECT uuid FROM users WHERE email = input_email));

end //


DROP PROCEDURE IF EXISTS calculateLifetimeEarnings;

CREATE PROCEDURE calculateLifetimeEarnings(
    IN input_uuid CHAR(36)
)
BEGIN
    DECLARE total_sales_amount DECIMAL(10, 2) DEFAULT 0.00;
    DECLARE total_refunds_amount DECIMAL(10, 2) DEFAULT 0.00;

    SELECT SUM(amount) INTO total_sales_amount
    FROM transactions
    WHERE
        user_id = input_uuid
        AND payment_purpose = 'sale_proceeds'
        AND transaction_status = 'completed';

    SELECT SUM(amount) INTO total_refunds_amount
    FROM transactions
    WHERE
        user_id = input_uuid
        AND payment_purpose = 'refund';

    IF total_sales_amount IS NULL THEN
        SET total_sales_amount = 0.00;
    END IF;

    IF total_refunds_amount IS NULL THEN
        SET total_refunds_amount = 0.00;
    END IF;

    SELECT (total_sales_amount - total_refunds_amount) AS lifetime_earnings;

END //

DROP PROCEDURE IF EXISTS retrieveCompleteUserProfile;

CREATE PROCEDURE retrieveCompleteUserProfile(
    IN input_uuid CHAR(36),
    IN input_email VARCHAR(225)
)

BEGIN

    SELECT
        u.uuid,
        u.email,
        u.first_name,
        u.last_name,
        u.location,
        u.birth_date,
        u.role,
        u.created_at,
        u.updated_at,
        ab.balance
    FROM users u
    LEFT JOIN account_balance ab ON u.uuid = ab.user_id
    WHERE
        (input_uuid IS NOT NULL AND u.uuid = input_uuid)
        OR
        (input_email IS NOT NULL AND u.email = input_email);

end //

DELIMITER ;