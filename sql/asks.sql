USE ecommerce;

DELIMITER //

DROP PROCEDURE IF EXISTS retrieveLowestAsksByProductId;

CREATE PROCEDURE retrieveLowestAsksByProductId(
    IN input_product_id INT UNSIGNED
)
BEGIN

    SELECT
        l.listing_id,
        l.user_id,
        l.product_id,
        l.price,
        l.item_condition,
        l.status,
        JSON_OBJECT(
            'size_id', s.size_id,
            'size_value', s.size_value
        ) AS size_details,
        l.created_at,
        l.updated_at
    FROM
        listings l
    INNER JOIN (
        SELECT
            size_id,
            item_condition,
            MIN(price) AS min_price
        FROM
            listings
        WHERE
            product_id = input_product_id AND status = 'active' AND listing_type = 'ask'
        GROUP BY
            size_id, item_condition
    ) AS lowest_asks ON l.size_id = lowest_asks.size_id
                       AND l.item_condition = lowest_asks.item_condition
                       AND l.price = lowest_asks.min_price
            JOIN
            sizes s ON l.size_id = s.size_id
    WHERE l.product_id = input_product_id AND l.status = 'active' AND l.listing_type = 'ask'
    ORDER BY
        s.size_id, l.item_condition;

END //

DELIMITER ;