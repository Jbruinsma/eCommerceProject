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
    LIMIT 25;

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
        sales_month;

end //

DELIMITER ;