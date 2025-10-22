USE ecommerce;

DELIMITER //

DROP PROCEDURE IF EXISTS createNewFeeStructure;

CREATE PROCEDURE createNewFeeStructure(
    IN input_seller_fee_percentage DECIMAL(10, 4),
    IN input_buyer_fee_percentage DECIMAL(10, 4),
    IN input_is_active TINYINT(1)
)

BEGIN

    INSERT INTO fee_structures(
        seller_fee_percentage,
        buyer_fee_percentage,
        is_active
        )
    VALUES (
        input_seller_fee_percentage,
        input_buyer_fee_percentage,
        input_is_active
           );

    SELECT id
    FROM fee_structures
    WHERE id = LAST_INSERT_ID();

end //

DROP PROCEDURE IF EXISTS getActiveFeeStructure;

CREATE PROCEDURE getActiveFeeStructure()
BEGIN

    SELECT *
    FROM fee_structures
    WHERE is_active = 1
    ORDER BY created_at DESC
    LIMIT 1;

end //

DROP PROCEDURE IF EXISTS setNewActiveFeeStructure;

CREATE PROCEDURE setNewActiveFeeStructure(
    IN input_seller_fee_percentage DECIMAL(10, 4),
    IN input_buyer_fee_percentage DECIMAL(10, 4)
)

BEGIN

    UPDATE fee_structures
    SET is_active = 0
    WHERE is_active = 1;

    IF EXISTS(

    SELECT *
    FROM fee_structures
    WHERE
        seller_fee_percentage = input_seller_fee_percentage
      AND
        buyer_fee_percentage = input_buyer_fee_percentage

    ) THEN

        UPDATE fee_structures
        SET is_active = 1
        WHERE
            seller_fee_percentage = input_seller_fee_percentage
        AND
            buyer_fee_percentage = input_buyer_fee_percentage;

    ELSE


        INSERT INTO fee_structures(seller_fee_percentage, buyer_fee_percentage, is_active)
        VALUES (input_seller_fee_percentage, input_buyer_fee_percentage, 1);

    end if;

end //

DROP PROCEDURE IF EXISTS retrieveActiveSellerFeePercentage;

CREATE PROCEDURE retrieveActiveSellerFeePercentage()

BEGIN

    SELECT id, seller_fee_percentage
    FROM fee_structures
    WHERE is_active = 1
    ORDER BY created_at DESC
    LIMIT 1;

END //

DROP PROCEDURE IF EXISTS retrieveActiveBuyerFeePercentage;

CREATE PROCEDURE retrieveActiveBuyerFeePercentage()

BEGIN

    SELECT id, buyer_fee_percentage
    FROM fee_structures
    WHERE is_active = 1
    ORDER BY created_at DESC
    LIMIT 1;

END //

DELIMITER ;