USE ecommerce;

DROP PROCEDURE IF EXISTS retrieveProductById;

DELIMITER //

CREATE PROCEDURE retrieveProductById(
    IN input_product_id INT UNSIGNED
)
BEGIN

    SELECT brand_name, name, sku, colorway, retail_price, release_date, image_url
    FROM products p
    JOIN brands ON p.brand_id = brands.brand_id
    WHERE product_id = input_product_id;

END//

DROP PROCEDURE IF EXISTS retrieveProductPreviewById;

CREATE PROCEDURE retrieveProductPreviewById(
    IN input_product_id INT UNSIGNED
)
BEGIN

    CALL retrieveProductById(input_product_id);

END//

DROP PROCEDURE IF EXISTS retrieveProductByBrandId;

CREATE PROCEDURE retrieveProductByBrandId(
    IN input_brand_id INT UNSIGNED
)

BEGIN

    SELECT product_id, name, sku, colorway, retail_price, release_date, image_url
    FROM products
    WHERE brand_id = input_brand_id
    ORDER BY release_date DESC;

END //

DROP PROCEDURE IF EXISTS retrieveAllProductSizes;

CREATE PROCEDURE retrieveAllProductSizes(
    IN input_product_id INT UNSIGNED
)
BEGIN
    SELECT s.size_id, s.size_value
    FROM products_sizes ps
    JOIN sizes s ON ps.size_id = s.size_id
    WHERE ps.product_id = input_product_id
    ORDER BY s.size_value;
end //

DROP PROCEDURE IF EXISTS productSearch;

CREATE PROCEDURE productSearch(
    IN input_brand_id INT UNSIGNED,
    IN input_brand_name VARCHAR(255),
    IN input_product_name VARCHAR(255),
    IN result_limit INT UNSIGNED
)
BEGIN
    SET @product_pattern = CONCAT('%', input_product_name, '%');
    SET @brand_pattern = CONCAT('%', input_brand_name, '%');

    IF input_brand_id IS NOT NULL THEN
        SELECT
            p.product_id,
            p.name,
            p.brand_id,
            (SELECT brand_name
             FROM brands
             WHERE brand_id = p.brand_id) AS brand_name,
            p.image_url,
            p.retail_price,
            JSON_ARRAYAGG(
                JSON_OBJECT('size_id', s.size_id, 'size_value', s.size_value)
            ) AS sizes
        FROM
            products p
        LEFT JOIN products_sizes ps ON p.product_id = ps.product_id
        LEFT JOIN sizes s ON ps.size_id = s.size_id
        WHERE
            p.name LIKE @product_pattern
            AND p.brand_id = input_brand_id
        GROUP BY
            p.product_id
        LIMIT result_limit;

    ELSEIF input_brand_name IS NOT NULL AND input_brand_name != '' THEN
        SELECT
            p.product_id,
            p.name,
            p.brand_id,
            (SELECT brand_name
             FROM brands
             WHERE brand_id = p.brand_id) AS brand_name,
            p.image_url,
            p.retail_price,
            JSON_ARRAYAGG(
                JSON_OBJECT('size_id', s.size_id, 'size_value', s.size_value)
            ) AS sizes
        FROM
            products p
        INNER JOIN
            brands b ON p.brand_id = b.brand_id
        LEFT JOIN products_sizes ps ON p.product_id = ps.product_id
        LEFT JOIN sizes s ON ps.size_id = s.size_id
        WHERE
            p.name LIKE @product_pattern
            AND b.brand_name LIKE @brand_pattern
        GROUP BY
            p.product_id
        LIMIT result_limit;

    ELSE
        SELECT
            p.product_id,
            p.name,
            p.brand_id,
            (SELECT brand_name
             FROM brands
             WHERE brand_id = p.brand_id)  AS brand_name,
            p.image_url,
            p.retail_price,
            JSON_ARRAYAGG(
                JSON_OBJECT('size_id', s.size_id, 'size_value', s.size_value)
            ) AS sizes
        FROM
            products p
        LEFT JOIN products_sizes ps ON p.product_id = ps.product_id
        LEFT JOIN sizes s ON ps.size_id = s.size_id
        WHERE
            p.name LIKE @product_pattern
        GROUP BY
            p.product_id
        LIMIT result_limit;

    END IF;

END //

DROP PROCEDURE IF EXISTS generalProductSearch;

CREATE PROCEDURE generalProductSearch(
    IN input_brand_id INT UNSIGNED,
    IN input_brand_name VARCHAR(255),
    IN input_product_name VARCHAR(255),
    IN result_limit INT UNSIGNED
)
BEGIN
    -- Create pattern variables for LIKE clauses.
    -- Using COALESCE ensures that if a NULL is passed, it becomes '%%', matching everything
    -- for that parameter, which simplifies the WHERE clauses.
    SET @product_pattern = CONCAT('%', COALESCE(input_product_name, ''), '%');
    SET @brand_pattern = CONCAT('%', COALESCE(input_brand_name, ''), '%');

    -- This handles the case where the user provides a specific brand ID.
    -- This is the most specific search and should be prioritized.
    IF input_brand_id IS NOT NULL THEN
        SELECT
            p.product_id,
            p.name,
            p.brand_id,
            b.brand_name, -- Fetched via JOIN for better performance
            p.image_url,
            p.retail_price,
            JSON_ARRAYAGG(
                JSON_OBJECT('size_id', s.size_id, 'size_value', s.size_value)
            ) AS sizes
        FROM
            products p
        -- Always JOIN with brands to get the name efficiently.
        JOIN brands b ON p.brand_id = b.brand_id
        LEFT JOIN products_sizes ps ON p.product_id = ps.product_id
        LEFT JOIN sizes s ON ps.size_id = s.size_id
        WHERE
            -- The logic remains the same: find products that match the name OR the brand ID.
            p.name LIKE @product_pattern OR p.brand_id = input_brand_id
        GROUP BY
            p.product_id, b.brand_name -- Standard SQL practice to group by all non-aggregated columns.
        LIMIT result_limit;

    -- This handles a text search that could be either a product or brand name.
    -- The NULLIF function treats an empty string as NULL, so this block won't run for empty searches.
    ELSEIF NULLIF(input_brand_name, '') IS NOT NULL THEN
        BEGIN
            DECLARE prefix_brand_id INT UNSIGNED DEFAULT NULL;
            DECLARE product_search_term VARCHAR(255);

            -- Check if the search query starts with a full brand name followed by a space.
            -- We order by length of brand_name descending to catch multi-word brands like "New Balance" before "New".
            SELECT
                b.brand_id,
                -- Extract the rest of the string after the brand name and the space.
                TRIM(SUBSTRING(input_brand_name, LENGTH(b.brand_name) + 2))
            INTO
                prefix_brand_id,
                product_search_term
            FROM
                brands b
            WHERE
                -- Check if input starts with a brand name and is followed by more characters.
                input_brand_name LIKE CONCAT(b.brand_name, ' %')
            ORDER BY
                LENGTH(b.brand_name) DESC
            LIMIT 1;

            -- If we found a brand prefix, the user is likely searching for a specific product within that brand.
            IF prefix_brand_id IS NOT NULL THEN
                SET @product_pattern = CONCAT('%', product_search_term, '%');
                SELECT
                    p.product_id,
                    p.name,
                    p.brand_id,
                    b.brand_name,
                    p.image_url,
                    p.retail_price,
                    JSON_ARRAYAGG(
                        JSON_OBJECT('size_id', s.size_id, 'size_value', s.size_value)
                    ) AS sizes
                FROM
                    products p
                JOIN brands b ON p.brand_id = b.brand_id
                LEFT JOIN products_sizes ps ON p.product_id = ps.product_id
                LEFT JOIN sizes s ON ps.size_id = s.size_id
                WHERE
                    -- Search only for products under the identified brand that match the rest of the search term.
                    p.brand_id = prefix_brand_id
                    AND p.name LIKE @product_pattern
                GROUP BY
                    p.product_id, b.brand_name
                LIMIT result_limit;

            ELSE
                -- This is the original logic for when the search term is not prefixed with a specific brand.
                -- It performs a general search across both product names and brand names.
                SELECT
                    p.product_id,
                    p.name,
                    p.brand_id,
                    b.brand_name, -- Fetched via JOIN
                    p.image_url,
                    p.retail_price,
                    JSON_ARRAYAGG(
                        JSON_OBJECT('size_id', s.size_id, 'size_value', s.size_value)
                    ) AS sizes
                FROM
                    products p
                JOIN brands b ON p.brand_id = b.brand_id
                LEFT JOIN products_sizes ps ON p.product_id = ps.product_id
                LEFT JOIN sizes s ON ps.size_id = s.size_id
                WHERE
                    -- Search for the input text in either the product name or the brand name.
                    p.name LIKE @product_pattern OR b.brand_name LIKE @brand_pattern
                GROUP BY
                    p.product_id, b.brand_name
                LIMIT result_limit;
            END IF;
        END;

    -- This is the fallback for when only a product name is provided.
    ELSE
        SELECT
            p.product_id,
            p.name,
            p.brand_id,
            b.brand_name, -- Still joining is better for consistency and performance.
            p.image_url,
            p.retail_price,
            JSON_ARRAYAGG(
                JSON_OBJECT('size_id', s.size_id, 'size_value', s.size_value)
            ) AS sizes
        FROM
            products p
        JOIN brands b ON p.brand_id = b.brand_id
        LEFT JOIN products_sizes ps ON p.product_id = ps.product_id
        LEFT JOIN sizes s ON ps.size_id = s.size_id
        WHERE
            p.name LIKE @product_pattern
        GROUP BY
            p.product_id, b.brand_name
        LIMIT result_limit;

    END IF;

END //

DELIMITER ;