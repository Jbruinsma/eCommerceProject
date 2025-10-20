USE ecommerce;

DELIMITER //

DROP PROCEDURE IF EXISTS createBid;

CREATE PROCEDURE createBid(
    IN input_user_id CHAR(36),
    IN input_product_id INT UNSIGNED,
    IN input_product_size INT UNSIGNED,
    IN input_product_condition ENUM('new', 'used', 'worn'),
    IN input_bid_amount DECIMAL(10,2),
    IN input_transaction_fee DECIMAL(10,2),
    IN input_total_amount DECIMAL(10,2)
)

BEGIN

    DECLARE new_bid_id CHAR(36);
    SET new_bid_id = UUID();

    INSERT INTO bids(
                    bid_id,
                    user_id,
                    product_id,
                    product_size_id,
                    product_condition,
                    bid_amount,
                    transaction_fee,
                    total_bid_amount,
                    bid_status,
                    created_at,
                    updated_at
        )

        VALUES (
                new_bid_id,
                input_user_id,
                input_product_id,
                (
                SELECT size_id
                FROM sizes
                WHERE size_value = input_product_size
                LIMIT 1
                ),
                input_product_condition,
                input_bid_amount,
                input_transaction_fee,
                input_total_amount,
                'active',
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP
               );

    SELECT *
    FROM bids
    WHERE bid_id = new_bid_id;

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
        b.total_bid_amount,
        b.bid_status,
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
            )
                AS highest_bids
                ON
                    b.product_size_id = highest_bids.product_size_id
                        AND
                    b.bid_amount = highest_bids.max_bid
            JOIN
            sizes s ON b.product_size_id = s.size_id
    ORDER BY
        s.size_id;

END //

DELIMITER ;