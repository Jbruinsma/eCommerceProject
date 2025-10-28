USE ecommerce;

DROP PROCEDURE IF EXISTS searchProducts;
DELIMITER //

CREATE PROCEDURE searchProducts(
    IN input_search_term VARCHAR(255),
    IN input_category ENUM('sneakers', 'apparel', 'accessories', 'other'),
    IN input_brand_id INT UNSIGNED,
    IN result_limit INT UNSIGNED
)
BEGIN
    -- Declare variables for parsing a brand prefix from the search term
    DECLARE prefix_brand_id INT UNSIGNED DEFAULT NULL;
    DECLARE product_search_term VARCHAR(255);
    SET @search_pattern = CONCAT('%', COALESCE(input_search_term, ''), '%');

    -- This block handles the special case from `generalProductSearch`
    -- It checks if the search term starts with a known brand name (e.g., "Adidas Samba")
    IF input_search_term IS NOT NULL AND input_brand_id IS NULL AND input_category IS NULL THEN
        SELECT
            b.brand_id,
            -- Extracts the product name that comes after the brand
            TRIM(SUBSTRING(input_search_term, LENGTH(b.brand_name) + 2))
        INTO
            prefix_brand_id,
            product_search_term
        FROM
            brands b
        WHERE
            -- Find a brand name that matches the start of the search term
            input_search_term LIKE CONCAT(b.brand_name, ' %')
        ORDER BY
            -- Prioritize longer brand names in case of overlaps (e.g., "New Balance" vs "New")
            LENGTH(b.brand_name) DESC
        LIMIT result_limit;
    END IF;

    -- If a brand was successfully parsed from the search term, run a targeted query
    IF prefix_brand_id IS NOT NULL THEN
        SET @product_pattern = CONCAT('%', product_search_term, '%');
        SELECT
            p.product_id,
            p.name,
            p.brand_id,
            b.brand_name,
            p.image_url,
            p.retail_price,
            p.release_date,
            p.product_type,
            JSON_ARRAYAGG(
                JSON_OBJECT('size_id', s.size_id, 'size_value', s.size_value)
            ) AS sizes,
            (SELECT MIN(price) FROM listings l WHERE l.product_id = p.product_id AND l.status = 'active') AS lowest_asking_price
        FROM
            products p
            JOIN brands b ON p.brand_id = b.brand_id
            LEFT JOIN products_sizes ps ON p.product_id = ps.product_id
            LEFT JOIN sizes s ON ps.size_id = s.size_id
        WHERE
            p.brand_id = prefix_brand_id
            AND p.name LIKE @product_pattern
        GROUP BY
            p.product_id, b.brand_name
        ORDER BY
            p.release_date DESC
        LIMIT result_limit;

    -- Otherwise, run the general-purpose query that handles all other cases
    ELSE
        SELECT
            p.product_id,
            p.name,
            p.brand_id,
            b.brand_name,
            p.image_url,
            p.retail_price,
            p.release_date,
            p.product_type,
            JSON_ARRAYAGG(
                JSON_OBJECT('size_id', s.size_id, 'size_value', s.size_value)
            ) AS sizes,
            (SELECT MIN(price) FROM listings l WHERE l.product_id = p.product_id AND l.status = 'active') AS lowest_asking_price
        FROM
            products p
            JOIN brands b ON p.brand_id = b.brand_id
            LEFT JOIN products_sizes ps ON p.product_id = ps.product_id
            LEFT JOIN sizes s ON ps.size_id = s.size_id
        WHERE
            -- Filter by category if provided, otherwise ignore
            (input_category IS NULL OR p.product_type = input_category)
            -- Filter by brand_id if provided, otherwise ignore
            AND (input_brand_id IS NULL OR p.brand_id = input_brand_id)
            -- Filter by search term (product or brand name) if provided, otherwise ignore
            AND (input_search_term IS NULL OR p.name LIKE @search_pattern OR b.brand_name LIKE @search_pattern)
        GROUP BY
            p.product_id, b.brand_name
        ORDER BY
            p.release_date DESC
        LIMIT result_limit;
    END IF;

END //

DROP PROCEDURE IF EXISTS searchProductByProductId;

CREATE PROCEDURE searchProductByProductId(
    IN input_product_id INT UNSIGNED
)
BEGIN
    -- CTE to find the highest active bid for each product, size, and condition.
    -- We use ROW_NUMBER() to handle cases where multiple bids have the same highest amount.
    WITH HighestBids AS (
        SELECT
            b.product_id,
            b.product_size_id,
            b.product_condition,
            b.bid_amount,
            b.bid_id,
            ROW_NUMBER() OVER(PARTITION BY b.product_id, b.product_size_id, b.product_condition ORDER BY b.bid_amount DESC) as rn
        FROM bids b
        WHERE b.bid_status = 'active'
    ),
    -- CTE to find the lowest active listing for each product, size, and condition.
    LowestAsks AS (
        SELECT
            l.product_id,
            l.size_id,
            l.item_condition,
            l.price,
            l.listing_id,
            ROW_NUMBER() OVER(PARTITION BY l.product_id, l.size_id, l.item_condition ORDER BY l.price ASC) as rn
        FROM listings l
        WHERE l.status = 'active'
    )
    -- Main query to select product details and construct the nested JSON for sizes.
    SELECT
        p.product_id,
        p.name,
        p.brand_id,
        b.brand_name,
        p.image_url,
        p.retail_price,
        p.release_date,
        p.product_type,
        (
            -- This subquery constructs the JSON array for all available sizes.
            SELECT
                JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'size_id', s.size_id,
                        'size_value', s.size_value,
                        'highest_bid', JSON_OBJECT(
                            'new',  JSON_OBJECT('amount', hb_new.bid_amount, 'bid_id', hb_new.bid_id),
                            'used', JSON_OBJECT('amount', hb_used.bid_amount, 'bid_id', hb_used.bid_id),
                            'worn', JSON_OBJECT('amount', hb_worn.bid_amount, 'bid_id', hb_worn.bid_id)
                        ),
                        'lowest_ask', JSON_OBJECT(
                            'new', JSON_OBJECT('price', la_new.price, 'listing_id', la_new.listing_id),
                            'used', JSON_OBJECT('price', la_used.price, 'listing_id', la_used.listing_id),
                            'worn', JSON_OBJECT('price', la_worn.price, 'listing_id', la_worn.listing_id)
                        )
                    )
                )
            FROM products_sizes ps
            JOIN sizes s ON ps.size_id = s.size_id
            -- Join against HighestBids CTE for each condition
            LEFT JOIN HighestBids hb_new ON ps.product_id = hb_new.product_id AND s.size_id = hb_new.product_size_id AND hb_new.product_condition = 'new' AND hb_new.rn = 1
            LEFT JOIN HighestBids hb_used ON ps.product_id = hb_used.product_id AND s.size_id = hb_used.product_size_id AND hb_used.product_condition = 'used' AND hb_used.rn = 1
            LEFT JOIN HighestBids hb_worn ON ps.product_id = hb_worn.product_id AND s.size_id = hb_worn.product_size_id AND hb_worn.product_condition = 'worn' AND hb_worn.rn = 1
            -- Join against LowestAsks CTE for each condition
            LEFT JOIN LowestAsks la_new ON ps.product_id = la_new.product_id AND s.size_id = la_new.size_id AND la_new.item_condition = 'new' AND la_new.rn = 1
            LEFT JOIN LowestAsks la_used ON ps.product_id = la_used.product_id AND s.size_id = la_used.size_id AND la_used.item_condition = 'used' AND la_used.rn = 1
            LEFT JOIN LowestAsks la_worn ON ps.product_id = la_worn.product_id AND s.size_id = la_worn.size_id AND la_worn.item_condition = 'worn' AND la_worn.rn = 1
            WHERE ps.product_id = p.product_id -- Correlate with the outer query
        ) AS sizes,
        (SELECT MIN(price) FROM listings l WHERE l.product_id = p.product_id AND l.status = 'active') AS lowest_asking_price
    FROM
        products p
    JOIN brands b ON p.brand_id = b.brand_id
    WHERE
        p.product_id = input_product_id
    GROUP BY
        p.product_id, b.brand_name;

END //

DELIMITER ;