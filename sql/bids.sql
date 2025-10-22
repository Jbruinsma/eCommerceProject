USE ecommerce;

DELIMITER //

DROP PROCEDURE IF EXISTS createBid;

CREATE PROCEDURE createBid(
    IN input_user_id CHAR(36),
    IN input_product_id INT UNSIGNED,
    IN input_product_size VARCHAR(50),
    IN input_product_condition ENUM('new', 'used', 'worn'),
    IN input_bid_amount DECIMAL(10,2),
    IN input_fee_structure_id INT,
    IN input_payment_origin VARCHAR(100)
)

BEGIN

    DECLARE new_bid_id CHAR(36);
    DECLARE bid_transaction_fee DECIMAL(10,2);
    DECLARE total_payment DECIMAL(10,2);

    SET new_bid_id = UUID();
    SET bid_transaction_fee = (input_bid_amount * (SELECT buyer_fee_percentage FROM fee_structures WHERE id = input_fee_structure_id));
    SET total_payment = input_bid_amount + bid_transaction_fee;

    INSERT INTO bids(
                    bid_id,
                    user_id,
                    product_id,
                    product_size_id,
                    product_condition,
                    bid_amount,
                    transaction_fee,
                    fee_structure_id,
                    total_bid_amount,
                    bid_status,
                    payment_origin,
                    created_at,
                    updated_at
        )

        VALUES (
                new_bid_id,
                input_user_id,
                input_product_id,
                (SELECT size_id FROM sizes WHERE size_id IN (SELECT size_id FROM products_sizes WHERE product_id = input_product_id) AND size_value = input_product_size),
                input_product_condition,
                input_bid_amount,
                bid_transaction_fee,
                input_fee_structure_id,
                total_payment,
                'active',
                input_payment_origin,
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP
               );

    SELECT *
    FROM bids
    WHERE bid_id = new_bid_id;

end //

DROP PROCEDURE IF EXISTS updateBid;

CREATE PROCEDURE updateBid(
    IN input_bid_id CHAR(36),
    IN input_bid_amount DECIMAL(10,2),
    IN input_fee_structure_id INT
)

BEGIN

    DECLARE new_transaction_fee DECIMAL(10,2);
    DECLARE new_total_bid_amount DECIMAL(10,2);

    SET new_transaction_fee = (input_bid_amount * (SELECT buyer_fee_percentage FROM fee_structures WHERE id = input_fee_structure_id));
    SET new_total_bid_amount = input_bid_amount + new_transaction_fee;

    UPDATE bids
    SET
        bid_amount = input_bid_amount,
        transaction_fee = new_transaction_fee,
        total_bid_amount = new_total_bid_amount,
        fee_structure_id = input_fee_structure_id,
        updated_at = CURRENT_TIMESTAMP
    WHERE bid_id = input_bid_id;

    SELECT *
    FROM bids
    WHERE bid_id = input_bid_id;

end //

DROP PROCEDURE IF EXISTS deleteBid;

CREATE PROCEDURE deleteBid(
    IN input_bid_id CHAR(36)
)

BEGIN

    DELETE FROM bids
    WHERE bid_id = input_bid_id;

end //

DROP PROCEDURE IF EXISTS getBidsByProductId;

CREATE PROCEDURE getBidsByProductId(
    IN input_product_id INT UNSIGNED
)
BEGIN

    SELECT
        b.bid_id,
        b.user_id,
        b.product_id,
        JSON_OBJECT(
            'size_id', s.size_id,
            'size_value', s.size_value
        ) AS listing_size,
        b.product_condition,
        b.bid_amount,
        b.transaction_fee,
        b.fee_structure_id,
        b.total_bid_amount,
        b.bid_status,
        b.payment_origin,
        b.created_at,
        b.updated_at
    FROM
        bids b
    INNER JOIN (
        SELECT
            product_size_id,
            MAX(bid_amount) AS max_bid
        FROM
            bids
        WHERE
            product_id = input_product_id AND bid_status = 'active'
        GROUP BY
            product_size_id
    ) AS highest_bids
        ON b.product_size_id = highest_bids.product_size_id
        AND b.bid_amount = highest_bids.max_bid
    JOIN
        sizes s ON b.product_size_id = s.size_id
    WHERE
        b.product_id = input_product_id AND b.bid_status = 'active'
    ORDER BY
        s.size_id;

END //

DROP PROCEDURE IF EXISTS retrieveBidsByUserId;

CREATE PROCEDURE retrieveBidsByUserId(
    IN input_user_id CHAR(36)
)

BEGIN

    SELECT *
    FROM bids
    JOIN sizes ON bids.product_size_id = sizes.size_id
    JOIN products ON bids.product_id = products.product_id
    WHERE user_id = input_user_id;


end //

DROP PROCEDURE IF EXISTS retrieveActiveBidsByUserId;

CREATE PROCEDURE retrieveActiveBidsByUserId(
    IN input_user_id CHAR(36)
)

BEGIN

    SELECT *
    FROM bids
    JOIN sizes ON bids.product_size_id = sizes.size_id
    JOIN products ON bids.product_id = products.product_id
    WHERE user_id = input_user_id AND bid_status = 'active';

end //

DROP PROCEDURE IF EXISTS retrieveBidById;

CREATE PROCEDURE retrieveBidById(
    IN input_bid_id CHAR(36)
)

BEGIN

    SELECT *
    FROM bids
    JOIN sizes ON bids.product_size_id = sizes.size_id
    JOIN products ON bids.product_id = products.product_id
    WHERE bid_id = input_bid_id;

end //

DELIMITER ;