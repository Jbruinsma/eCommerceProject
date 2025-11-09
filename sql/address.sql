USE ecommerce;

DELIMITER //

DROP PROCEDURE IF EXISTS addAddress;

CREATE PROCEDURE addAddress(
    IN input_user_id CHAR(36),
    IN input_name VARCHAR(100),
    IN input_address_line1 VARCHAR(255),
    IN input_address_line2 VARCHAR(255),
    IN input_city VARCHAR(100),
    IN input_state VARCHAR(100),
    IN input_zip_code VARCHAR(20),
    IN input_country VARCHAR(100),
)

BEGIN

    INSERT INTO addresses(
                          user_id,
                          purpose,
                          name,
                          address_line_1,
                          address_line_2,
                          city,
                          state,
                          zip_code,
                          country

    )
    VALUES (
            input_user_id,
            'both',
            input_name,
            input_address_line1,
            input_address_line2,
            input_city,
            input_state,
            input_zip_code,
            input_country
    );

    SELECT *
    FROM addresses
    WHERE user_id = input_user_id;

end //

DELIMITER ;