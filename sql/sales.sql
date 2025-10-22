USE ecommerce;

DELIMITER //

CREATE PROCEDURE connectListingToBid(
    IN input_product_id INT UNSIGNED,
    IN input_seller_id CHAR(36),
    IN input_bid_id CHAR(36),
    IN input_listing_id INT UNSIGNED,
    IN input_sale_price DECIMAL(10,2)
)

BEGIN

    DECLARE buyer_id CHAR(36);

    IF (input_listing_id IS NOT NULL) THEN

        UPDATE listings
        SET status = 'pending'
        WHERE listing_id = input_listing_id;

    end if;

    SELECT user_id INTO buyer_id
    FROM bids
    WHERE bid_id = input_bid_id;

    UPDATE bids
    SET bid_status = 'accepted'
    WHERE bid_id = input_bid_id;






#     Create new order for buyer & seller

#     Record Transactions

end //

DELIMITER ;