USE ecommerce;

DELIMITER //

DROP PROCEDURE IF EXISTS calculateTotalRevenue;

CREATE PROCEDURE calculateTotalRevenue()

BEGIN

    SELECT
        DATE_FORMAT(created_at, '%Y-%m') AS revenue_month,
        SUM(buyer_transaction_fee + seller_transaction_fee) AS total_revenue
    FROM orders
    GROUP BY
        revenue_month
    ORDER BY
        revenue_month;

end //

DROP PROCEDURE IF EXISTS retrieveTopSellingProducts;

CREATE PROCEDURE retrieveTopSellingProducts()

BEGIN

    SELECT
    COUNT(o.product_id) AS total_sales,
    p.name,
    s.size_value,
    o.product_condition,
    p.image_url
FROM
    orders o
JOIN
    ecommerce.sizes s ON o.size_id = s.size_id
JOIN
    ecommerce.products p ON o.product_id = p.product_id
GROUP BY
    p.name, s.size_value, o.product_condition, p.image_url
ORDER BY
    total_sales DESC
    LIMIT 10;

end //

DROP PROCEDURE IF EXISTS retrieveMonthlyTopSellingProducts;

CREATE PROCEDURE retrieveMonthlyTopSellingProducts()

BEGIN

    WITH MonthlyVariantSales AS (
    SELECT
        DATE_FORMAT(o.created_at, '%Y-%m') AS sales_month,
        p.name AS product_name,
        s.size_value,
        o.product_condition,
        p.image_url,
        COUNT(*) AS total_sales
    FROM
        orders o
    JOIN
        products p ON o.product_id = p.product_id
    JOIN
        sizes s ON o.size_id = s.size_id
    GROUP BY
        sales_month,
        p.name,
        s.size_value,
        o.product_condition,
        p.image_url
    ),
        RankedSales AS (
        SELECT
            sales_month,
            product_name,
            size_value,
            product_condition,
            image_url,
            total_sales,
            ROW_NUMBER() OVER(
                PARTITION BY sales_month
                ORDER BY total_sales DESC
                ) AS sales_rank
        FROM
            MonthlyVariantSales
        )
    SELECT
        sales_month,
        product_name,
        size_value,
        product_condition,
        image_url,
        total_sales
    FROM
        RankedSales
    WHERE
        sales_rank = 1
    ORDER BY
        sales_month
    LIMIT 1;

end //

DROP PROCEDURE IF EXISTS retrieveSalesByCategory;

CREATE PROCEDURE retrieveSalesByCategory()

BEGIN

    SELECT
        COUNT(o.order_id) AS total_orders,
        p.product_type
    FROM
        orders o
            JOIN
            products p ON o.product_id = p.product_id
    GROUP BY
        p.product_type;

end //

DROP PROCEDURE IF EXISTS calculateCustomerBreakdown;

CREATE PROCEDURE calculateCustomerBreakdown()

BEGIN

    WITH BuyerOrderCounts AS (
    SELECT
        COUNT(o.order_id) AS total_orders,
        o.buyer_id
    FROM orders o
    GROUP BY buyer_id
    )
    SELECT
        COUNT(o.order_id) AS total_orders,
        IF(boc.total_orders = 1, 'New_Buyer', 'Returning_Buyer') AS buyer_type
    FROM orders o
        JOIN BuyerOrderCounts boc ON o.buyer_id = boc.buyer_id
    GROUP BY buyer_type;

end //

DROP PROCEDURE IF EXISTS retrieveAverageOrderValue;

CREATE PROCEDURE retrieveAverageOrderValue()

BEGIN

    SELECT ROUND(AVG(buyer_final_price), 2) AS average_completed_order_value
    FROM orders
    WHERE order_status = 'completed';

end //

DROP PROCEDURE IF EXISTS retrieveTotalOrders;

CREATE PROCEDURE retrieveTotalOrders()

BEGIN

    SELECT COUNT(*) AS total_orders
    FROM orders;

end //

DROP PROCEDURE IF EXISTS retrieveSaleHistory;

CREATE PROCEDURE retrieveSaleHistory(
    IN input_product_id INT UNSIGNED,
    IN input_product_size_id INT UNSIGNED,
    IN input_product_condition VARCHAR(50),
    IN input_result_limit INT UNSIGNED
)

BEGIN

    DECLARE max_rows BIGINT UNSIGNED;
    SET max_rows = IFNULL(input_result_limit, 18446744073709551615);

    SELECT
        sale_price,
        DATE_FORMAT(created_at, '%Y-%m-%d') AS order_date
    FROM
        orders
    WHERE
        product_id = input_product_id
      AND
        size_id = input_product_size_id
      AND
        product_condition = input_product_condition
      AND
        order_status = 'completed'
    ORDER BY
        created_at DESC
    LIMIT max_rows;

END //

DROP PROCEDURE IF EXISTS calculateProductValue;

CREATE PROCEDURE calculateProductValue(
    IN input_product_id INT UNSIGNED,
    IN input_product_size_id INT UNSIGNED,
    IN input_product_condition VARCHAR(50)
)

BEGIN

    CALL retrieveSaleHistory(
        input_product_id,
        input_product_size_id,
        input_product_condition,
        1
    );

END //

DELIMITER ;