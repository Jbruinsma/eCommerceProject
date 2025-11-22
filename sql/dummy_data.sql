USE ecommerce;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE fee_structures;
TRUNCATE TABLE account_balance;
TRUNCATE TABLE users;
TRUNCATE TABLE brands;
TRUNCATE TABLE sizes;
TRUNCATE TABLE products;
TRUNCATE TABLE products_sizes;
TRUNCATE TABLE listings;
TRUNCATE TABLE orders;
TRUNCATE TABLE transactions;
TRUNCATE TABLE addresses;
TRUNCATE TABLE portfolio_items;
TRUNCATE TABLE bids;

SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO fee_structures
(id, seller_fee_percentage, buyer_fee_percentage, is_active)
VALUES(1, 0.10, 0.025, true);


DROP PROCEDURE IF EXISTS InsertDummyUsers;

DELIMITER $$

CREATE PROCEDURE InsertDummyUsers()
BEGIN
    DECLARE i INT DEFAULT 0;

    DECLARE v_first_name VARCHAR(100);
    DECLARE v_last_name VARCHAR(100);
    DECLARE v_domain VARCHAR(100);
    DECLARE v_email VARCHAR(225);
    DECLARE v_location VARCHAR(255);
    DECLARE v_birth_date DATE;
    DECLARE v_role ENUM('user', 'admin');
    DECLARE v_created_at DATETIME;

    -- A realistic bcrypt hash for the password '123456'
    DECLARE v_password_hash VARCHAR(255) DEFAULT '$2a$12$w0J/utshaw.IcuHwz.dagGyTLPS.sa';

    WHILE i < 1000 DO
        SET v_first_name = ELT(FLOOR(1 + RAND() * 20),
            'Alex', 'Jamie', 'Chris', 'Taylor', 'Jordan', 'Morgan', 'Casey', 'Riley', 'Jesse', 'Drew',
            'Liam', 'Olivia', 'Noah', 'Emma', 'Oliver', 'Ava', 'Elijah', 'Charlotte', 'William', 'Sophia'
        );
        SET v_last_name = ELT(FLOOR(1 + RAND() * 20),
            'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
            'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin'
        );
        SET v_domain = ELT(FLOOR(1 + RAND() * 5),
            'gmail.com', 'yahoo.com', 'outlook.com', 'example.com', 'icloud.com'
        );
        SET v_email = CONCAT(LOWER(v_first_name), '.', LOWER(v_last_name), i, '@', v_domain);

        SET v_location = ELT(FLOOR(1 + RAND() * 6),
            'New York, NY, USA', 'Los Angeles, CA, USA', 'Chicago, IL, USA', 'London, UK', 'Toronto, ON, CA', 'Sydney, AUS'
        );
        SET v_birth_date = CURDATE() - INTERVAL FLOOR(6570 + RAND() * 11680) DAY;
        IF i < 995 THEN
            SET v_role = 'user';
        ELSE
            SET v_role = 'admin';
        END IF;
        -- This line is already correct and spreads users over 2 years
        SET v_created_at = NOW() - INTERVAL FLOOR(RAND() * 730) DAY - INTERVAL FLOOR(RAND() * 86400) SECOND;
        INSERT INTO users (
            uuid, email, password, first_name, last_name,
            location, birth_date, role, created_at, updated_at
        ) VALUES (
            UUID(),
            v_email,
            v_password_hash,
            v_first_name,
            v_last_name,
            v_location,
            v_birth_date,
            v_role,
            v_created_at,
            v_created_at
        );
        SET i = i + 1;
    END WHILE;

END$$
DELIMITER ;



CALL InsertDummyUsers();

-- Re-populate account_balance for all users, with a starting balance "curve"
INSERT INTO account_balance (user_id, balance)
SELECT
    u.uuid,
    CASE
        -- "Month 0: $0" (Users created in the current month)
        WHEN TIMESTAMPDIFF(MONTH, u.created_at, NOW()) = 0 THEN 0.00

        -- "Month 1: $500" (Users created 1 month ago)
        WHEN TIMESTAMPDIFF(MONTH, u.created_at, NOW()) = 1 THEN 500.00

        -- "At a certain point it becomes random" (Users > 1 month old)
        -- We'll give them a random balance based on their "age"
        ELSE
            -- Start with a base of 500, plus a random amount ($0-$200) for each month they've been active.
            ROUND(500.00 + (TIMESTAMPDIFF(MONTH, u.created_at, NOW()) * RAND() * 200), 2)
    END AS starting_balance
FROM users u;

INSERT INTO brands (brand_id, brand_name, brand_logo_url) VALUES
(1, 'Adidas', '/brand_logos/adidasLogo.png'),
(2, 'ASICS', '/brand_logos/AsicsLogo.png'),
(3, 'Balenciaga', '/brand_logos/BalenciagaLogo.png'),
(4, 'BAPE', '/brand_logos/BapeLogo.webp'),
(5, 'Converse', '/brand_logos/ConverseLogo.png'),
(6, 'Dior', '/brand_logos/DiorLogo.png'),
(7, 'Fear of God', '/brand_logos/FearOfGodLogo.png'),
(8, 'Jordan Brand', '/brand_logos/JordanLogo.png'),
(9, 'Kith', '/brand_logos/KithLogo.png'),
(10, 'Maison Margiela', '/brand_logos/MaisonMargielaLogo.png'),
(11, 'New Balance', '/brand_logos/NewBalanceLogo.png'),
(12, 'Nike', '/brand_logos/NikeLogo.svg'),
(13, 'Off-White', '/brand_logos/OffWhiteLogo.svg'),
(14, 'Palace', '/brand_logos/PalaceLogo.webp'),
(15, 'Puma', '/brand_logos/PumaLogo.svg'),
(16, 'Reebok', '/brand_logos/ReebokLogo.png'),
(17, 'Salomon', '/brand_logos/SalomonLogo.svg'),
(18, 'Stüssy', '/brand_logos/StussyLogo.png'),
(19, 'Supreme', '/brand_logos/SupremeLogo.png'),
(20, 'Vans', '/brand_logos/VansLogo.png');

INSERT INTO sizes (size_id, size_value) VALUES
(11, '9'), (12, '9.5'), (13, '10'), (14, '10.5'), (15, '11'), (16, '11.5'), (17, '12'), (18, '13'), (19, '14'), (20, '15'),
(21, 'XS'), (22, 'S'), (23, 'M'), (24, 'L'), (25, 'XL'), (26, 'XXL');

INSERT INTO Products (brand_id, name, sku, colorway, product_type, retail_price, release_date, image_url) VALUES
-- Nike
(12, 'Nike Air Force 1 ''07 ''Triple White''', 'DD8959-100', 'White/White/White/White', 'Sneakers', 115.00, '2020-12-21', '/products/DD8959-100.avif'),
(12, 'Nike Dunk Low ''Panda'' (Black/White)', 'DD1391-100', 'White/White/Black', 'Sneakers', 115.00, '2021-03-09', '/products/DD1391-100.avif'),
(12, 'Nike Air Max 270 ''Black''', 'AH8050-005', ' Black/Black/Black', 'Sneakers', 170.00, '2018-03-16', '/products/AH8050-005.avif'),
(12, 'Nike Zoom Vomero 5 ''White/Metallic Silver''', 'IM2219-121', 'Summit White/Light Smoke Grey/Smoke Grey/Metallic Silver', 'Sneakers', 170.00, '2025-08-05', '/products/IM2219-121.avif'),
(12, 'Nike P-6000 ''White/Silver''', 'CN0149-001', 'Metallic Silver/Sail/Black/Metallic Silver', 'Sneakers', 115.00, '2023-10-06', '/products/CN0149-001.avif'),
(12, 'Nike Tech Fleece Windrunner Full-Zip Jacket ''Grey''', 'FB7921-063', 'Dark Grey Heather/Black', 'Apparel - Jacket', 135.00, '2023-08-12', '/products/FB7921-063.avif'),
(12, 'Nike Tech Fleece Joggers ''Grey''', 'HV0959-063', 'Dark Grey Heather/Black', 'Apparel - Pants', 125.00, '2025-09-10', '/products/HV0959-063.avif'),
(12, 'Nike Sportswear Phoenix Fleece Wide-Leg Sweatpants ''Black''', 'DQ5615-010', 'Black/Sail', 'Apparel - Pants', 70.00, '2023-01-26', '/products/DQ5615-010.jpg'),
(12, 'Nike Solo Swoosh Pullover Hoodie ''Fir/White''', 'DX1355-323', 'Fir/White', 'Apparel - Hoodie', 100.00, '2023-08-28', '/products/DX1355-323.avif'),
(12, 'Nike Air Max 1 ''86 OG ''Big Bubble''', 'DQ3989-100', 'White/University Red-Neutral Grey-Black', 'Sneakers', 150.00, '2023-03-26', '/products/DQ3989-100.avif'),
(12, 'Nike Air Max 90 ''Infrared'' (2020)', 'CT1685-100', 'White/Black-Cool Grey-Radiant Red', 'Sneakers', 135.00, '2020-11-09', '/products/CT1685-100.avif'),
(12, 'Nike Sportswear Club Fleece Crew ''Grey''', 'BV2662-063', 'Dark Grey Heather/White', '''Apparel - Crewneck', 70.00, '2022-01-26', '/products/BV2662-063.avif'),
(12, 'Nike V2K Run ''Metallic Silver''', 'FD0736-100', 'Summit White/Pure Platinum/Light Iron Ore/Metallic Silver', 'Sneakers', 110.00, '2023-09-28', '/products/FD0736-100.jpg'),
(12, 'Nike SB Dunk High ''MF Doom''', '313171-004', 'Black/Black-Midnight Fog', 'Sneakers', 150.00, '2007-07-24', '/products/313171-004.jpg'),
(12, 'Nike SB Dunk High ''Humidity''', 'AV4168-776', 'Metallic Gold/Metallic Gold-Black', 'Sneakers', 110.00, '2018-10-22', '/products/AV4168-776.jpg'),
(12, 'Nike SB Dunk High ''Strawberry Cough''', 'CW7093-600', 'University Red/Spinach Green-Magic Ember', 'Sneakers', 110.00, '2021-10-22', '/products/CW7093-600.jpg'),
(12, 'Nike SB Dunk High ''Skunk 420''', '313171-300', 'Black/Forest/Vintage Purple-Pilgrim', 'Sneakers', 140.00, '2010-04-20', '/products/313171-300.jpg'),

-- Adidas
(1, 'Adidas Samba OG ''White/Black''', 'BZ0057', 'Cloud White/Core Black/Clear Granite', 'Sneakers', 110.00, '2018-01-01', '/products/BZ0057.avif'),
(1, 'Adidas Gazelle Bold Shoes ''Core Black''', 'JI2060', 'Core Black/Cloud White/Gum', 'Sneakers', 120.00, '2018-05-01', '/products/JI2060.avif'),
(1, 'Essentials Wide Leg 3 Bar Logo Pant', 'JF3604', 'Black/White', 'Apparel - Pants', 38.00, '2025-03-14', '/products/JF3604.avif'),
(1, 'Adidas Stan Smith ''White/Green''', 'M20324', 'Running White/Running White/Fairway', 'Sneakers', 100.00, '2014-01-15', '/products/M20324.jpg'),
(1, 'Adidas Ultraboost 22 ''Core Black''', 'GZ0127', 'Core Black/Core Black/Core Black', 'Sneakers', 190.00, '2021-12-09', '/products/GZ0127.jpg'),
(1, 'Adidas NMD_R1 ''Core Black''', 'GZ9256', 'Core Black/Core Black/Core Black', 'Sneakers', 140.00, '2021-06-06', '/products/GZ9256.avif'),
(1, 'Adidas Adilette Slides ''Black Scarlet''', 'ID4925', 'Core Black/Core Black/Better Scarlet', 'Sandals', 50.00, '2023-06-15', '/products/ID4925.avif'),
(1, 'Adidas Superstar ''White/Black''', 'EG4958', 'Cloud White/Core Black/Cloud White', 'Sneakers', 80.00, '2019-12-01', '/products/EG4958.avif'),
(1, 'Adidas Gazelle Indoor ''Blue''', 'JI2061', 'Blue Bird/Cloud White/Gum', 'Sneakers', 120.00, '2024-01-30', '/products/JI2061.jpg'),
(1, 'Adidas Campus 00s ''Core Black''', 'HQ8708', 'Core Black/Footwear White/Off White', 'Sneakers', 110.00, '2023-02-14', '/products/HQ8708.avif'),
(1, 'adidas Fear of God Athletics Basketball 2 "Ash Silver"', 'JS0979', 'Ash Silver/Ash Silver/Ash Silver', 'Sneakers', 180.00, '2025-09-17', '/products/JS0979.avif'),
(1, 'Bad Bunny x adidas Adiracer GT', 'HQ2570', 'Branch/Sand/Cinder', 'Sneakers', 160.00, '2025-10-24', '/products/HQ2570.avif'),

-- Jordan
(8, 'Air Jordan 1 Retro High OG ''Chicago'' (Lost & Found)', 'DZ5485-612', 'Varsity Red/Black/Sail/Muslin', 'Sneakers', 180.00, '2022-11-19', '/products/DZ5485-612.avif'),
(8, 'Air Jordan 1 Retro High OG ''Shattered Backboard''', '555088-005', 'Black/Starfish-Sail', 'Sneakers', 160.00, '2015-06-27', '/products/555088-005.avif'),
(8, 'Air Jordan 3 Retro ''White Cement'' (Reimagined)', 'DN3707-100', 'Summit White/Fire Red/Black/Cement Grey', 'Sneakers', 210.00, '2023-03-11', '/products/DN3707-100.avif'),
(8, 'Air Jordan 4 Retro ''Bred'' (Reimagined)', 'FV5029-006', 'Black/Fire Red/Cement Grey/Summit White', 'Sneakers', 215.00, '2024-02-17', '/products/FV5029-006.avif'),
(8, 'Air Jordan 11 Retro ''Concord'' (2018)', '378037-100', 'White/Black-Dark Concord', 'Sneakers', 220.00, '2018-12-08', '/products/378037-100.avif'),
(8, 'Air Jordan 5 Retro ''Fire Red'' (2020)', 'DA1911-102', 'White/Black-Metallic Silver-Fire Red', 'Sneakers', 200.00, '2020-05-02', '/products/DA1911-102.avif'),
(8, 'Air Jordan 5 Retro ''Fire Red Silver Tongue'' (2020)', 'DA1911-102', 'White/Black-Metallic Silver-Fire Red', 'Sneakers', 200.00, '2020-05-02', '/products/DA1911-102.avif'),
(8, 'Air Jordan 4 Retro ''Black Cat'' (2020)', 'CU1110-010', 'Black/Black-Light Graphite', 'Sneakers', 190.00, '2020-01-22', '/products/CU1110-010.jpg'),
(8, 'Air Jordan 1 Mid ''White/Black''', 'DQ8426-132', 'White/Black-White-Black', 'Sneakers', 125.00, '2023-12-12', '/products/DQ8426-132.avif'),
(8, 'Air Jordan 3 Retro ''El Vuelo''', 'IO1752-100', 'Summit White/Metallic Gold/Pine Green/Dragon Red/Sail', 'Sneakers', 230.00, '2025-09-16', '/products/IO1752-100.avif'),
(8, 'Air Jordan 1 Retro High OG ''Pro Green'' (Women''s)', 'FD2596-101', 'Pale Ivory/Pro Green-Fir-Coconut Milk', 'Sneakers', 185.00, '2025-10-18', '/products/FD2596-101.avif'),
(8, 'Air Jordan 1 Retro Low OG ''Black Toe''', 'CZ0790-106', 'White/Black/Varsity Red', 'Sneakers', 140.00, '2023-08-04', '/products/CZ0790-106.jpg'),
(8, 'A Ma Maniére x Air Jordan 4 ''A Ma Maniére While You Were Sleeping (Women''s)''', 'FZ4810-200', 'Fossil Stone/Metallic Pewter/Burgundy Crush', 'Sneakers', 225.00, '2025-12-12', '/products/IF3102-200.jpg'),
(8, 'A Ma Maniére x Air Jordan 4 ''Violet Ore''', 'DV6773-220', 'Violet Ore/Medium Ash-Black-Muslin-Burgundy Crush', 'Sneakers', 225.00, '2025-12-12', '/products/DV6773-220.avif'),
(8, 'Travis Scott x Jordan Jumpman Jack "Bright Cactus"', 'FZ8117-102', 'Muslin/Black/Bright Cactus', 'Sneakers', 200.00, '2025-04-30', '/products/FZ8117-102.avif'),

-- Supreme
(19, 'Supreme x Swarovski Box Logo Hooded Sweatshirt ''Heather Grey''', 'SS19SW9 HEATHER GREY', 'Heather Grey', 'Apparel - Hoodie', 598.00, '2019-04-25', '/products/SS19SW9_HEATHER_GREY.avif'),
(19, 'Supreme x Swarovski Box Logo Hooded Sweatshirt ''Black''', 'SS19SW9 BLACK', 'Black', 'Apparel - Hoodie', 598.00, '2019-04-25', '/products/SS19SW9_BLACK.avif'),
(19, 'Supreme x Swarovski Box Logo Hooded Sweatshirt ''Red''', 'SS19SW9 RED', 'Red', 'Apparel - Hoodie', 598.00, '2019-04-25', '/products/SS19SW9_RED.avif'),
(19, 'Supreme x Swarovski Box Logo Tee ''White''', 'SS19T1 WHITE', 'White', 'Apparel - T-Shirt', 398.00, '2019-04-25', '/products/SS19T1_WHITE.avif'),
(19, 'Supreme x Swarovski Box Logo Tee ''Black''', 'SS19T1 BLACK', 'Black', 'Apparel - T-Shirt', 398.00, '2019-04-25', '/products/SS19T1_BLACK.avif'),
(19, 'Supreme x Nike Air Force 1 Low ''White''', 'CU9225-100', 'White/White', 'Sneakers', 124.00, '2020-03-05', '/products/CU9225-100.avif'),
(19, 'Supreme x Nike Air Force 1 Low ''Black''', 'CU9225-001', 'Black/Black-Black', 'Sneakers', 124.00, '2020-03-05', '/products/CU9225-001.avif'),
(19, 'Supreme x The North Face ''By Any Means Necessary'' Nuptse Jacket ''Black''', 'FW15J2 BLACK', 'Black', 'Apparel - Jacket', 368.00, '2015-11-19', '/products/FW15J2_BLACK.avif'),
(19, 'Supreme x The North Face ''By Any Means Necessary'' Mountain Jacket ''Black''', 'FW15J1 BLACK', 'Black', 'Apparel - Jacket', 298.00, '2015-11-19', '/products/FW15J1_BLACK.avif'),
(19, 'Supreme x The North Face ''Arc Logo'' Denali Fleece Jacket ''Red''', 'SS19J4 RED', 'Red', 'Apparel - Jacket', 268.00, '2019-03-28', '/products/SS19J4_RED.avif'),
(19, 'Supreme Hanes Boxer Briefs (4 Pack) ''White''', '99HAA36-WHITE', 'White', 'Accessory', 48.00, '2024-02-15', '/products/99HAA36-WHITE.avif'),
(19, 'Supreme Hanes Tagless Tees (3 Pack) ''White''', 'SS21', 'White', 'Apparel - T-Shirt', 38.00, '2021-08-19', '/products/SS21.avif'),

-- Balenciaga
(3, 'Balenciaga Triple S Sneaker ''Black''', '534217W2CA11000', 'Black', 'Sneakers', 1100.00, '2018-02-14', '/products/534217W2CA11000.avif'),
(3, 'Balenciaga Triple S Sneaker ''White Tan''', '534217W2CA19000', 'White/Tan', 'Sneakers', 1100.00, '2019-01-01', '/products/534217W2CA19000.avif'),
(3, 'Balenciaga Triple S Clear Sole Sneaker ''White''', '541624W2FB19000', 'White', 'Sneakers', 1150.00, '2017-09-21', '/products/541624W2FB19000.avif'),
(3, 'Balenciaga Speed 2.0 Full Clear Sole Sneaker ''Black''', '617239W2DC41000', 'Black', 'Sneakers', 1100.00, '2020-07-01', '/products/617239W2DC41000.avif'),
(3, 'Balenciaga Speed 2.0 LT Sock Sneaker ''Black/White''', '617239W2DB21015', 'Black/White', 'Sneakers', 995.00, '2020-07-01', '/products/617239W2DB21015.avif'),
(3, 'Balenciaga Runner Sneaker ''White''', '772774W3RMU9000', 'White', 'Sneakers', 1190.00, '2024-12-19', '/products/772774W3RMU9000.avif'),
(3, 'Balenciaga Runner Sneaker ''Multicolor''', '677403W3RB68123', 'Multicolor', 'Sneakers', 1190.00, '2022-04-07', '/products/677403W3RB68123.avif'),
(3, 'Balenciaga Track Sneaker ''White''', '542023W1GB19000', 'White', 'Sneakers', 1150.00, '2019-01-01', '/products/542023W1GB19000.avif'),
(3, 'Balenciaga Track Trail Sneaker ''Black''', '800592WTRHK1000', 'Black/Orange', 'Sneakers', 1250.00, '2024-04-22', '/products/800592WTRHK1000.avif'),
(3, 'Balenciaga 3XL Extreme Lace Sneaker ''White''', '778698W3XLL9114', 'White/Grey', 'Sneakers', 1290.00, '2025-03-01', '/products/778698W3XLL9114.avif'),
(3, 'Balenciaga 10XL Sneaker ''Grey''', '792779-W2MV2-9110', 'White/Black/Grey', 'Sneakers', 1290.00, '2023-12-02', '/products/792779-W2MV2-9110.jpg'),
(3, 'Balenciaga 3XL Extreme Lace Sneaker ''White''', '778698W3XLL1261', 'Grey/Red/Black', 'Sneakers', 1290.00, '2025-03-01', '/products/778698W3XLL1261.avif'),
(3, 'Balenciaga Political Campaign Hoodie ''White''', '600583TKVI99084', 'White', 'Apparel - Hoodie', 1150.00, '2017-01-01', '/products/600583TKVI99084.avif'),
(3, 'Balenciaga Political Campaign Hoodie ''Black''', '620973TKVI91070', 'Black', 'Apparel - Hoodie', 1150.00, '2017-01-01', '/products/620973TKVI91070.avif'),
(3, 'Balenciaga 10XL Sneaker ''Worn-Out Grey White Red''', '792779W2MV21960', 'Grey/White/Red', 'Sneakers', 1290.00, '2023-12-02', '/products/792779W2MV21960.avif'),
(3, 'Balenciaga Furry Slide ''Black''', '654747W2DO11096-654747W2HS41096', 'Black/White/Red', 'Slides', 550.00, '2022-05-13', '/products/654747W2DO11096-654747W2HS41096.jpg'),

-- Off-White
(13, 'Off-White x Nike Air Jordan 1 ''Chicago'' (The Ten)', 'AA3834-101', 'White/Black-Varsity Red', 'Sneakers', 190.00, '2017-11-09', '/products/AA3834-101.avif'),
(13, 'Off-White x Nike Blazer ''The Ten''', 'AA3832-100', 'White/Black-Muslin', 'Sneakers', 130.00, '2017-09-06', '/products/AA3832-100.avif'),
(13, 'Off-White x Nike Air Max 97 ''The Ten''', 'AJ4585-100', 'White/Cone/Ice Blue', 'Sneakers', 190.00, '2017-11-20', '/products/AJ4585-100.avif'),
(13, 'Off-White x Nike Air Presto ''The Ten''', 'AA3830-001', 'Black/Black/Muslin', 'Sneakers', 160.00, '2017-09-07', '/products/AA3830-001.avif'),
(13, 'Off-White x Nike Air Max 90 ''The Ten''', 'AA7293-100', 'Sail/White/Muslin', 'Sneakers', 160.00, '2017-09-06', '/products/AA7293-100.avif'),
(13, 'Off-White x Nike React Hyperdunk 2017 ''The Ten''', 'AJ4578-100', 'White/White-White', 'Sneakers', 200.00, '2017-11-01', '/products/AJ4578-100.avif'),
(13, 'Off-White x Nike Zoom Fly ''The Ten''', 'AJ4588-100', 'White/White-Muslin', 'Sneakers', 170.00, '2017-11-20', '/products/AJ4588-100.avif'),
(13, 'Off-White x Nike Air Presto ''Black'' (2018)', 'AA3830-002', 'Black/White-Cone', 'Sneakers', 160.00, '2018-07-27', '/products/AA3830-002.avif'),
(13, 'Off-White x Nike Air Max 90 ''Black''', 'AA7293-001', 'Black/Black-Cone-White', 'Sneakers', 160.00, '2019-02-07', '/products/AA7293-001.avif'),
(13, 'Off-White x Nike Air Force 1 ''Volt''', 'AO4606-700', 'Volt/Hyper Jade-Cone-Black', 'Sneakers', 170.00, '2018-12-19', '/products/AO4606-700.avif'),
(13, 'Off-White x Air Jordan 1 ''UNC''', 'AQ0818-148', 'White/Dark Powder Blue-Cone', 'Sneakers', 190.00, '2018-06-23', '/products/AQ0818-148.avif'),
(13, 'Off-White x Nike Air Force 1 ''MCA''', 'CI1173-400', 'University Blue/Metallic Silver-White', 'Sneakers', 150.00, '2019-07-20', '/products/CI1173-400.avif'),

-- BAPE
(4, 'BAPE 1st Camo Shark Full Zip Hoodie ''Green''', '1J80-115-009', 'Green', 'Apparel - Hoodie', 260.00, '2023-11-11', '/products/1J80-115-009.avif'),
(4, 'BAPE 1st Camo Shark Full Zip Hoodie ''Yellow''', '1L80-115-007', 'Yellow', 'Apparel - Hoodie', 435.00, '2018-09-22', '/products/1L80-115-007.avif'),
(4, 'BAPE Honeycomb Camo Shark Full Zip Hoodie ''Blue''', '1J30-115-009 BLUE', 'Blue', 'Apparel - Hoodie', 280.00, '2023-01-21', '/products/1J30-115-009_BLUE.avif'),
(4, 'BAPE Honeycomb Camo Shark Full Zip Hoodie ''Grey''', '1J30-115-009 GREY', 'Grey', 'Apparel - Hoodie', 280.00, '2023-01-21', '/products/1J30-115-009_GREY.avif'),
(4, 'A Bathing Ape Bape SK8 Sta ''Triple White Patent Leather Sta Logo''', '1I70-191-010-1I70-291-010-001FWI701010I-WHT', 'White/White/White', 'Sneakers', 180.00, '2022-10-21', '/products/1I70-191-010-1I70-291-010-001FWI701010I-WHT.avif'),
(4, 'A Bathing Ape Sk8 Sta #3 ''Black''', '1K80-191-312-BLK1-K80-291-312-BLK-001FWK801312M-BLK', 'Black', 'Sneakers', 309.00, '2025-01-04', '/products/1K80-191-312-BLK1-K80-291-312-BLK-001FWK801312M-BLK.avif'),
(4, 'A Bathing Ape Bape Sta Low ''Shark Pack White''', '1K80-191-307-WHT-1K80-291-307-WHT-001FWK801307-WHT', 'White', 'Sneakers', 299.00, '2024-09-21', '/products/1K80-191-307-WHT-1K80-291-307-WHT-001FWK801307-WHT.avif'),
(4, 'A Bathing Ape Bape Sta Double Sta ''Highsnobiety 20th Anniversary''', '1L73-191-909-1L73-291-901-001FWL731909-IVY', 'Ivory', 'Sneakers', 355.00, '2025-09-11', '/products/1L73-191-909-1L73-291-901-001FWL731909-IVY.avif'),
(4, 'A Bathing Ape Bape Sta Icon ''M2 Black''', '1K80-191-308-1K80-291-308-1K80191308-BLK', 'Black', 'Sneakers', 299.00, '2024-11-30', '/products/1K80-191-308-1K80-291-308-1K80191308-BLK.avif'),
(4, 'BAPE One Point Ape Head Shark Relaxed Fit Full Zip Hoodie ''Black''', '1K80-115-305', 'Black', 'Apparel - Hoodie', 535.00, '2024-07-14', '/products/1K80-115-305.avif'),
(4, 'BAPE 2nd Shark Full Zip Hoodie ''Gray''', 'FW24Grey', 'Gray', 'Apparel - Hoodie', 569.00, '2024-11-23', '/products/FW24Grey.avif'),
(4, 'BAPE x DC Baby Milo Superman Relaxed Fit Tee ''Navy''', '2H23-110-903', 'Navy', 'Apparel - T-Shirt', 90.00, '2021-03-01', '/products/2H23-110-903.avif'),

-- Brand: Stüssy
(18, 'Stüssy Authentic Gear Pigment Dyed Tee ''Faded Black''', '1905124', 'Faded Black', 'Apparel - T-Shirt', 45.00, '2025-09-06', '/products/1905124.jpg'),
(18, 'Stüssy Personalities Tee ''Slate''', '1905120-SLAT', 'Slate', 'Apparel - T-Shirt', 45.00, '2025-09-06', '/products/1905120-SLAT.jpg'),
(18, 'Stüssy Authorized Tee ''Black''', '1905122-BLAC', 'Black', 'Apparel - T-Shirt', 45.00, '2025-09-06', '/products/1905122-BLAC.jpg'),
(18, 'Stüssy Speedway L/S Tee ''Black''', '1995123-BLAC', 'Black', 'Apparel - T-Shirt', 55.00, '2025-09-06', '/products/1995123-BLAC.jpg'),
(18, 'Stüssy Lazy L/S Tee ''Pale Yellow''', '1140333-PYEL', 'Pale Yellow', 'Apparel - T-Shirt', 60.00, '2024-08-16', '/products/1140333-PYEL.jpg'),
(18, 'Stüssy State Crew Hoodie ''Black''', '118596-BLAC', 'Black', 'Apparel - Crewneck', 145.00, '2025-10-03', '/products/118596-BLAC.jpg'),
(18, 'Stüssy Midweight Hooded Puffer ''Black''', '115856-BLAC', 'Black', 'Apparel - Jacket', 245.00, '2024-09-13', '/products/115856-BLAC.jpg'),
(18, 'Stüssy Warm Up Jacket ''Red''', 'FW25Red', 'Red', 'Apparel - Jacket', 185.00, '2025-08-08', '/products/FW25Red.jpg'),
(18, 'Stüssy x Nike Fleece Sweatpants''Grey(SS23)''', 'DO9340-063', 'Grey (SS23)', 'Apparel - Pants', 90.00, '2024--08-02', '/products/DO9340-063.jpg'),
(18, 'Stüssy Carpenter Pant Canvas ''Black''', '116722_BLAC', 'Black', 'Apparel - Pants', 155.00, '2025-09-19', '/products/116722_BLAC.jpg'),
(18, 'Stüssy Training Pant ''Digi Camo''', '116717', 'Digi Camo', 'Apparel - Pants', 135.00, '2025-09-06', '/products/116717.jpg'),
(18, 'Stüssy Basic Cuff Beanie ''Black''', '1321019_BLAC', 'Black', 'Accessory', 40.00, '2021-09-17', '/products/1321019_BLAC.jpg'),
(18, 'Stüssy x Nike Air Force 1 Mid ''Fossil''', 'DJ7841-200', 'Fossil/Sail', 'Sneakers', 150.00, '2022-05-13', '/products/DJ7841-200.jpg'),
(18, 'Stüssy x Nike Air Penny 2 ''Black''', 'DQ5674-001', 'Black/Cobalt Pulse-White', 'Sneakers', 200.00, '2022-12-20', '/products/DQ5674-001.jpg'),
(18, 'Stüssy x Nike Air Max 2013 ''Fossil''', 'DM6447-200', 'Fossil/Black-Fossil', 'Sneakers', 210.00, '2022-08-05', '/products/DM6447-200.jpg'),

-- Palace
(14, 'Palace Zodiac Tri-Ferg Hood ''Black''', 'P28CS080', 'Grey Marl', 'Apparel - Hoodie', 138.00, '2025-02-07', '/products/P28CS080.webp'),
(14, 'Palace 09 Tri-Ferg T-Shirt ''Grey Marl''', 'P29TS149', 'Grey Marl', 'Apparel - T-Shirt', 48.00, '2025-10-17', '/products/P29TS149.avif'),
(14, 'Palace Shell Jogger ''Navy''', 'P29JG028', 'Navy', 'Apparel - Pants', 158.00, '2025-10-24', '/products/P29JG028.avif'),
(14, 'Palace Barbour Field Casual Jacket ''Kelp Forest Camo''', 'MCA1079GN51', 'Kelp Forest Camo', 'Apparel - Jacket', 970.00, '2025-10-24', '/products/MCA1079GN51.avif'),
(14, 'Palace Horses Jacket ''Navy/Red''', 'P29JK082', 'Navy/Red', 'Apparel - Jacket', 288.00, '2025-10-24', '/products/P29JK082.avif'),
(14, 'Palace Pertex Puffa Beanie ''Black''', 'P29BN021', 'Black', 'Accessory', 52.00, '2025-10-24', '/products/P29BN021.avif'),

-- Kith
(9, 'Kith Classic Logo Hoodie ''Sand''', 'FW17_01', 'Sand', 'Apparel - Hoodie', 150.00, '2017-12-04', '/products/FW17_01.avif'),
(9, 'Kith Classic Logo Hoodie ''Tiger Camo''', 'FW17_02', 'Tiger Camo', 'Apparel - Hoodie', 150.00, '2017-12-04', '/products/FW17_02.avif'),
(9, 'Kith Classic Logo Williams II Hoodie ''Heather Grey''', 'FW18_01HGH', 'Heather Grey', 'Apparel - Hoodie', 160.00, '2018-11-26', '/products/FW18_01HGH.jpg'),
(9, 'Kith Retro Logo Tee ''White''', 'khm034785-101', 'White', 'Apparel - T-Shirt', 65.00, '2022-08-04', '/products/khm034785-101.avif'),
(9, 'Kith Retro Logo Tee ''Black''', 'khm034785-001', 'Black', 'Apparel - T-Shirt', 65.00, 2022-08-04, '/products/khm034785-001.avif'),
(9, 'Kith x Looney Tunes KithJam Vintage Tee ''Black''', 'KH3808-100', 'Black', 'Apparel - T-Shirt', 75.00, '2020-07-13', '/products/KH3808-100.webp'),
(9, 'Kith x Disney Plush Through the Ages (Box set of 8)', 'KHxDP_8', 'Multicolor', 'Accessory', 105.00, '2019-11-18', '/products/KHxDP_8.avif'),
(9, 'Kith x ASICS Gel-Lyte III ''The Palette'' (Hallow)', '1201A224-253', 'Hallow', 'Sneakers', 180.00, '2020-11-27', '/products/1201A224-253.avif'),
(9, 'Kith x Nike Air Force 1 Low ''Knicks Home''', 'CZ7928-100', 'White/Rush Blue/Brilliant Orange', 'Sneakers', 130.00, '2020-12-18', '/products/CZ7928-100.avif'),
(9, 'Kith x New Balance 990v3 ''Daytona''', 'M990KH3', 'Daytona', 'Sneakers', 235.00, '2022-06-16', '/products/M990KH3.avif'),
(9, 'Kith x New Balance 990v2 ''Cyclades''', 'M990KC2', 'Cyclades', 'Sneakers', 225.00, '2022-06-17', '/products/M990KC2.avif'),
(9, 'Kith x New Balance 990v6 ''MSG (Sandrift)''', 'NBU990KN6', 'Sandrift/Methyl Blue', 'Sneakers', 220.00, '2023-11-06', '/products/NBU990KN6.avif'),

-- Fear of God
(7, 'Fear of God Athletics Pullover Hoodie ''Black''', 'IM8935', 'Black', 'Apparel - Hoodie', 230.00, '2023-12-03', '/products/IM8935.avif'),
(7, 'Fear of God Athletics Pullover Hoodie ''White''', 'IS5308', 'White', 'Apparel - Hoodie', 230.00, '2023-12-25', '/products/IS5308.avif'),
(7, 'Fear of God Athletics Cotton Fleece Hoodie ''Cement''', 'KA4570', 'Cement', 'Apparel - Hoodie', 165.00, '2024-06-07', '/products/KA4570.avif'),
(7, 'Fear of God Athletics Suede Fleece Hoodie ''Black''', 'KA4568', 'Black', 'Apparel - Hoodie', 280.00, '2023-12-03', '/products/KA4568.avif'),
(7, 'Fear of God Athletics Running Leggings ''Black''', 'IT1932', 'Black', 'Apparel - Pants', 180.00, '2024-04-03', '/products/IT1932.avif'),
(7, 'Fear of God Athletics Base Layer Running Tights ''Black''', 'IT1926', 'Black', 'Apparel - Pants', 150.00, '2024-04-03', '/products/IT1926.avif'),
(7, 'Fear of God Athletics Mock Neck 3/4 Sleeve T-Shirt ''Black''', 'IS6839', 'Black', 'Apparel - T-Shirt', 180.00, '2023-12-03', '/products/IS6839.webp'),
(7, 'Fear of God Essentials Vintage Fit Tee ''Jet Black''', '125SP254280F', 'Jet Black', 'Apparel - T-Shirt', 60.00, '2023-10-18', '/products/125SP254280F.webp'),
(7, 'Fear of God Essentials Pullover Hoodie ''Off Black''', '0192250500017522', 'Off Black', 'Apparel - Hoodie', 100.00, '2022-08-24', '/products/0192250500017522.webp'),
(7, 'Fear of God The California Slip-On ''Oat''', 'FG80-100EVA-991', 'Oat', 'Sneakers', 195.00, '2021-07-09', '/products/FG80-100EVA-991.webp'),
(7, 'Fear of God The California Slip-On ''Cream''', 'FG80-100EVA-CRM', 'Cream', 'Sneakers', 195.00, '2021-07-09', '/products/FG80-100EVA-CRM.avif'),
(7, 'Fear of God Athletics Adilette Slide Sandals ''Cream''', 'IH2272', 'Cream', 'Sneakers', 100.00, '2023-12-03', '/products/IH2272.avif'),

-- New Balance
(11, 'New Balance 9060 ''Rain Cloud''', 'U9060GRY', 'Rain Cloud/Castlerock/Grey', 'Sneakers', 159.99, '2022-08-13', '/products/U9060GRY.avif'),
(11, 'New Balance 9060 ''Truffle Rich Earth Magnet''', 'U9060BCG', 'Black/Phantom', 'Sneakers', 160.00, '2023-11-23', '/products/U9060BCG.avif'),
(11, 'New Balance 9060 ''Mushroom Aluminum''', 'U9060MUS', 'Mushroom/Aluminium/Grey', 'Sneakers', 159.99, '2023-08-04', '/products/U9060MUS.avif'),
(11, 'New Balance 2002R ''Protection Pack - Rain Cloud''', 'M2002RDA', 'Rain Cloud/Phantom/Grey', 'Sneakers', 145.00, '2021-08-20', '/products/M2002RDA.avif'),
(11, 'New Balance 2002R ''Arid Stone/Black Coffee''', 'U2002RN', 'Arid Stone/Black Coffee/Moon Shadow', 'Sneakers', 145.00, '2024-03-21', '/products/U2002RN.avif'),
(11, 'New Balance 574 Core ''Grey White''', 'ML574EVG', 'Grey/White', 'Sneakers', 99.99, '2018-01-01', '/products/ML574EVG.avif'),
(11, 'New Balance 574 Core ''Navy White''', 'ML574EVN', 'Navy/White', 'Sneakers', 99.99, '2018-01-01', '/products/ML574EVN.avif'),
(11, 'New Balance Made in USA 993 ''Grey''', 'MR993GL', 'Grey/White', 'Sneakers', 199.99, '2008-01-01', '/products/MR993GL.avif'),
(11, 'New Balance Made in USA 990v6 ''MiUSA Grey''', 'M990GL6', 'Grey/White/Navy', 'Sneakers', 199.99, '2022-11-04', '/products/M990GL6.avif'),
(11, 'New Balance 997H ''Team Red''', 'CM997HVR', 'Team Red/Pigment', 'Sneakers', 90.00, '2019-02-01', '/products/CM997HVR.avif'),
(11, 'New Balance 580 ''Comme des Garcons Homme Black''', 'MT580HM1', 'Black/White', 'Sneakers', 150.00, '2023-01-13', '/products/MT580HM1.avif'),
(11, 'New Balance 57/40 ''White Gum''', 'M5740LT', 'White/Ghost Pepper', 'Sneakers', 100.00, '2021-01-29', '/products/M5740LT.avif'),
(11, 'New Balance Fresh Foam X 1080v14 ''White Silver Metallic Sea Salt''', 'M1080W14', 'White/Sea Salt/Black', 'Sneakers', 164.99, '2024-03-01', '/products/M1080W14.jpg'),

-- ASICS
(2, 'ASICS GEL-KAYANO 14 ''White/Midnight''', '1201A019-107', 'White/Midnight', 'Sneakers', 150.00, '2022-08-01', '/products/1201A019-107.avif'),
(2, 'ASICS GEL-KAYANO 14 ''White/Pure Silver''', '1201A019-108', 'White/Pure Silver', 'Sneakers', 150.00, '2023-11-17', '/products/1201A019-108.avif'),
(2, 'ASICS GEL-1130 ''Clay Canyon''', '1201A256-200', 'Clay Canyon/Simply Taupe', 'Sneakers', 95.00, '2022-08-19', '/products/1201A256-200.avif'),
(2, 'ASICS GEL-1130 ''White/Oatmeal''', '1201A256-120', 'White/Oatmeal', 'Sneakers', 100.00, '2023-08-10', '/products/1201A256-120.avif'),
(2, 'ASICS GEL-1130 ''Black/Pure Silver''', '1201A906-001', 'Black/Silver', 'Sneakers', 99.99, '2023-03-01', '/products/1201A906-001.avif'),
(2, 'ASICS GEL-NYC ''Cream Grey''', '1203A739-100', 'Cream/Cream', 'Sneakers', 130.00, '2023-03-01', '/products/1203A739-100.jpg'),
(2, 'ASICS GEL-NYC ''Cream/Oyster Grey''', '1201A789-103', 'Cream/Oyster Grey', 'Sneakers', 140.00, '2023-01-13', '/products/1201A789-103.avif'),
(2, 'ASICS GT-2160 ''White Pure Silver Gold''', '1203A275-102', 'White/Pure Silver', 'Sneakers', 130.00, '2023-07-07', '/products/1203A275-102.avif'),
(2, 'ASICS GEL-LYTE III OG ''Okayama Denim Azure''', '1201A530-400', 'Hydrangea/Oyster Grey', 'Sneakers', 130.00, '2023-07-21', '/products/1201A530-400.avif'),
(2, 'ASICS GEL-NIMBUS 9 ''White Pure Silver''', '1201A424-106', 'White/Pure Silver', 'Sneakers', 160.00, '2022-01-20', '/products/1201A424-106.avif'),
(2, 'ASICS GEL-QUANTUM KINETIC ''Graphite Grey Black''', '1203A270-023', 'Graphite Grey/Black', 'Sneakers', 250.00, '2023-04-06', '/products/1203A270-023.jpg'),
(2, 'ASICS NOVALIS GEL-TEREMOA ''Kiko Kostadinov Novalis Obsidian Black Smoke Shadow''', '1203A331-001', 'Obsidian Black/Smoke Shadow', 'Sneakers', 120.00, '2023-10-13', '/products/1203A331-001.avif'),
(2, 'ASICS GEL-LYTE III OG ''Cream Olive Gray''', '1201A382-101', 'Cream/Olive Grey', 'Sneakers', 90.00, '2022-12-22', '/products/1201A382-101.avif'),

-- Salomon
(17, 'Salomon XT-6 ''Triple Black''', 'L41086600', 'Black/Black/Phantom', 'Sneakers', 190.00, '2020-034-27', '/products/L41086600.jpg'),
(17, 'Salomon XT-4 OG Protective ''Safari Almond Milk''', 'L47730300', 'Safari/Almond Milk/Kelp', 'Sneakers', 200.00, NULL, '/products/L47730300.jpg'),
(17, 'Salomon XT-6 Gore-Tex ''Black Silver''', 'L47450600', 'Black/Black/Footwear Silver', 'Sneakers', 200.00, '2024-01-27', '/products/L47450600.jpg'),
(17, 'Salomon XT-6 Expanse ''Lily Pad Pewter''', 'L47134200', 'Lily Pad/Laurel Wreath/Pewter', 'Sneakers', 180.00, '2023-02-01', '/products/L47134200.jpg'),
(17, 'Salomon XT-6 ''White/Ftw Silver''', 'L47581100', 'White/White/Footwear Silver', 'Sneakers', 2000.00, '2024-08-23', '/products/L47581100.jpg'),
(17, 'Salomon XT-4 OG ''White Lunar Rock ''', 'L47133000', 'White/Ebony/Lunar Rock', 'Sneakers', 220.00, '2023-02-07', '/products/L47133000.jpg'),
(17, 'Salomon XT-6 White ''Lunar Rock''', 'L41252900', 'White/White/Lunar Rock', 'Sneakers', 190.00, '2022-01-27', '/products/L41252900.jpg'),
(17, 'Salomon XT-6 ''Gore-TexCarbon Liberty''', 'L47732500', 'Carbon/Vanilla Ice/Liberty', 'Sneakers', 200.00, '2025-01-10', '/products/L47732500.jpg'),
(17, 'Salomon XT-6 Gore-Tex ''Olive Night''', 'L47732700', 'Olive Night/Sedona Sage/Black', 'Sneakers', 200.00, NULL, '/products/L47732700.jpg'),
(17, 'Salomon XT-WINGS 2 ''Black''', 'L41085700', 'Black/Black/Magnet', 'Sneakers', 160.00, '2022-03-02', '/products/L41085700.jpg'),
(17, 'Salomon XT-4 Mule ''MM6 Maison Margiela Ultramarine''', 'S59WS0240P8163 ', 'Ultramarine/Rum Raisin/Yellow Iris', 'Sneakers', 455.00, '2025-04-17', '/products/S59WS0240P8163.jpg'),
(17, 'Salomon XT-6 Expanse ''75th Anniversary Golden Oak''', 'L41705300', 'Golden Oak/Acorn/Black', 'Sneakers', 180.00, '2022-08-11', '/products/L41705300.jpg'),
(17, 'Salomon XT-6 ''Skyline Sun Baked''', 'L41629800', 'Vanilla Ice/Yucca/Sun Baked', 'Sneakers', 185.00, '2022-07-12', '/products/L41629800.jpg'),

-- Vans
(20, 'Vans Premium Old Skool Black & White', 'VN000CQDBA2', 'Black & White', 'Sneakers', 90, '2025-01-24', '/products/VN000CQDBA2.jpg'),
(20, 'Vans Skate Old Skool 36+ Black White', 'VN000D5RBA2', 'Black/White', 'Sneakers', 80, '2025-01-30', '/products/VN000D5RBA2.jpg'),
(20, 'Vans Classic Slip-On ''Checkerboard'' (Black/White)', 'VN000EYEBWW', 'Black/White', 'Sneakers', 65.00, '2022-06-01', '/products/VN000EYEBWW.jpg'),
(20, 'Vans Classic Slip-On ''Checkerboard'' (True White/True White)', 'VN000EYEX1L', 'True White/True White', 'Sneakers', 65.00, '2019-01-01', '/products/VN000EYEX1L.jpg'),
(20, 'Vans Classic Slip-On ''Checkerboard'' (Black/Black)', 'VN000EYE276', 'Black/Black', 'Sneakers', 50.00, NULL, '/products/VN000EYE276.jpg'),
(20, 'Vans Classic Slip-On ''Checkerboard'' (Black/Pewter)', 'VN000EYEBPJ', 'Pewter', 'Sneakers', 65.00, NULL, '/products/VN000EYEBPJ.jpg'),
(20, 'Vans Knu Skool ''Black Port''', 'VN0009QC2Q1', 'Black/Port', 'Sneakers', 75.00, '2023-10-24', '/products/VN0009QC2Q1.jpg'),
(20, 'Vans Knu Skool ''Triple Black''', 'VN0009QCBKA', 'Black/Black', 'Sneakers', 75.00, '2023-05-21', '/products/VN0009QCBKA.jpg'),
(20, 'Vans Knu Skool ''Black True White''', 'VN0009QC6BT', 'Black/True White', 'Sneakers', 75, '2023-02-18', '/products/VN0009QC6BT.jpg'),
(20, 'Vans Sk8-Hi ''Black/White''', 'VN000D5IB8C', 'Black/True White', 'Sneakers', 65.00, '2019-01-01', '/products/VN000D5IB8C.jpg'),
(20, 'Vans Authentic ''True White''', 'VN000EE3W00', 'True White', 'Sneakers', 60, '2019-01-01', '/products/VN000EE3W00.jpg'),
(20, 'Vans Authentic ''Black''', 'VN000EE3BLK', 'Black', 'Sneakers', 60.00, '2018-01-01', '/products/VN000EE3BLK.jpg'),
(20, 'Vans Curren ''Triple Black''', 'VN000D8RBLK', 'Black/Black', 'Sneakers', 80, '2025-05-15', '/products/VN000D8RBLK.jpg'),
(20, 'Vans Old Skool Platform ''Black White''', 'VN0A3B3UY28', 'Black/White', 'Sneakers', 75.00, '2019-01-01', '/products/VN0A3B3UY28.jpg'),
(20, 'Vans Old Skool ''Black White''', 'VN000D3HY28', 'Black/White', 'Sneakers', 70.00, '2017-01-01', '/products/VN000D3HY28.jpg'),
(20, 'Vans UltraRange 2.0 ''Black Grey''', 'VN000D60BKA', 'Black', 'Sneakers', 100.00, NULL, '/products/VN000D60BKA.jpg'),
(20, 'Vans Old Skool ''Navy White''', 'VN0D3HNVY', 'Navy/WHite', 'Sneakers', 70.00, '2000-01-01', '/products/VN0D3HNVY.jpg'),

-- Converse
(5, 'Converse Chuck Taylor All Star Classic ''White'' (High Top)', 'M7650C', 'Optical White', 'Sneakers', 60.00, '2017-01-20', '/products/M7650C.jpg'),
(5, 'Converse Run Star Hike Hi ''Black White Gum''', '166800C', 'Black/White-Gum', 'Sneakers', NULL, '2020-01-09', '/products/166800C.jpg'),
(5, 'Converse Chuck Taylor All Star 70 Hi ''Comme des Garcons PLAY Black''', '150204C-A08791C', 'Black/White/High Risk Red', 'Sneakers', 125.00, '2019-03-30', '/products/150204C-A08791C.jpg'),
(5, 'Converse Chuck Taylor All Star 70 Hi ''Comme des Garcons PLAY Grey''', '171847C-A08793C', 'Steel Gray/Egret/Black', 'Sneakers', 150.00, '2021-06-03', '/products/171847C-A08793C.jpg'),
(5, 'Converse Chuck Taylor All Star 70 Ox ''Comme des Garcons PLAY Blue Quartz''', '171848C-A08798C', 'Blue Quartz/Egret/Black', 'Sneakers', 150.00, '2024-05-29', '/products/171848C-A08798C.jpg'),
(5, 'Converse Chuck Taylor All Star 70 Ox ''Comme des Garcons PLAY Multi-Heart Milk''', 'A08150C-AZ-K126-001-2', 'Milk/Black/Egret', 'Sneakers', 150.00, '2023-10-26', '/products/A08150C-AZ-K126-001-2.jpg'),
(5, 'Converse Chuck Taylor All Star OX ''Black''', 'M9166', 'Black', 'Sneakers', 55.00, '2011-03-16', '/products/M9166.jpg'),
(5, 'Converse Chuck Taylor All Star Hi ''Platform Black White (Women''s)''', '560845F-560845C', 'Black/White/White', 'Sneakers', 70, '2021-12-27', '/products/560845F-560845C.jpg'),
(5, 'Converse Chuck 70 High Top ''Black''', '162050C', 'Black', 'Sneakers', 85, '2018-01-01', '/products/162050C.jpg'),
(5, 'Converse Chuck Taylor All Star Lugged ''White''', '565902C', 'White/Black/White', 'Sneakers', 70.00, '2020-01-14', '/products/565902C.jpg'),
(5, 'Converse Chuck Taylor All Star 70 Hi ''Comme des Garcons PLAY Single Heart Black''', 'AZ-K129-001-1', 'Black/White/Egret', 'Sneakers', 150, '2024-07-11', '/products/AZ-K129-001-1.jpg'),
(5, 'Converse Jack Purcell Canvas Low ''White''', '164057C', 'White/White', 'Sneakers', 65, '2019-05-01', '/products/164057C.jpg'),
(5, 'Converse Chuck Taylor All Star 70 Hi ''Comme des Garcons PLAY White''', '150205C', 'Milk/White-High Risk Red', 'Sneakers', 125, '2019-01-27', '/products/150205C.jpg'),

-- Puma
(15, 'Puma Palermo ''Black-Feather Gray-Gum''', '397647-03', 'Black-Feather Gray-Gum', 'Sneakers', 90, '2023-09-01', '/products/397647-03.avif'),
(15, 'Puma x LaMelo Ball MB.01 ''Red'' (Not From Here)', '377237-202', 'Red Blast/Fiery Red', 'Sneakers', NULL, '2021-12-16', '/products/377237-02.jpg'),
(15, 'Puma x LaMelo Ball MB.01 ''Team Colors Red''', '376941-10', 'Puma White/High Risk Red', 'Sneakers', 120, '2022-07-13', '/products/376941-10.jpg'),
(15, 'Fenty x Puma Creeper Phatty ''Lavender Alert''', '396403-03', 'Lavender Alert/Burnt Red-Gum', 'Sneakers', 140, '2023-11-30', '/products/396403-03.jpg'),
(15, 'Puma Suede Classic ''Team Regal Red''', '352634-05', 'Team Regal Red/White', 'Sneakers', 90.00, '2025-03-31', '/products/352634-05.jpg'),
(15, 'Puma Suede XL ''Black Frosted Ivory''', '396057-01', 'Black/Frosted Ivory', 'Sneakers', NULL, '2024-01-06', '/products/396057-01.jpg'),
(15, 'Puma Suede XL ''Black White''', '395205-02', 'Black/White', 'Sneakers', 100, '2018-04-08', '/products/395205-02.jpg'),
(15, 'Puma Speedcat OG ''Black White''', '398846-01', 'Black/White', 'Sneakers', 120.00, '2024-06-29', '/products/398846-01.jpg'),
(15, 'Puma x LaMelo Ball MB.01 ''Foot Locker 50th Anniversary''', '310506-01', 'Black/White-Gold', 'Sneakers', 120, '2024-09-09', '/products/310506-01.jpg'),
(15, 'Puma Suede Classic XXI ''Black/White''', '374915-01', 'Black/White', 'Sneakers', 70, '2021-02-19', '/products/374915-01.jpg'),
(15, 'Puma x LaMelo Ball MB.01 ''White Silver''', '376941-04', 'Puma White/Silver', 'Sneakers', 120.00, '2022-07-13', '/products/376941-04.jpg'),
(15, 'Fenty x Puma Creeper Phatty ''Rihanna Fenty Speed Blue''', '396403-02', 'Speed Blue/Lime Pow/Gum', 'Sneakers', 140.00, '2023-11-30', '/products/396403-02.jpg'),
(15, 'Fenty x Puma Creeper Phatty ''Rihanna Fenty Totally Taupe''', '396813-01', 'Totally Taupe/Gold/Warm White', 'Sneakers', 140.00, '2024-04-18', '/products/396813-01.jpg'),
(15, 'Fenty x Puma Creeper Phatty ''Rihanna Fenty Warm White (Women''s)''', '399865-03', 'Warm White/Gold/Gum', 'Sneakers', NULL, '2024-04-25', '/products/399865-03.jpg'),

-- Reebok
(16, 'Reebok Club C 85 Vintage ''Chalk/Glen Green''', 'DV6434-100000317', 'Chalk/Paperwhite/Glen Green', 'Sneakers', NULL, '2021-02-12', '/products/DV6434-100000317.jpg'),
(16, 'Reebok Club C Revenge Vintage ''Chalk/Glen Green''', 'FW4862-100001283', 'Chalk/Paper White/Glen Green', 'Sneakers', 80, NULL, '/products/FW4862-100001283.jpg'),
(16, 'White Mountaineering x Reebok Classic Leather ''Grey''', '100233213', 'Grey/White', 'Sneakers', 190, '2025-04-11', '/products/100233213.jpg'),
(16, 'White Mountaineering x Reebok Classic Leather ''Brown''', '100233214', 'Brown/White', 'Sneakers', 190, '2025-04-11', '/products/100233214.jpg'),
(16, 'Reebok Question Mid ''Red Toe'' (2024 Re-release)', '100074721', 'Footwear White/Vector Red/Footwear White', 'Sneakers', 170, '2024-02-16', '/products/100074721.jpg'),
(16, 'Reebok x JJJJOUND Club C ''Olive''', 'GX9657', 'White/Olive', 'Sneakers', 150, '2023-04-06', '/products/GX9657.jpg'),
(16, 'Reebok Classic Leather ''Black/Silver''', '100201810', 'Black/Silver/White', 'Sneakers', 130, '2024-10-23', '/products/100201810.jpg'),
(16, 'Reebok Club C 85 Vintage ''Footwear White/Barely Grey'' (Paperwhite)', '100033001', 'Cloud White/Pure Grey/Paperwhite', 'Sneakers', NULL, '2023-09-21', '/products/100033001.jpg'),
(16, 'Reebok Question Mid ''Banner''', 'M46120', 'Red/Royal/White/Gold Met', 'Sneakers', 160, '2014-03-15', '/products/M46120.jpg'),
(16, 'Reebok Club C Revenge ''White/Glen Green''', 'H04169', 'Footwear White/Glen Green/Footwear White', 'Sneakers', NULL, '2020-12-23', '/products/H04169.jpg'),
(16, 'Reebok Classic Leather ''White'' (Core)', '49797', 'White', 'Sneakers', NULL, '2022-01-01', '/products/49797.jpg'),
(16, 'Reebok Classic Leather ''Black'' (Core)', 'GY0955', 'Core Black/Core Black/Pure Grey 5', 'Sneakers', NULL, '2022-04-05', '/products/GY0955.jpg'),
(16, 'Reebok Premier Road Ultra ''Black''', 'RMIA06BC99MAT0011019-100236667', 'Black', 'Sneakers', 170.00, '2024-09-19', '/products/RMIA06BC99MAT0011019-100236667.jpg'),
(16, 'Reebok Nano X5 ''Black''', '100209359', 'Black/Grey 5/Reebok Lee 3', 'Sneakers', 140, '2025-01-24', '/products/100209359.jpg'),
(16, 'Reebok Phase Court ''White Chalk Blue''', '100201248', 'White/Chalk/Kinetic Blue', 'Sneakers', 85, '2024-06-01', '/products/100201248.jpg'),

-- Dior
(6, 'Dior B27 Low ''White Calfskin''', '3SN272ZSB_H000', 'White/Grey', 'Sneakers', 1150.00, '2023-04-15', '/products/3SN272ZSB_H000.jpg'),
(6, 'Dior B27 Low ''Black Beige''', '3SN272ZIR_H965', 'Black/Beige', 'Sneakers', 990.00, '2020-11-01', '/products/3SN272ZIR_H965.jpg'),
(6, 'Dior B57 Low ''Dior Oblique Black White''', '3SN318ZXU_H960', 'Black/White', 'Sneakers', 1250, '2024-04-15', '/products/3SN318ZXU_H960.jpg'),
(6, 'Dior B23 High Top ''Logo Oblique''', '3SH118YJP_H069-3SH118YJPT00480H069', 'Oblique', 'Sneaker', 1050.00, '2019-04-05', '/products/3SH118YJP_H069-3SH118YJPT00480H069.jpg'),
(6, 'Dior B24 High Top ''BLack''', '3SH126ZXX_H969', 'Black', 'Sneakers', 1150.00, '2023-10-12', '/products/3SH126ZXX_H969.jpg'),
(6, 'Dior Square-Frame Acetate Optical Frames ''Beige Transparent''', 'DM50082I-54-059', 'Beige Beige Transparent', 'Accessories - Eyewear', 430.00, NULL, '/products/DM50082I-54-059.jpg'),
(6, 'Dior Square-Frame Acetate Optical Frames ''Havana Transparent''', 'DM50008J-54-052', 'Havana Havana Transparent', 'Accessories - Eyewear', 430.00, NULL, '/products/DM50008J-54-052.jpg'),
(6, 'Dior Square-Frame Acetate Optical Frames ''Green Transparent''', 'DM50084I-55-098', 'Green Green Transparent', 'Accessories - Eyewear', 430.00, '2024-05-30', '/products/DM50084I-55-098.jpg'),
(6, 'Dior Portefeuille Leather Wallet ''Gris Marron''', '2ADBH076YKE', 'Gris/Marron', 'Accessories - Wallets & Cardholders - Wallets', NULL, NULL, '/products/2ADBH076YKE.jpg'),
(6, 'Dior Saddle Wallet ''Oblique (6 Card Slot) Blue''', 'S5614CTZQ_M928', 'Blue', 'Accessories - Bags', 1250.00, NULL, '/products/S5614CTZQ_M928.jpg'),
(6, 'Dior Card Holder (6 Card Slot) ''Oblique Jacquard Black''', '2ESCH135YSE_H03E', 'Black', 'Accessories - Wallets & Cardholders - Card Holders', 450.00, NULL, '/products/2ESCH135YSE_H03E.jpg'),
(6, 'Dior Card Holder (6 Card Slot) ''Oblique Jacquard Gray''', '2ESCH135VPD_H860', 'Gray', 'Accessories - Wallets & Cardholders - Card Holders', 390.00, NULL, '/products/2ESCH135VPD_H860.jpg'),
(6, 'Dior Bi-Fold Card Holder ''Oblique Jacquard Black''', '2ESCH138YSE_H03E', 'Black', 'Accessories - Wallets & Cardholders - Card Holders', 400.00, NULL, '/products/2ESCH138YSE_H03E.jpg'),
(6, 'Dior Oblique Jacquard Belt ''Beige Black''', '1.4WLeatherBeigeBlack', 'Beige/Black', 'Accessories - Belts', NULL, NULL, '/products/1.4WLeatherBeigeBlack.jpg'),

-- Maison Margiela
(10, 'Maison Margiela Replica GAT ''White Painter''', 'S57WS0240P1892-961', 'White/Gum/Multi', 'Sneakers', 650.00, '2022-12-20', '/products/S57WS0240P1892-961.jpg'),
(10, 'Maison Margiela Replica GAT', 'S57WS0236P1895101', 'Grey/White/Gum', 'Sneakers', 540.00, '2020-04-30', '/products/S57WS0236P1895101.jpg'),
(10, 'Maison Margiela Paint Replica GAT ''Black''', 'S57WS0240P1892963', 'Black', 'Sneakers', 680.00, '2024-03-19', '/products/S57WS0240P1892963.jpg'),
(10, 'Maison Margiela Replica GAT ''Black Gum''', 'S57WS0236P1895H6851', 'Black/Gum', 'Sneakers', 495.00, '2019-06-29', '/products/S57WS0236P1895H6851.jpg'),
(10, 'Maison Margiela MM6 Basic T-shirt ''Black''', 'S62GD0193-S23962-900', 'Black', 'T-Shirt', 455.00, NULL, '/products/S62GD0193-S23962-900.jpg'),
(10, 'Maison Margiela MM6 V-Neck SIDA Print T-shirt ''White''', 'S62GD0203-M20108-100', 'White', 'T-Shirt', 315, NULL, '/products/S62GD0203-M20108-100.jpg'),
(10, 'Maison Margiela Paint Replica ''White Pewter''', 'S57WS0481P6230H0A65', 'White/Pewter', 'Sneakers', 680.00, NULL, '/products/S57WS0481P6230H0A65.jpg'),
(10, 'Maison Margiela Tabi Ballerina Flat Elastic Band ''Black Nude (Women''s)''', 'S39WZ0104-P6853-HA334', 'Black/Nude', 'Shoes - Flats', 1090.00, NULL, '/products/S39WZ0104-P6853-HA334.jpg'),
(10, 'Supreme MM6 Maison Margiela Receipt Wallet ''Multicolor''', 'SS24Multicolor', 'Multicolor', 'Accessories - Wallet', 228.00, '2024-03-28', '/products/SS24Multicolor.jpg'),
(10, 'Maison Margiela Replica GAT ''Dirty Wash''', 'S37WS0562P3724H8339', 'Dirty Wash', 'Sneakers', 590.00, NULL, '/products/S37WS0562P3724H8339.jpg'),
(10, 'Maison Margiela 50-50 Sneakers ''Black''', 'S37WS0575', 'Black', 'Sneakers', 1000.00, NULL, '/products/S37WS0575.jpg'),
(10, 'Maison Margiela Tabi County Loafer ''Black''', 'S57WR0139-P3827-H8396', 'Black', 'Shoes - Loafers', 1090.00, NULL, '/products/S57WR0139-P3827-H8396.jpg'),
(10, 'Maison Margiela Doll Hobo Bag ''Black''', 'SB1WD0032-P7275-T8013', 'Black', 'Accessories - Bags', 1770.00, NULL, '/products/SB1WD0032-P7275-T8013.jpg'),
(10, 'Maison Margiela Dress-Age Hobo Bag ''Black/Chestnut/Black''', 'SB2WD0096-P7268-HA755', 'Black/Chestnut/Black', 'Accessories - Bags', 2500.00, NULL, '/products/SB2WD0096-P7268-HA755.jpg'),
(10, 'Gentle Monster Maison Margiela Glasses ''Black Clear''', 'MM210-01', 'Black Clear', 'Accessories - Glasses', 291.00, '2025-03-06', '/products/MM210-01.jpg');

INSERT INTO products_sizes (product_id, size_id)
SELECT p.product_id, s.size_id
FROM products p
CROSS JOIN sizes s
WHERE
    p.product_type IN (
        'Sneakers',
        'Sandals',
        'Slides',
        'Shoes - Flats'
    )
    AND s.size_id BETWEEN 11 AND 20;

INSERT INTO products_sizes (product_id, size_id)
SELECT p.product_id, s.size_id
FROM products p
CROSS JOIN sizes s
WHERE
    (
        p.product_type LIKE 'Apparel%'
        OR p.product_type IN (
            'T-Shirt',
            'Hooded Sweatshirt',
            'Sweater'
        )
    )
    AND s.size_id BETWEEN 21 AND 26;

INSERT INTO products_sizes (product_id, size_id)
SELECT p.product_id, s.size_id
FROM products p
CROSS JOIN sizes s
WHERE
    p.name = 'Supreme Hanes Boxer Briefs (4 Pack) ''White'''
    AND s.size_id BETWEEN 21 AND 26;

-- Truncate transactional tables before inserting new data
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE addresses;
TRUNCATE TABLE portfolio_items;
TRUNCATE TABLE transactions;
TRUNCATE TABLE orders;
TRUNCATE TABLE listings;
TRUNCATE TABLE bids;
TRUNCATE TABLE account_balance;
SET FOREIGN_KEY_CHECKS = 1;

-- Re-populate account_balance for all users, with a starting balance "curve"
INSERT INTO account_balance (user_id, balance)
SELECT
    u.uuid,
    CASE
        -- "Month 0: $0" (Users created in the current month)
        WHEN TIMESTAMPDIFF(MONTH, u.created_at, NOW()) = 0 THEN 0.00

        -- "Month 1: $500" (Users created 1 month ago)
        WHEN TIMESTAMPDIFF(MONTH, u.created_at, NOW()) = 1 THEN 500.00

        -- "At a certain point it becomes random" (Users > 1 month old)
        -- We'll give them a random balance based on their "age"
        ELSE
            -- Start with a base of 500, plus a random amount ($0-$200) for each month they've been active.
            ROUND(500.00 + (TIMESTAMPDIFF(MONTH, u.created_at, NOW()) * RAND() * 200), 2)
    END AS starting_balance
FROM users u;

-- Truncate transactional tables before inserting new data
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE addresses;
TRUNCATE TABLE portfolio_items;
TRUNCATE TABLE transactions;
TRUNCATE TABLE orders;
TRUNCATE TABLE listings;
TRUNCATE TABLE bids;
TRUNCATE TABLE account_balance;
SET FOREIGN_KEY_CHECKS = 1;

-- Re-populate account_balance for all users, with a starting balance "curve"
INSERT INTO account_balance (user_id, balance)
SELECT
    u.uuid,
    CASE
        -- "Month 0: $0" (Users created in the current month)
        WHEN TIMESTAMPDIFF(MONTH, u.created_at, NOW()) = 0 THEN 0.00

        -- "Month 1: $500" (Users created 1 month ago)
        WHEN TIMESTAMPDIFF(MONTH, u.created_at, NOW()) = 1 THEN 500.00

        -- "At a certain point it becomes random" (Users > 1 month old)
        ELSE
            -- Start with a base of 500, plus a random amount ($0-$200) for each month they've been active.
            ROUND(500.00 + (TIMESTAMPDIFF(MONTH, u.created_at, NOW()) * RAND() * 200), 2)
    END AS starting_balance
FROM users u;

-- =================================================================
-- UNIFIED PROCEDURE: CreateMarketHistory
--
-- This single procedure replaces CreatePastSales, CreateActiveListings,
-- and CreateActiveBids.
--
-- 1. It iterates through every product/size/condition.
-- 2. It generates a *chronological* sales history (15-30 sales)
--    where each sale price is a slight "random walk" from the
--    previous sale price, making the history trend up or down.
-- 3. It uses the FINAL sale price from that history as an anchor.
-- 4. It then generates 3-5 realistic active bids and 3-5 active
--    asks, creating a "spread" based on that last sale price.
-- =================================================================

DROP PROCEDURE IF EXISTS CreateMarketHistory;

DELIMITER $$

CREATE PROCEDURE CreateMarketHistory()
BEGIN
    -- Cursor variables
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_product_id INT UNSIGNED;
    DECLARE v_size_id INT UNSIGNED;
    DECLARE v_retail_price DECIMAL(10, 2);
    DECLARE v_brand_id INT UNSIGNED;
    DECLARE v_product_name VARCHAR(255);

    -- Loop variables
    DECLARE v_product_condition ENUM('new', 'used', 'worn');
    DECLARE cond_iterator INT;
    DECLARE sales_iterator INT;
    DECLARE num_sales_for_item INT;

    -- Price/Time variables
    DECLARE v_sale_price DECIMAL(10, 2);
    DECLARE v_last_sale_price DECIMAL(10, 2);
    DECLARE v_initial_market_price DECIMAL(10, 2);
    DECLARE v_base_price_multiplier DECIMAL(5, 2);
    DECLARE v_price_walk_multiplier DECIMAL(5, 2);
    DECLARE v_current_timestamp DATETIME;
    DECLARE v_time_increment_days INT;

    -- Order variables
    DECLARE v_order_id CHAR(36);
    DECLARE v_buyer_id CHAR(36);
    DECLARE v_seller_id CHAR(36);
    DECLARE v_buyer_first_name VARCHAR(100);
    DECLARE v_buyer_last_name VARCHAR(100);

    -- Fee variables
    DECLARE v_fee_id INT UNSIGNED DEFAULT 1;
    DECLARE v_seller_fee_pct DECIMAL(10, 4);
    DECLARE v_buyer_fee_pct DECIMAL(10, 4);
    DECLARE v_buyer_tx_fee DECIMAL(10, 2);
    DECLARE v_buyer_final_price DECIMAL(10, 2);
    DECLARE v_seller_tx_fee DECIMAL(10, 2);
    DECLARE v_seller_final_payout DECIMAL(10, 2);

    -- Balance check variables
    DECLARE v_buyer_current_balance DECIMAL(15, 2);
    DECLARE v_payment_origin ENUM('account_balance', 'credit_card', 'other');

    -- Active Bid/Ask variables
    DECLARE v_active_loop_i INT;
    DECLARE v_num_active_bids INT;
    DECLARE v_num_active_asks INT;
    DECLARE v_ask_price DECIMAL(10, 2);
    DECLARE v_bid_amount DECIMAL(10, 2);
    DECLARE v_total_bid_amount DECIMAL(10, 2);
    DECLARE v_active_created_at DATETIME;

    -- Declare the cursor
    DECLARE product_cursor CURSOR FOR
        SELECT ps.product_id, ps.size_id, p.retail_price, p.brand_id, p.name
        FROM products_sizes ps
        JOIN products p ON ps.product_id = p.product_id;

    -- Declare continue handler
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Get fee percentages ONCE
    SELECT seller_fee_percentage, buyer_fee_percentage
    INTO v_seller_fee_pct, v_buyer_fee_pct
    FROM fee_structures WHERE id = v_fee_id;

    OPEN product_cursor;

    product_loop: LOOP
        FETCH product_cursor INTO v_product_id, v_size_id, v_retail_price, v_brand_id, v_product_name;
        IF done THEN
            LEAVE product_loop;
        END IF;

        IF v_retail_price IS NULL OR v_retail_price = 0 THEN
            SET v_retail_price = 150.00; -- Default retail if missing
        END IF;

        -- Loop 1: Iterate through all 3 conditions
        SET cond_iterator = 1;
        WHILE cond_iterator <= 3 DO
            IF cond_iterator = 1 THEN
                SET v_product_condition = 'new';
            ELSEIF cond_iterator = 2 THEN
                SET v_product_condition = 'used';
            ELSE
                SET v_product_condition = 'worn';
            END IF;

            -- =================================================
            -- PART 1: CREATE CHRONOLOGICAL PAST SALES
            -- =================================================

            -- 1. Calculate the *Initial* "Hype" Price for this item.
            -- This is the anchor for the *first* sale.
            SET v_base_price_multiplier = (0.8 + RAND() * 1.0); -- 80% - 180%
            IF v_brand_id IN (13, 19, 3, 6, 7) THEN -- Hype brands
                SET v_base_price_multiplier = (1.2 + RAND() * 1.8); -- 120% - 300%
            END IF;
            IF
                v_product_name LIKE '%Travis Scott%'
                   OR
                v_product_name LIKE '%(The Ten)%'
                    OR
                v_product_name LIKE '%(Lost & Found)%'
                    OR
                v_product_name LIKE '%Shattered Backboard%'
                    OR
                v_product_name LIKE 'SB Dunk High%'
                THEN
                SET v_base_price_multiplier = (2.5 + RAND() * 4.5); -- 250% - 700%
            END IF;

            -- Adjust multiplier based on condition
            IF v_product_condition = 'new' THEN
                SET v_initial_market_price = ROUND(v_retail_price * v_base_price_multiplier, 2);
            ELSEIF v_product_condition = 'used' THEN
                SET v_initial_market_price = ROUND(v_retail_price * v_base_price_multiplier * (0.5 + RAND() * 0.3), 2);
            ELSE -- 'worn'
                SET v_initial_market_price = ROUND(v_retail_price * v_base_price_multiplier * (0.2 + RAND() * 0.3), 2);
            END IF;

            -- This variable will be updated after each sale
            SET v_last_sale_price = v_initial_market_price;

            -- Set the starting time for the sales history
            SET v_current_timestamp = NOW() - INTERVAL 720 DAY;

            -- Loop 2: Create 15-30 sales for this item/size/condition
            SET num_sales_for_item = FLOOR(15 + RAND() * 16); -- 15 to 30
            SET v_time_increment_days = FLOOR(720 / num_sales_for_item); -- Avg days between sales

            SET sales_iterator = 0;
            WHILE sales_iterator < num_sales_for_item DO

                SET v_order_id = UUID();

                -- 1. Get random users
                SELECT uuid, first_name, last_name, b.balance
                INTO v_buyer_id, v_buyer_first_name, v_buyer_last_name, v_buyer_current_balance
                FROM users u
                JOIN account_balance b ON u.uuid = b.user_id
                ORDER BY RAND() LIMIT 1;

                SELECT uuid INTO v_seller_id
                FROM users WHERE uuid != v_buyer_id ORDER BY RAND() LIMIT 1;

                -- 2. Calculate NEW Sale Price (Random Walk)
                -- The new price is a slight variation (95% to 105%) of the *last* sale price.
                -- This creates a more realistic, trending price history.
                SET v_price_walk_multiplier = (0.95 + RAND() * 0.1); -- 0.95 to 1.05
                SET v_sale_price = ROUND(v_last_sale_price * v_price_walk_multiplier, 2);

                -- 3. Calculate fees
                SET v_seller_tx_fee = ROUND(v_sale_price * v_seller_fee_pct, 2);
                SET v_seller_final_payout = v_sale_price - v_seller_tx_fee;
                SET v_buyer_tx_fee = ROUND(v_sale_price * v_buyer_fee_pct, 2);
                SET v_buyer_final_price = v_sale_price + v_buyer_tx_fee;

                -- 4. Set chronological date
                SET v_current_timestamp = v_current_timestamp + INTERVAL (v_time_increment_days + FLOOR(RAND() * 5 - 2)) DAY;
                IF v_current_timestamp > NOW() THEN
                    SET v_current_timestamp = NOW() - INTERVAL 1 SECOND;
                END IF;

                -- 5. === INSERT into orders ===
                INSERT INTO orders (
                    order_id, buyer_id, seller_id, product_id, size_id, product_condition,
                    sale_price,
                    buyer_transaction_fee, buyer_fee_structure_id, buyer_final_price,
                    seller_transaction_fee, seller_fee_structure_id, seller_final_payout,
                    order_status, created_at, updated_at
                ) VALUES (
                    v_order_id, v_buyer_id, v_seller_id, v_product_id, v_size_id, v_product_condition,
                    v_sale_price,
                    v_buyer_tx_fee, v_fee_id, v_buyer_final_price,
                    v_seller_tx_fee, v_fee_id, v_seller_final_payout,
                    'completed', v_current_timestamp, v_current_timestamp
                );

                -- 6. === INSERT into addresses ===
                INSERT INTO addresses (
                    user_id, order_id, purpose, name,
                    address_line_1, city, state, zip_code, country
                ) VALUES (
                    v_buyer_id, v_order_id, 'shipping', CONCAT(v_buyer_first_name, ' ', v_buyer_last_name),
                    '123 Market St', 'Fakeville', 'CA', '90210', 'USA'
                );

                -- 7. === INSERT into listings ('sold') ===
                INSERT INTO listings (
                    user_id, product_id, size_id, listing_type, price,
                    fee_structure_id, item_condition, status, created_at, updated_at
                ) VALUES (
                    v_seller_id, v_product_id, v_size_id, 'sale', v_sale_price,
                    v_fee_id, v_product_condition, 'sold', v_current_timestamp, v_current_timestamp
                );

                -- 8. === INSERT into transactions (buyer) ===
                IF v_buyer_current_balance >= v_buyer_final_price THEN
                    SET v_payment_origin = 'account_balance';
                    UPDATE account_balance SET balance = balance - v_buyer_final_price WHERE user_id = v_buyer_id;
                ELSE
                    SET v_payment_origin = 'credit_card';
                END IF;

                INSERT INTO transactions (
                    user_id, order_id, amount, transaction_status,
                    payment_origin, payment_purpose, created_at
                ) VALUES (
                    v_buyer_id, v_order_id, -v_buyer_final_price, 'completed',
                    v_payment_origin, 'purchase_funds', v_current_timestamp
                );

                -- 9. === INSERT into transactions (seller) & UPDATE seller balance ===
                INSERT INTO transactions (
                    user_id, order_id, amount, transaction_status,
                    payment_destination, payment_purpose, created_at
                ) VALUES (
                    v_seller_id, v_order_id, v_seller_final_payout, 'completed',
                    'account_balance', 'sale_proceeds', v_current_timestamp + INTERVAL 1 DAY
                );
                UPDATE account_balance SET balance = balance + v_seller_final_payout WHERE user_id = v_seller_id;

                -- 10. === INSERT into portfolio_items ===
                INSERT INTO portfolio_items (
                    portfolio_item_id, user_id, product_id, size_id,
                    acquisition_date, acquisition_price, item_condition
                ) VALUES (
                    UUID(), v_buyer_id, v_product_id, v_size_id,
                    DATE(v_current_timestamp), v_sale_price, v_product_condition
                );

                -- 11. UPDATE v_last_sale_price FOR NEXT LOOP
                SET v_last_sale_price = v_sale_price;

                SET sales_iterator = sales_iterator + 1;
            END WHILE; -- End sales_iterator loop

            -- =================================================
            -- PART 2: CREATE ACTIVE BIDS & ASKS
            -- Use v_last_sale_price as the anchor
            -- =================================================

            -- Create 3-5 Active Asks
            SET v_num_active_asks = FLOOR(3 + RAND() * 3);
            SET v_active_loop_i = 0;
            WHILE v_active_loop_i < v_num_active_asks DO
                SELECT uuid INTO v_seller_id FROM users ORDER BY RAND() LIMIT 1;

                -- Ask price is 2% to 15% *above* the last sale price
                SET v_ask_price = ROUND(v_last_sale_price * (1.02 + RAND() * 0.13), 2);
                SET v_active_created_at = NOW() - INTERVAL FLOOR(RAND() * 30) DAY;

                INSERT INTO listings (
                    user_id, product_id, size_id, listing_type, price,
                    fee_structure_id, item_condition, status, created_at, updated_at
                ) VALUES (
                    v_seller_id, v_product_id, v_size_id, 'sale', v_ask_price,
                    v_fee_id, v_product_condition, 'active', v_active_created_at, v_active_created_at
                );

                SET v_active_loop_i = v_active_loop_i + 1;
            END WHILE;

            -- Create 3-5 Active Bids
            SET v_num_active_bids = FLOOR(3 + RAND() * 3);
            SET v_active_loop_i = 0;
            WHILE v_active_loop_i < v_num_active_bids DO
                SELECT uuid, b.balance
                INTO v_buyer_id, v_buyer_current_balance
                FROM users u
                JOIN account_balance b ON u.uuid = b.user_id
                ORDER BY RAND() LIMIT 1;

                -- Bid price is 2% to 15% *below* the last sale price
                SET v_bid_amount = ROUND(v_last_sale_price * (0.85 + RAND() * 0.13), 2);
                SET v_active_created_at = NOW() - INTERVAL FLOOR(RAND() * 30) DAY;

                SET v_buyer_tx_fee = ROUND(v_bid_amount * v_buyer_fee_pct, 2);
                SET v_total_bid_amount = v_bid_amount + v_buyer_tx_fee;

                IF v_buyer_current_balance >= v_total_bid_amount THEN
                    SET v_payment_origin = 'account_balance';
                ELSE
                    SET v_payment_origin = 'credit_card';
                END IF;

                INSERT INTO bids (
                    bid_id, user_id, product_id, size_id, product_condition,
                    bid_amount, transaction_fee, fee_structure_id, total_bid_amount,
                    bid_status, payment_origin, created_at, updated_at
                ) VALUES (
                    UUID(), v_buyer_id, v_product_id, v_size_id, v_product_condition,
                    v_bid_amount, v_buyer_tx_fee, v_fee_id, v_total_bid_amount,
                    'active', v_payment_origin, v_active_created_at, v_active_created_at
                );

                SET v_active_loop_i = v_active_loop_i + 1;
            END WHILE;


            SET cond_iterator = cond_iterator + 1;
        END WHILE; -- End cond_iterator loop

    END LOOP product_loop;

    CLOSE product_cursor;
END$$

DELIMITER ;


-- =================================================================
-- CALL THE NEW UNIFIED PROCEDURE
-- =================================================================

CALL CreateMarketHistory(); #completed in 2 h 28 m 24 s 373 ms
