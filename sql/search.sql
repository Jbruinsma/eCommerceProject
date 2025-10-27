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
            ) AS sizes
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
            ) AS sizes
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
            JSON_OBJECT('size_id', s.size_id, 'size_value', s.size_value, 'highest_bid', JSON_OBJECT('amount', bd.bid_amount, 'bid_id', bd.bid_id), 'lowest_asking_price', JSON_OBJECT('price', l.price, 'listing_id', l.listing_id))
        ) AS sizes
    FROM
        products p
        JOIN brands b ON p.brand_id = b.brand_id
            LEFT JOIN products_sizes ps
                ON
                    p.product_id = ps.product_id
            LEFT JOIN sizes s
                ON
                    ps.size_id = s.size_id
            LEFT JOIN bids bd
                ON
                    p.product_id = bd.product_id
                        AND
                    bd.bid_status = 'active'
                        AND
                    bd.product_size_id = s.size_id
            LEFT JOIN listings l
                ON
                    p.product_id = l.product_id
                        AND
                    l.status = 'active'
                        AND
                    l.size_id = s.size_id
    WHERE
        p.product_id = input_product_id
    GROUP BY
        p.product_id, b.brand_name;

end //

DELIMITER ;