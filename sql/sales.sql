USE ecommerce;

DELIMITER //

DROP PROCEDURE IF EXISTS connectListingToBid;

CREATE PROCEDURE connectListingToBid(
    IN input_product_id INT UNSIGNED,
    IN input_seller_id CHAR(36),
    IN input_bid_id CHAR(36),
    IN input_listing_id INT UNSIGNED,
    IN input_sale_price DECIMAL(10,2),
    IN input_size_id INT UNSIGNED,
    IN input_seller_fee_structure_id INT UNSIGNED
)
BEGIN
    DECLARE calculated_buyer_id CHAR(36);
    DECLARE buyer_fee_id INT UNSIGNED;
    DECLARE buyer_fee_percentage DECIMAL(10, 4);
    DECLARE calculated_buyer_transaction_fee DECIMAL(10,2);
    DECLARE calculated_buyer_final_price DECIMAL(10,2);
    DECLARE calculated_seller_transaction_fee_percentage DECIMAL(10,2);
    DECLARE calculated_seller_transaction_fee DECIMAL(10,2);
    DECLARE calculated_seller_final_payout DECIMAL(10,2);
    DECLARE new_order_id CHAR(36);

    SELECT fee_structure_id INTO buyer_fee_id FROM bids WHERE bid_id = input_bid_id;
    SELECT fee.buyer_fee_percentage INTO buyer_fee_percentage FROM fee_structures AS fee WHERE fee.id = buyer_fee_id;

    SET calculated_buyer_transaction_fee = ROUND((input_sale_price * buyer_fee_percentage), 2);
    SET calculated_buyer_final_price = ROUND((input_sale_price + calculated_buyer_transaction_fee), 2);
    SET calculated_seller_transaction_fee_percentage = (SELECT seller_fee_percentage FROM fee_structures WHERE id = input_seller_fee_structure_id);
    SET calculated_seller_transaction_fee = ROUND((input_sale_price * calculated_seller_transaction_fee_percentage), 2);
    SET calculated_seller_final_payout = ROUND((input_sale_price - calculated_seller_transaction_fee), 2);
    SET new_order_id = UUID();

    IF (input_listing_id IS NOT NULL) THEN
        UPDATE listings SET status = 'pending' WHERE listing_id = input_listing_id;
    END IF;

    SELECT user_id INTO calculated_buyer_id FROM bids WHERE bid_id = input_bid_id;
    UPDATE bids SET bid_status = 'accepted' WHERE bid_id = input_bid_id;

    INSERT INTO orders (
        order_id, buyer_id, seller_id, product_id, size_id, sale_price,
        buyer_transaction_fee, buyer_fee_structure_id, buyer_final_price,
        seller_transaction_fee, seller_fee_structure_id, seller_final_payout,
        order_status, created_at, updated_at
    ) VALUES (
        new_order_id, calculated_buyer_id, input_seller_id, input_product_id,
        input_size_id, input_sale_price, calculated_buyer_transaction_fee,
        buyer_fee_id, calculated_buyer_final_price, calculated_seller_transaction_fee,
        input_seller_fee_structure_id, calculated_seller_final_payout,
        'pending', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    );

    UPDATE addresses
    SET order_id = new_order_id
    WHERE user_id = calculated_buyer_id AND order_id = input_bid_id;

    SELECT * FROM orders WHERE order_id = new_order_id;

    COMMIT;

END //

DELIMITER ;