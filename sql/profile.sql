USE ecommerce;

DROP PROCEDURE IF EXISTS fetchUserProfileById;

DELIMITER //

CREATE PROCEDURE fetchUserProfileById(
    IN input_uuid CHAR(36)
)
BEGIN

    /*
        Returns a single row with the following keys to match the API response:
         - firstName: user's first_name
         - memberSince: date the user was created (DATE only)
         - location: user's location
         - activeListings: count of user's listings with status = 'active'
         - openOrders: count of orders involving the user (buyer or seller) that are not final

        Assumptions:
         - "open" orders are those NOT in final states: completed, cancelled, refunded
         - portfolioValue is intentionally omitted per request
    */

    SELECT
        u.first_name AS firstName,
        DATE(u.created_at) AS memberSince,
        u.location AS location,
        IFNULL(COUNT(DISTINCT l.listing_id), 0) AS activeListings,
        IFNULL(COUNT(DISTINCT o.order_id), 0) AS openOrders
    FROM users u
    LEFT JOIN listings l
        ON l.user_id = u.uuid
        AND l.status = 'active'
    LEFT JOIN orders o
        ON (o.buyer_id = u.uuid OR o.seller_id = u.uuid)
        AND o.order_status NOT IN ('completed', 'cancelled', 'refunded')
    WHERE u.uuid = input_uuid
    GROUP BY u.uuid, u.first_name, u.created_at, u.location;

END//

DELIMITER ;