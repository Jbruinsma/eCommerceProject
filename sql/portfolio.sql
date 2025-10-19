USE ecommerce;

DELIMITER //

DROP PROCEDURE IF EXISTS estimateProductValue;

CREATE PROCEDURE estimateProductValue(
    IN input_product_id INT UNSIGNED,
    IN input_size_id INT UNSIGNED
)

BEGIN

    SELECT order_id
    FROM orders
    WHERE product_id = input_product_id
    AND size_id = input_size_id
    ORDER BY sale_price DESC
    LIMIT 1;

END //

DROP PROCEDURE IF EXISTS retrieveAllPortfolioItemsByUserId;

CREATE PROCEDURE retrieveAllPortfolioItemsByUserId(
    IN input_user_id CHAR(36)
)

BEGIN

    SELECT
        pi.*,
        p.name AS product_name,
        p.image_url AS product_image_url,
        s.size_value,
        (
            SELECT o.sale_price
            FROM orders o
            WHERE o.product_id = pi.product_id
            AND o.size_id = pi.size_id
            ORDER BY o.sale_price DESC
            LIMIT 1
        ) AS estimated_current_value,
        (
            (
            SELECT o.sale_price
            FROM orders o
            WHERE o.product_id = pi.product_id AND o.size_id = pi.size_id
            ORDER BY o.created_at DESC
            LIMIT 1
            )
                -
            (
                IF(pi.acquisition_date IS NOT NULL, (
                SELECT o.sale_price
                FROM orders o
                WHERE o.product_id = pi.product_id
                  AND o.size_id = pi.size_id
                  AND o.created_at < pi.acquisition_date
                ORDER BY o.created_at DESC
                LIMIT 1), pi.acquisition_price)
                )
            ) AS profit_loss
    FROM
        portfolio_items pi
            JOIN
            products p ON pi.product_id = p.product_id
            JOIN
            sizes s ON pi.size_id = s.size_id
    WHERE
        pi.user_id = input_user_id
    ORDER BY
        pi.acquisition_date DESC;

end //

DROP PROCEDURE IF EXISTS addNewPortfolioItem;

CREATE PROCEDURE addNewPortfolioItem(
    IN input_user_id CHAR(36),
    IN input_product_id INT UNSIGNED,
    IN input_size_id INT UNSIGNED,
    IN input_purchase_date DATE,
    IN input_purchase_price DECIMAL(10,2),
    IN input_item_condition ENUM('new', 'used', 'worn')
)

BEGIN

    DECLARE new_portfolio_item_uuid CHAR(36);
    SET new_portfolio_item_uuid = UUID();

    INSERT INTO portfolio_items(portfolio_item_id,
                                user_id,
                                product_id,
                                size_id,
                                acquisition_date,
                                acquisition_price,
                                item_condition
                               )

    VALUES( new_portfolio_item_uuid,
           input_user_id,
           input_product_id,
           input_size_id,
           input_purchase_date,
           input_purchase_price,
           input_item_condition
          );

    SELECT * FROM portfolio_items
    WHERE portfolio_item_id = new_portfolio_item_uuid;

end //

DELIMITER ;