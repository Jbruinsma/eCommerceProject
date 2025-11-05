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
(12, 'Nike Sportswear Phoenix Fleece Wide-Leg Sweatpants ''Black''', 'DQ5615-010', 'Black/Sail', 'Apparel - Pants', 70.00, NULL, '/products/DQ5615-010.jpg'),
(12, 'Nike Solo Swoosh Pullover Hoodie ''Fir/White''', 'DX1355-323', 'Fir/White', 'Apparel - Hoodie', 100.00, NULL, '/products/DX1355-323.avif'),
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
(19, 'Supreme x Swarovski Box Logo Hooded Sweatshirt ''Heather Grey''', 'SS19SW9 HEATHER GREY', 'Heather Grey', 'Apparel - Hoodie', 598.00, '2019-04-25', '/products/SS19SW9 HEATHER GREY'),
(19, 'Supreme x Swarovski Box Logo Hooded Sweatshirt ''Black''', 'SS19SW9 BLACK', 'Black', 'Apparel - Hoodie', 598.00, '2019-04-25', '/products/SS19SW9 BLACK'),
(19, 'Supreme x Swarovski Box Logo Hooded Sweatshirt ''Red''', 'SS19SW9 RED', 'Red', 'Apparel - Hoodie', 598.00, '2019-04-25', '/products/SS19SW9 RED'),
(19, 'Supreme x Swarovski Box Logo Tee ''White''', 'SS19T1 WHITE', 'White', 'Apparel - T-Shirt', 398.00, '2019-04-25', '/products/SS19T1 WHITE'),
(19, 'Supreme x Swarovski Box Logo Tee ''Black''', 'SS19T1 BLACK', 'Black', 'Apparel - T-Shirt', 398.00, '2019-04-25', '/products/SS19T1 BLACK'),
(19, 'Supreme x Nike Air Force 1 Low ''White''', 'CU9225-100', 'White/White', 'Sneakers', 124.00, '2020-03-05', '/products/CU9225-100.avif'),
(19, 'Supreme x Nike Air Force 1 Low ''Black''', 'CU9225-001', 'Black/Black-Black', 'Sneakers', 124.00, '2020-03-05', '/products/CU9225-001.avif'),
(19, 'Supreme x The North Face ''By Any Means Necessary'' Nuptse Jacket ''Black''', 'FW15J2 BLACK', 'Black', 'Apparel - Jacket', 368.00, '2015-11-19', '/products/FW15J2 BLACK'),
(19, 'Supreme x The North Face ''By Any Means Necessary'' Mountain Jacket ''Black''', 'FW15J1 BLACK', 'Black', 'Apparel - Jacket', 298.00, '2015-11-19', '/products/FW15J1 BLACK'),
(19, 'Supreme x The North Face ''Arc Logo'' Denali Fleece Jacket ''Red''', 'SS19J4 RED', 'Red', 'Apparel - Jacket', 268.00, '2019-03-28', '/products/SS19J4 RED'),
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
(4, 'BAPE Honeycomb Camo Shark Full Zip Hoodie ''Blue''', '1J30-115-009 BLUE', 'Blue', 'Apparel - Hoodie', 280.00, '2023-01-21', '/products/1J30-115-009 BLUE'),
(4, 'BAPE Honeycomb Camo Shark Full Zip Hoodie ''Grey''', '1J30-115-009 GREY', 'Grey', 'Apparel - Hoodie', 280.00, '2023-01-21', '/products/1J30-115-009 GREY'),
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
(18, 'Stüssy Personalities Tee ''Slate''', '1905120-SLAT', 'Slate', 'Apparel - T-Shirt', 45.00, NULL, '/products/1905120-SLAT.jpg'),
(18, 'Stüssy Authorized Tee ''Black''', '1905122-BLAC', 'Black', 'Apparel - T-Shirt', 45.00, '2025-09-06', '/products/1905122-BLAC.jpg'),
(18, 'Stüssy Speedway L/S Tee ''Black''', '1995123-BLAC', 'Black', 'Apparel - T-Shirt', 55.00, '2025-09-06', '/products/1995123-BLAC.jpg'),
(18, 'Stüssy Lazy L/S Tee ''Pale Yellow''', '1140333-PYEL', 'Pale Yellow', 'Apparel - T-Shirt', 60.00, NULL, '/products/1140333-PYEL.jpg'),
(18, 'Stüssy State Crew Hoodie ''Black''', '118596-BLAC', 'Black', 'Apparel - Crewneck', 145.00, NULL, '/products/118596-BLAC.jpg'),
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
(9, 'Kith Classic Logo Hoodie ''Sand''', NULL, 'Sand', 'Apparel - Hoodie', 150.00, '2017-12-04', NULL),
(9, 'Kith Classic Logo Hoodie ''Tiger Camo''', NULL, 'Tiger Camo', 'Apparel - Hoodie', 150.00, '2017-12-04', NULL),
(9, 'Kith Classic Logo Williams II Hoodie ''Heather Grey''', NULL, 'Heather Grey', 'Apparel - Hoodie', 160.00, '2018-11-26', NULL),
(9, 'Kith Retro Logo Tee ''White''', 'khm034785-101', 'White', 'Apparel - T-Shirt', 65.00, NULL, '/products/khm034785-101'),
(9, 'Kith Retro Logo Tee ''Black''', 'khm034785-001', 'Black', 'Apparel - T-Shirt', 65.00, NULL, '/products/khm034785-001'),
(9, 'Kith x Looney Tunes KithJam Vintage Tee ''Black''', 'KH3808-100', 'Black', 'Apparel - T-Shirt', 75.00, '2020-07-13', '/products/KH3808-100'),
(9, 'Kith x Disney Plush Through the Ages (Box set of 8)', '697', NULL, 'Accessory', 105.00, '2019-11-18', '/products/697'),
(9, 'Kith x ASICS Gel-Lyte III ''The Palette'' (Hallow)', '1201A224-253', 'Hallow', 'Sneakers', 180.00, '2020-11-27', '/products/1201A224-253'),
(9, 'Kith x Nike Air Force 1 Low ''Knicks Home''', 'CZ7928-100', 'White/Rush Blue/Brilliant Orange', 'Sneakers', 130.00, '2020-12-18', '/products/CZ7928-100'),
(9, 'Kith x New Balance 990v3 ''Daytona''', 'M990KH3', 'Daytona', 'Sneakers', 235.00, '2022-06-16', '/products/M990KH3'),
(9, 'Kith x New Balance 990v2 ''Cyclades''', 'M990KC2', 'Cyclades', 'Sneakers', 225.00, '2022-06-17', '/products/M990KC2'),
(9, 'Kith x New Balance 990v6 ''MSG (Sandrift)''', 'NBU990KN6', 'Sandrift/Methyl Blue', 'Sneakers', 220.00, '2023-11-06', '/products/NBU990KN6'),

-- Fear of God
(7, 'Fear of God Athletics Pullover Hoodie ''Black''', 'IM8935', 'Black', 'Apparel - Hoodie', 230.00, '2023-12-03', '/products/IM8935'),
(7, 'Fear of God Athletics Pullover Hoodie ''White''', 'IS5308', 'White', 'Apparel - Hoodie', 230.00, '2023-12-25', '/products/IS5308'),
(7, 'Fear of God Athletics Cotton Fleece Hoodie ''Cement''', 'KA4570', 'Cement', 'Apparel - Hoodie', 165.00, '2024-06-07', '/products/KA4570'),
(7, 'Fear of God Athletics Suede Fleece Hoodie ''Black''', 'KA4568', 'Black', 'Apparel - Hoodie', 280.00, '2023-12-03', '/products/KA4568'),
(7, 'Fear of God Athletics Running Leggings ''Black''', 'IT1932', 'Black', 'Apparel - Pants', 180.00, '2024-04-03', '/products/IT1932'),
(7, 'Fear of God Athletics Base Layer Running Tights ''Black''', 'IT1926', 'Black', 'Apparel - Pants', 150.00, '2024-04-03', '/products/IT1926'),
(7, 'Fear of God Athletics Mock Neck 3/4 Sleeve T-Shirt ''Black''', 'IS6839', 'Black', 'Apparel - T-Shirt', 180.00, '2023-12-03', '/products/IS6839'),
(7, 'Fear of God Essentials Vintage Fit Tee ''Jet Black''', '125SP254280F', 'Jet Black', 'Apparel - T-Shirt', 60.00, NULL, '/products/125SP254280F'),
(7, 'Fear of God Essentials Pullover Hoodie ''Off Black''', '0192250500017522', 'Off Black', 'Apparel - Hoodie', 100.00, NULL, '/products/0192250500017522'),
(7, 'Fear of God The California Slip-On ''Oat''', 'FG80-100EVA-991', 'Oat', 'Sneakers', 195.00, '2021-07-09', '/products/FG80-100EVA-991'),
(7, 'Fear of God The California Slip-On ''Cream''', 'FG80-100EVA-CRM', 'Cream', 'Sneakers', 195.00, '2021-07-09', '/products/FG80-100EVA-CRM'),
(7, 'Fear of God Athletics Adilette Slide Sandals ''Black''', NULL, 'Black', 'Sneakers', 100.00, NULL, NULL),

-- New Balance
(11, 'New Balance 9060 ''Rain Cloud''', 'U9060GRY', 'Rain Cloud/Castlerock/Grey', 'Sneakers', 159.99, '2022-08-13', '/products/U9060GRY'),
(11, 'New Balance 9060 ''Black Cat''', 'U9060BCG', 'Black/Phantom', 'Sneakers', 160.00, '2023-11-23', '/products/U9060BCG'),
(11, 'New Balance 9060 ''Mushroom''', 'U9060MUS', 'Mushroom/Aluminium/Grey', 'Sneakers', 159.99, '2023-08-04', '/products/U9060MUS'),
(11, 'New Balance 2002R ''Protection Pack - Rain Cloud''', 'M2002RDA', 'Rain Cloud/Phantom/Grey', 'Sneakers', 145.00, '2021-08-20', '/products/M2002RDA'),
(11, 'New Balance 2002R ''Arid Stone/Black Coffee''', 'M2002RCH', 'Arid Stone/Black Coffee/Moon Shadow', 'Sneakers', 145.00, '2024-03-21', '/products/M2002RCH'),
(11, 'New Balance 574 Core ''Grey''', 'ML574EVG', 'Grey/White', 'Sneakers', 99.99, '2018-01-01', '/products/ML574EVG'),
(11, 'New Balance 574 Core ''Navy''', 'ML574EVN', 'Navy/White', 'Sneakers', 99.99, '2018-01-01', '/products/ML574EVN'),
(11, 'New Balance Made in USA 993 ''Grey''', 'MR993GL', 'Grey/White', 'Sneakers', 199.99, '2008-01-01', '/products/MR993GL'),
(11, 'New Balance Made in USA 990v6 ''Grey''', 'M990GL6', 'Grey/White/Navy', 'Sneakers', 199.99, '2022-11-04', '/products/M990GL6'),
(11, 'New Balance 997H ''Team Red''', 'CM997HTR', 'Team Red/Pigment', 'Sneakers', 90.00, '2019-02-01', '/products/CM997HTR'),
(11, 'New Balance 580 ''Black''', 'MT580MBK', 'Black/White', 'Sneakers', 150.00, '2023-01-13', '/products/MT580MBK'),
(11, 'New Balance 57/40 ''White''', 'M5740PG1', 'White/Ghost Pepper', 'Sneakers', 100.00, '2021-01-29', '/products/M5740PG1'),
(11, 'New Balance Fresh Foam X 1080v14 ''White''', 'M1080W14', 'White/Sea Salt/Black', 'Sneakers', 164.99, '2024-03-01', '/products/M1080W14'),

-- ASICS
(2, 'ASICS GEL-KAYANO 14 ''White/Midnight''', '1201A019-107', 'White/Midnight', 'Sneakers', 150.00, '2022-08-01', '/products/1201A019-107'),
(2, 'ASICS GEL-KAYANO 14 ''White/Pure Silver''', '1201A019-108', 'White/Pure Silver', 'Sneakers', 150.00, '2023-11-17', '/products/1201A019-108'),
(2, 'ASICS GEL-1130 ''Clay Canyon''', '1201A256-200', 'Clay Canyon/Simply Taupe', 'Sneakers', 95.00, '2022-08-19', '/products/1201A256-200'),
(2, 'ASICS GEL-1130 ''White/Oatmeal''', '1201A256-120', 'White/Oatmeal', 'Sneakers', 100.00, '2023-08-10', '/products/1201A256-120'),
(2, 'ASICS GEL-1130 ''Black/Slate Grey''', '1201A256-004', 'Black/Slate Grey', 'Sneakers', 99.99, '2023-03-01', '/products/1201A256-004'),
(2, 'ASICS GEL-NYC ''White''', '1201A789-106', 'White/Steel Grey', 'Sneakers', 130.00, '2023-03-01', '/products/1201A789-106'),
(2, 'ASICS GEL-NYC ''Cream/Oyster Grey''', '1201A789-103', 'Cream/Oyster Grey', 'Sneakers', 140.00, '2023-01-13', '/products/1201A789-103'),
(2, 'ASICS GT-2160 ''White/Pure Silver''', '1203A275-102', 'White/Pure Silver', 'Sneakers', 130.00, '2023-07-07', '/products/1203A275-102'),
(2, 'ASICS GEL-LYTE III OG ''Hydrangea''', '1201A832-400', 'Hydrangea/Oyster Grey', 'Sneakers', 130.00, '2023-07-21', '/products/1201A832-400'),
(2, 'ASICS GEL-NIMBUS 9 ''White''', '1201A424-100', 'White/Pure Silver', 'Sneakers', 160.00, '2022-01-20', '/products/1201A424-100'),
(2, 'ASICS GEL-QUANTUM KINETIC ''Black''', '1203A270-001', 'Black/Black', 'Sneakers', 250.00, '2023-04-06', '/products/1203A270-001'),
(2, 'ASICS GEL-TERRAIN ''Black''', '1203A331-001', 'Black/Black', 'Sneakers', 120.00, '2023-11-10', '/products/1203A331-001'),
(2, 'ASICS SKYHAND OG ''White/Blue''', '1201A382-101', 'White/Directoire Blue', 'Sneakers', 100.00, '2021-08-01', '/products/1201A382-101'),

-- Salomon
(17, 'Salomon XT-6 ''White/Lunar Rock''', 'L41086700', 'White/Lunar Rock/White', 'Sneakers', 180.00, '2019-03-28', '/products/L41086700'),
(17, 'Salomon XT-6 GORE-TEX ''Black''', 'L41760300', 'Black/Ebony/Lunar Rock', 'Sneakers', 200.00, '2022-10-06', '/products/L41760300'),
(17, 'Salomon XT-6 ''Black/Phantom''', 'L41086600', 'Black/Black/Phantom', 'Sneakers', 180.00, '2021-03-01', '/products/L41086600'),
(17, 'Salomon XT-6 EXPANSE ''Almond Milk''', 'L47134200', 'Almond Milk/Moth/Vanilla Ice', 'Sneakers', 160.00, '2023-02-01', '/products/L47134200'),
(17, 'Salomon XT-4 OG ''Fiery Red''', 'L47024100', 'Fiery Red/Black/Empire Yellow', 'Sneakers', 190.00, '2023-03-01', '/products/L47024100'),
(17, 'Salomon XT-4 OG ''White''', 'L47024200', 'White/Ebony/Lunar Rock', 'Sneakers', 190.00, '2023-03-01', '/products/L47024200'),
(17, 'Salomon ACS Pro ''Black''', 'L47132200', 'Black/Black/Black', 'Sneakers', 200.00, '2022-09-01', '/products/L47132200'),
(17, 'Salomon ACS Pro ''Almond Milk/Cement''', 'L47432700', 'Almond Milk/Cement/Falcon', 'Sneakers', 230.00, '2024-02-01', '/products/L47432700'),
(17, 'Salomon ACS Pro LEATHER ''Black''', 'L47493600', 'Black/Black/Black', 'Sneakers', 200.00, '2024-03-14', '/products/L47493600'),
(17, 'Salomon XT-WINGS 2 ''Black''', 'L41085700', 'Black/Black/Magnet', 'Sneakers', 160.00, '2020-03-01', '/products/L41085700'),
(17, 'Salomon RX MOC 3.0 ''Black''', 'L47131000', 'Black/Black/Phantom', 'Sneakers', 100.00, '2023-01-20', '/products/L47131000'),
(17, 'Salomon Speedcross 3 ''Black''', 'L41765300', 'Black/Black/Quiet Shade', 'Sneakers', 140.00, '2022-08-01', '/products/L41765300'),
(17, 'Salomon XA Pro 3D v8 ''Black''', 'L41689800', 'Black/Black/Magnet', 'Sneakers', 130.00, '2020-01-01', '/products/L41689800'),

-- Vans
(20, 'Vans Premium Old Skool Black & White', 'VN000CQDBA2', 'Black & White', 'Sneaker', 90, '2025-01-24', '/products/VN000CQDBA2'),
(20, 'Vans Skate Old Skool 36+ Black White', 'VN000D5RBA2', 'Black/White', 'Sneaker', 80, '2025-01-30', '/products/VN000D5RBA2'),
(20, 'Vans Classic Slip-On ''Checkerboard'' (Black/White)', 'VN000EYEBWW', 'Black/White', 'Sneaker', NULL, '2022-06-01', '/products/VN000EYEBWW'),
(20, 'Vans Classic Slip-On ''Checkerboard'' (True White/True White)', 'VN000EYEX1L', 'True White/True White', 'Sneaker', NULL, NULL, '/products/VN000EYEX1L'),
(20, 'Vans Classic Slip-On ''Checkerboard'' (Black/Black)', 'VN000EYE276', 'Black/Black', 'Sneaker', NULL, NULL, '/products/VN000EYE276'),
(20, 'Vans Classic Slip-On ''Checkerboard'' (Black/Pewter)', 'VN000EYEBPJ', 'Black/Pewter', 'Sneaker', NULL, NULL, '/products/VN000EYEBPJ'),
(20, 'Vans Knu Skool ''Black / Port''', 'VN0009QC2Q1', 'Black / Port', 'Sneaker', NULL, '2024-06-01', '/products/VN0009QC2Q1'),
(20, 'Vans Knu Skool ''Black''', 'VN0009QCBKA', 'Black', 'Sneaker', NULL, '2024-06-01', '/products/VN0009QCBKA'),
(20, 'Vans Knu Skool ''Black/True White''', 'VN0009QC6BT', 'Black/True White', 'Sneaker', NULL, '2023-02-18', '/products/VN0009QC6BT'),
(20, 'Vans Sk8-Hi ''Black/White''', 'VN000D5IB8C', 'Black/ White', 'Sneaker', NULL, '2019-09-28', '/products/VN000D5IB8C'),
(20, 'Vans Authentic ''True White''', 'VN000EE3W00', 'True White', 'Sneaker', 55, '2024-06-01', '/products/VN000EE3W00'),
(20, 'Vans Authentic ''Black''', 'VN000EE3BLK', 'Black', 'Sneaker', NULL, '2022-06-01', '/products/VN000EE3BLK'),
(20, 'Vans Authentic ''Black Waffle Outsole''', 'VN000D8BBLK', 'Black', 'Sneaker', 80, '2025-01-10', '/products/VN000D8BBLK'),
(20, 'Vans Old Skool Platform ''Black/White''', 'VN0A3B3UY28', 'Black/White', 'Sneaker', NULL, '2018-02-28', '/products/VN0A3B3UY28'),
(20, 'Vans Old Skool ''Black/White'' (Classic)', 'VN000D3HY28', 'Black/White', 'Sneaker', NULL, '2022-05-31', '/products/VN000D3HY28'),
(20, 'Vans UltraRange 2.0 ''Black''', 'VN000D60BKA', 'Black', 'Sneaker', NULL, '2025-05-08', '/products/VN000D60BKA'),
(20, 'Vans Filmore High-Top Sneakers ''Black''', NULL, 'Black', 'Sneaker', NULL, NULL, NULL),

-- Converse
(5, 'Converse Chuck Taylor All Star Classic ''White'' (High Top)', 'M7650', 'Optic White', 'Sneaker', NULL, '2019-01-01', '/products/M7650'),
(5, 'Converse Run Star Hike Platform ''Black''', '166800C', 'Black/White/Gum', 'Sneaker', NULL, '2020-01-09', '/products/166800C'),
(5, 'Converse x CDG PLAY Chuck 70 ''Black'' (2015)', '150204C', 'Black/White', 'Sneaker', 150, '2015-05-14', '/products/150204C'),
(5, 'Converse x CDG PLAY Chuck 70 ''Black'' (2023)', 'A01793C', 'Black/Red/Egret', 'Sneaker', 150, '2023-02-14', '/products/A01793C'),
(5, 'Converse Chuck 70 Low Top ''Black''', '162058C-001', 'Black', 'Sneaker', 85, '2024-05-29', '/products/162058C-001'),
(5, 'Converse Chuck 70 High Top ''Parchment''', '162053C', 'Parchment/Garnet/Egret', 'Sneaker', 85, '2020-06-15', '/products/162053C'),
(5, 'Converse Chuck Taylor All Star Classic ''Black'' (Low Top)', 'M9166', 'Black', 'Sneaker', NULL, '2011-03-16', '/products/M9166'),
(5, 'Converse Chuck Taylor All Star Lift Platform ''White''', '560845F', 'White', 'Sneaker', 75, '2023-06-01', '/products/560845F'),
(5, 'Converse Chuck 70 High Top ''Black'' (Classic)', '162050C', 'Black', 'Sneaker', 90, '2018-02-28', '/products/162050C'),
(5, 'Converse Chuck Taylor All Star Lugged ''White''', '565902C', 'White/Black/White', 'Sneaker', NULL, '2020-01-14', '/products/565902C'),
(5, 'Converse One Star Academy Pro ''Black/White''', 'A08501C', 'Black/White', 'Sneaker', 95, '2024-08-02', '/products/A08501C'),
(5, 'Converse Jack Purcell ''White''', '164057C', 'White/White', 'Sneaker', NULL, '2019-05-01', '/products/164057C'),
(5, 'Converse x CDG PLAY Chuck 70 ''Parchment'' (2015)', '150205C', 'Milk', 'Sneaker', 150, '2015-05-14', '/products/150205C'),

-- Puma
(15, 'Puma Palermo ''Black-Feather Gray-Gum''', '397647-03', 'Black-Feather Gray-Gum', 'Sneaker', 90, '2023-09-01', '/products/397647-03'),
(15, 'Puma Palermo ''Black Feather Grey Gum''', '396464 03', 'Black/Feather Grey/Gum', 'Sneaker', 85, '2023-09-01', '/products/396464 03'),
(15, 'Puma x LaMelo Ball MB.01 ''Red'' (Not From Here)', '377237 02', 'Red Blast/Fiery Red', 'Sneaker', NULL, '2021-12-16', '/products/377237 02'),
(15, 'Puma x LaMelo Ball MB.01 ''Team Colors Red''', '376941-10', 'Team Colors Red', 'Sneaker', 120, '2022-07-13', '/products/376941-10'),
(15, 'Fenty x Puma Creeper Phatty ''Lavender Alert'' (Unisex)', '396403-03', 'Lavender Alert/Burnt Red-Gum', 'Sneaker', 140, '2023-11-30', '/products/396403-03'),
(15, 'Fenty x Puma Creeper Phatty ''Lavender Alert'' (Women)', '399332-03', 'Lavender Alert/Burnt Red-Gum', 'Sneaker', 140, '2023-11-30', '/products/399332-03'),
(15, 'Fenty x Puma Creeper Phatty ''Lavender Alert'' (GS)', '397587-03', 'Lavender Alert/Burnt Red-Gum', 'Sneaker', 100, '2023-11-30', '/products/397587-03'),
(15, 'Fenty x Puma Creeper Phatty ''Lavender Alert'' (PS)', '396830-03', 'Lavender Alert/Burnt Red/Gum', 'Sneaker', 75, '2023-11-30', '/products/396830-03'),
(15, 'Fenty x Puma Creeper Phatty ''Lavender Alert'' (TD)', '396829-03', 'Lavender Alert/Burnt Red-Gum', 'Sneaker', 65, '2023-11-30', '/products/396829-03'),
(15, 'Puma Suede Classic ''Team Regal Red''', '399781 05', 'Team Regal Red/White', 'Sneaker', NULL, '2025-03-31', '/products/399781 05'),
(15, 'Puma Suede XL ''Black Frosted Ivory''', '396057 01', 'Black/Frosted Ivory', 'Sneaker', NULL, '2024-01-06', '/products/396057 01'),
(15, 'Puma Suede XL ''Black/White''', '395205 02', 'Black/White', 'Sneaker', 100, '2018-04-08', '/products/395205 02'),
(15, 'Puma Speedcat ''Black/White''', '398846 01', 'Black/White', 'Sneaker', NULL, '2024-06-29', '/products/398846 01'),
(15, 'Puma x LaMelo Ball MB.01 ''Foot Locker 50th Anniversary''', '310506-01', 'Black/White-Gold', 'Sneaker', 120, '2024-09-09', '/products/310506-01'),
(15, 'Puma Suede Classic XXI ''Black/White''', '374915 01', 'Black/White', 'Sneaker', 70, '2021-02-19', '/products/374915 01'),
(15, 'Puma x LaMelo Ball MB.01 Lo ''Team Colors - Triple White''', '376941 04', 'Puma White/Silver', 'Sneaker', NULL, '2022-07-13', '/products/376941 04'),
(15, 'Fenty x Puma Creeper Phatty ''Speed Blue'' (Unisex)', '396403-02', 'Speed Blue/Lime Pow/Gum', 'Sneaker', 140, '2023-11-30', '/products/396403-02'),
(15, 'Fenty x Puma Creeper Phatty ''Speed Blue'' (Women)', '399332-02', 'Speed Blue/Lime Pow-Gum', 'Sneaker', 140, '2023-11-30', '/products/399332-02'),
(15, 'Fenty x Puma Creeper Phatty ''Speed Blue'' (GS)', '397587-02', 'Speed Blue/Lime Pow-Gum', 'Sneaker', 100, '2023-11-30', '/products/397587-02'),
(15, 'Fenty x Puma Creeper Phatty ''Totally Taupe''', '396813 01', 'Totally Taupe/Gold/Warm White', 'Sneaker', NULL, '2024-04-18', '/products/396813 01'),
(15, 'Fenty x Puma Creeper Phatty ''Warm White'' (Women)', '399865 03', 'Warm White/Gold/Gum', 'Sneaker', NULL, '2024-04-25', '/products/399865 03'),

-- Reebok
(16, 'Reebok Club C 85 Vintage ''Chalk/Glen Green''', '100000317', 'Chalk/Paperwhite/Glen Green', 'Sneaker', NULL, '2021-02-12', '/products/100000317'),
(16, 'Reebok Club C Revenge Vintage ''Chalk/Glen Green''', '100001283', 'Chalk/Paper White/Glen Green', 'Sneaker', 90, NULL, '/products/100001283'),
(16, 'White Mountaineering x Reebok Classic Leather ''Grey''', '100233213', 'Grey/White', 'Sneaker', 190, '2025-04-11', '/products/100233213'),
(16, 'White Mountaineering x Reebok Classic Leather ''Brown''', '100233214', 'Brown/White', 'Sneaker', 190, '2025-04-11', '/products/100233214'),
(16, 'Reebok Question Mid ''Red Toe'' (2024 Re-release)', '100074721', 'Footwear White/Vector Red/Footwear White', 'Sneaker', 170, '2024-02-16', '/products/100074721'),
(16, 'Reebok x JJJJOUND Club C ''Olive''', 'GX9657', 'White/Olive', 'Sneaker', 150, '2023-04-06', '/products/GX9657'),
(16, 'Reebok Classic Leather ''Black/Silver''', '100201810', 'Black/Silver/White', 'Sneaker', 130, '2024-10-23', '/products/100201810'),
(16, 'Reebok Club C 85 Vintage ''Footwear White/Barely Grey'' (Paperwhite)', '100033001', 'Cloud White/Pure Grey/Paperwhite', 'Sneaker', NULL, '2023-09-21', '/products/100033001'),
(16, 'Reebok Question Mid ''Banner''', 'M46120', 'Red/Royal/White/Gold Met', 'Sneaker', 160, '2014-03-15', '/products/M46120'),
(16, 'Reebok Club C Revenge ''White/Glen Green''', 'H04169', 'Footwear White/Glen Green/Footwear White', 'Sneaker', NULL, '2020-12-23', '/products/H04169'),
(16, 'Reebok Classic Leather ''White'' (Core)', '49797', 'White', 'Sneaker', NULL, '2022-01-01', '/products/49797'),
(16, 'Reebok Classic Leather ''Black'' (Core)', 'GY0955', 'Core Black/Core Black/Pure Grey 5', 'Sneaker', NULL, '2022-04-05', '/products/GY0955'),
(16, 'Reebok Premier Road Ultra ''Black''', 'RMIA06BC99MAT001 1019', 'Ultra Black', 'Sneaker', NULL, '2024-08-01', '/products/RMIA06BC99MAT001 1019'),
(16, 'Reebok Premier Road Ultra ''Black'' (LTD)', '100236667', 'Black', 'Sneaker', 170, '2024-11-22', '/products/100236667'),
(16, 'Reebok Nano X5 ''Black''', '100209359', 'Black/Grey 5/Reebok Lee 3', 'Sneaker', 140, '2025-01-24', '/products/100209359'),
(16, 'Reebok ERS World Shoes ''Barely Grey''', NULL, 'Barely Grey', 'Sneaker', NULL, '2025-07-29', NULL),
(16, 'Reebok Phase Court ''White''', '100201248', 'White/Chalk/Kinetic Blue', 'Sneaker', 85, '2024-06-01', '/products/100201248'),

-- Dior
(6, 'Dior B27 Low-Top Sneaker ''White Dior Oblique''', '3SN272ZAY_H000', 'White Grained Calfskin', 'Sneaker', NULL, '2020-10-30', '/products/3SN272ZAY_H000'),
(6, 'Dior B27 Low-Top Sneaker ''Brown''', '3SN272AAH_H758', 'Deep Brown Suede', 'Sneaker', NULL, '2020-10-30', '/products/3SN272AAH_H758'),
(6, 'Dior B57 Dribble Low-Top Sneaker ''Black/White Oblique''', '3SN318ZXU_H960', 'Black/White', 'Sneaker', 1250, '2024-04-15', '/products/3SN318ZXU_H960'),
(6, 'Dior Oblique Hooded Sweatshirt ''Navy Blue'' (Quilted)', '513J626A0978_C540', 'Navy Blue', 'Hooded Sweatshirt', 2250, NULL, '/products/513J626A0978_C540'),
(6, 'Dior Oblique Hooded Sweatshirt ''Navy Blue'' (Jacquard)', '113J631A0684_C540', 'Navy Blue', 'Hooded Sweatshirt', 2100, NULL, '/products/113J631A0684_C540'),
(6, 'Dior T-Shirt with Bee Embroidery ''Black''', '733J603B0677_C980', 'Black', 'T-Shirt', 660, NULL, '/products/733J603B0677_C980'),
(6, 'Dior T-Shirt with Bee Embroidery ''White''', '733J603B0677_C089', 'White', 'T-Shirt', 660, NULL, '/products/733J603B0677_C089'),
(6, 'Dior Chrono Sneaker ''White Mesh''', 'KCK473TXX_S46W', 'White Mesh/Silver-Tone', 'Sneaker', 1250, '2024-05-30', '/products/KCK473TXX_S46W'),
(6, 'Dior Chrono Sneaker ''Gray Mesh/Suede''', 'KCK414SUH_S20G', 'Gray Mesh/Suede Calfskin', 'Sneaker', NULL, '2024-05-30', '/products/KCK414SUH_S20G'),
(6, 'Dior Vibe Sneaker ''Gray Dior Oblique''', 'KCK365OBU_S47W', 'Gray Dior Oblique', 'Sneaker', 1190, NULL, '/products/KCK365OBU_S47W'),
(6, 'Dior B101 Slip-On Sneaker ''White'' (Cream Greige)', '3SN285ZRH H068', 'Cream/Greige/White', 'Sneaker', NULL, '2022-08-25', '/products/3SN285ZRH H068'),
(6, 'Dior B23 High-Top Sneaker ''Dior Oblique Canvas''', '3SH118YJP_H960', 'Black/White Dior Oblique', 'Sneaker', 1050, '2020-03-02', '/products/3SH118YJP_H960'),
(6, 'Dior Oblique Sweater ''Black Cotton Jacquard''', '513M634A7003_C901', 'Black', 'Sweater', 2250, NULL, '/products/513M634A7003_C901'),
(6, 'Dior Oblique Hooded Sweatshirt ''Black'' (Quilted)', '513J626A0978_C900', 'Black', 'Hooded Sweatshirt', 2250, NULL, '/products/513J626A0978_C900'),

-- Maison Margiela
(10, 'Maison Margiela Replica GAT ''White Painter''', 'S57WS0240P1892-961', 'White/Gum/Multi', 'Sneaker', 650.00, '2022-12-20', '/products/S57WS0240P1892-961.jpg'),
(10, 'Maison Margiela Replica GAT', 'S57WS0236P1895101', 'Grey/White/Gum', 'Sneaker', 540.00, '2020-04-30', '/products/S57WS0236P1895101.jpg'),
(10, 'Maison Margiela Paint Replica GAT ''Black''', 'S57WS0240P1892963', 'Black', 'Sneaker', 680.00, '2024-03-19', '/products/S57WS0240P1892963.jpg'),
(10, 'Maison Margiela Replica GAT ''Black Gum''', 'S57WS0236P1895H6851', 'Black/Gum', 'Sneaker', 495.00, '2019-06-29', '/products/S57WS0236P1895H6851.jpg'),
(10, 'Maison Margiela ''AIDS'' T-Shirt ''Black'' (Women''s V-Neck)', 'S62GD0203M20108100', 'Black', 'T-Shirt', NULL, '1993-09-01', '/products/S62GD0203M20108100'),
(10, 'Maison Margiela ''AIDS'' T-Shirt ''Black'' (Men''s)', 'S50GC0663', 'Black', 'T-Shirt', 380, '2019-01-01', '/products/S50GC0663'),
(10, 'Maison Margiela 4-Stitch Logo Hoodie ''Black''', 'S50HG0048S25614105M', 'Black', 'Hooded Sweatshirt', NULL, NULL, '/products/S50HG0048S25614105M'),
(10, 'Maison Margiela 4-Stitch Logo Hoodie ''Black'' (Reverse Embroidery)', 'S50HG0046S25520960', 'Black', 'Hooded Sweatshirt', NULL, NULL, '/products/S50HG0046S25520960'),
(10, 'Maison Margiela 4-Stitch Logo Hoodie ''Black'' (Reverse Logo)', 'S50GU0216S25570860', 'Black', 'Hooded Sweatshirt', NULL, NULL, '/products/S50GU0216S25570860'),
(10, 'Maison Margiela Replica GAT ''Dirty Wash''', 'S37WS0562P3724H8339', 'Dirty Wash', 'Sneaker', 590.00, NULL, '/products/S37WS0562P3724H8339.jpg'),
(10, 'Maison Margiela 50-50 Sneakers ''Black''', 'S57WS0444P4760 H9195', 'Black', 'Sneaker', NULL, '2024-10-07', '/products/S57WS0444P4760 H9195'),
(10, 'Maison Margiela 4-Stitch T-Shirt ''Grey''', 'S50GC0646 S23883 855', 'Grey', 'T-Shirt', NULL, NULL, '/products/S50GC0646 S23883 855'),
(10, 'Maison Margiela 4-Stitch T-Shirt ''Black'' (Reverse Embroidery)', 'S50GC0703S23883960', 'Black', 'T-Shirt', NULL, NULL, '/products/S50GC0703S23883960'),
(10, 'Maison Margiela 4-Stitch T-Shirt ''Black'' (Reverse Embroidery, Women''s)', 'S51GC0526S20079970', 'Black', 'T-Shirt', NULL, NULL, '/products/S51GC0526S20079970'),
(10, 'Maison Margiela Low-Profile Leather Sneakers ''White''', 'S57WS0236 P1897 101', 'White/Grey', 'Sneaker', NULL, '2020-11-02', '/products/S57WS0236 P1897 101'),
(10, 'Maison Margiela Frayed-Edges Distressed Sneakers ''Black''', 'S39WS0129P7454HB129', 'Blue and Black', 'Sneaker', 1050, '2025-10-20', '/products/S39WS0129P7454HB129'),
(10, 'Maison Margiela Embroidered Logo T-shirt ''White''', 'S50GC0644', 'White', 'T-Shirt', 430, '2024-02-14', '/products/S50GC0644');

INSERT INTO products_sizes (product_id, size_id)
SELECT p.product_id, s.size_id
FROM products p
CROSS JOIN sizes s
WHERE
    p.product_type = 'Sneakers'
    AND s.size_id BETWEEN 11 AND 20;


INSERT INTO products_sizes (product_id, size_id)
SELECT p.product_id, s.size_id
FROM products p
CROSS JOIN sizes s
WHERE
    p.product_type LIKE 'Apparel%'
    AND s.size_id BETWEEN 21 AND 26;

INSERT INTO products_sizes (product_id, size_id)
SELECT p.product_id, s.size_id
FROM products p
CROSS JOIN sizes s
WHERE
    p.product_type = 'Sandals'
    AND s.size_id BETWEEN 11 AND 20;


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

-- =================================================================
-- PROCEDURE 1: CreatePastSales (*** NOW CHECKS BALANCE ***)
-- Creates N completed sales. Checks if buyer has enough balance.
-- If not, uses 'credit_card' as origin and does not debit account.
-- =================================================================

DROP PROCEDURE IF EXISTS CreatePastSales;

DELIMITER $$

CREATE PROCEDURE CreatePastSales(IN num_sales INT)
BEGIN
    DECLARE i INT DEFAULT 0;

    -- Order variables
    DECLARE v_order_id CHAR(36);
    DECLARE v_buyer_id CHAR(36);
    DECLARE v_seller_id CHAR(36);
    DECLARE v_buyer_first_name VARCHAR(100);
    DECLARE v_buyer_last_name VARCHAR(100);
    DECLARE v_product_id INT UNSIGNED;
    DECLARE v_size_id INT UNSIGNED;
    DECLARE v_product_condition ENUM('new', 'used', 'worn');
    DECLARE v_retail_price DECIMAL(10, 2);
    DECLARE v_sale_price DECIMAL(10, 2);

    -- Fee variables
    DECLARE v_fee_id INT UNSIGNED DEFAULT 1;
    DECLARE v_seller_fee_pct DECIMAL(10, 4);
    DECLARE v_buyer_fee_pct DECIMAL(10, 4);
    DECLARE v_buyer_tx_fee DECIMAL(10, 2);
    DECLARE v_buyer_final_price DECIMAL(10, 2);
    DECLARE v_seller_tx_fee DECIMAL(10, 2);
    DECLARE v_seller_final_payout DECIMAL(10, 2);

    -- NEW: Balance check variables
    DECLARE v_buyer_current_balance DECIMAL(15, 2);
    DECLARE v_payment_origin ENUM('account_balance', 'credit_card', 'other');

    -- Other
    DECLARE v_order_status ENUM('pending', 'paid', 'shipped', 'completed', 'cancelled', 'refunded');
    DECLARE v_created_at DATETIME;

    -- Get fee percentages from the table
    SELECT seller_fee_percentage, buyer_fee_percentage
    INTO v_seller_fee_pct, v_buyer_fee_pct
    FROM fee_structures WHERE id = v_fee_id;

    WHILE i < num_sales DO
        SET v_order_id = UUID();

        -- 1. Get random users
        SELECT uuid, first_name, last_name, b.balance
        INTO v_buyer_id, v_buyer_first_name, v_buyer_last_name, v_buyer_current_balance
        FROM users u
        JOIN account_balance b ON u.uuid = b.user_id
        ORDER BY RAND() LIMIT 1;

        SELECT uuid INTO v_seller_id
        FROM users WHERE uuid != v_buyer_id ORDER BY RAND() LIMIT 1;

        -- 2. Get random product/size combo
        SELECT ps.product_id, ps.size_id, p.retail_price
        INTO v_product_id, v_size_id, v_retail_price
        FROM products_sizes ps
        JOIN products p ON ps.product_id = p.product_id
        ORDER BY RAND() LIMIT 1;

        IF v_retail_price IS NULL OR v_retail_price = 0 THEN
            SET v_retail_price = 150.00;
        END IF;

        -- 3. Calculate sale price
        SET v_sale_price = ROUND(v_retail_price * (0.7 + RAND() * 1.8), 2);

        -- 4. Set condition and status
        SET v_product_condition = ELT(FLOOR(1 + RAND() * 3), 'new', 'used', 'worn');
        SET v_order_status = 'completed';

        -- 5. Calculate fees
        SET v_seller_tx_fee = ROUND(v_sale_price * v_seller_fee_pct, 2);
        SET v_seller_final_payout = v_sale_price - v_seller_tx_fee;
        SET v_buyer_tx_fee = ROUND(v_sale_price * v_buyer_fee_pct, 2);
        SET v_buyer_final_price = v_sale_price + v_buyer_tx_fee;

        -- 6. Set random date
        SET v_created_at = NOW() - INTERVAL FLOOR(RAND() * 730) DAY - INTERVAL FLOOR(RAND() * 86400) SECOND;

        -- 7. === INSERT into orders ===
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
            v_order_status, v_created_at, v_created_at
        );

        -- 8. === INSERT into addresses ===
        INSERT INTO addresses (
            user_id, order_id, purpose, name,
            address_line_1, city, state, zip_code, country
        ) VALUES (
            v_buyer_id, v_order_id, 'shipping', CONCAT(v_buyer_first_name, ' ', v_buyer_last_name),
            '123 Market St', 'Fakeville', 'CA', '90210', 'USA'
        );

        -- 9. === INSERT into listings ===
        INSERT INTO listings (
            user_id, product_id, size_id, listing_type, price,
            fee_structure_id, item_condition, status, created_at, updated_at
        ) VALUES (
            v_seller_id, v_product_id, v_size_id, 'sale', v_sale_price,
            v_fee_id, v_product_condition, 'sold', v_created_at, v_created_at
        );

        -- 10. === INSERT into transactions (buyer) ===
        -- *** NEW LOGIC: Check balance to determine payment origin ***
        IF v_buyer_current_balance >= v_buyer_final_price THEN
            SET v_payment_origin = 'account_balance';

            -- Debit the buyer's account
            UPDATE account_balance
               SET balance = balance - v_buyer_final_price
             WHERE user_id = v_buyer_id;
        ELSE
            SET v_payment_origin = 'credit_card';
            -- No update to account_balance, as it's a "credit card" purchase
        END IF;

        INSERT INTO transactions (
            user_id, order_id, amount, transaction_status,
            payment_origin, payment_purpose, created_at
        ) VALUES (
            v_buyer_id, v_order_id, -v_buyer_final_price, 'completed',
            v_payment_origin, 'purchase_funds', v_created_at
        );

        -- 11. === INSERT into transactions (seller) & UPDATE seller balance ===
        INSERT INTO transactions (
            user_id, order_id, amount, transaction_status,
            payment_destination, payment_purpose, created_at
        ) VALUES (
            v_seller_id, v_order_id, v_seller_final_payout, 'completed',
            'account_balance', 'sale_proceeds', v_created_at + INTERVAL 1 DAY
        );

        -- Credit the seller's account (this was already correct)
        UPDATE account_balance
           SET balance = balance + v_seller_final_payout
         WHERE user_id = v_seller_id;

        -- 12. === INSERT into portfolio_items ===
        INSERT INTO portfolio_items (
            portfolio_item_id, user_id, product_id, size_id,
            acquisition_date, acquisition_price, item_condition
        ) VALUES (
            UUID(), v_buyer_id, v_product_id, v_size_id,
            DATE(v_created_at), v_sale_price, v_product_condition
        );

        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;


-- =================================================================
-- PROCEDURE 2: CreateActiveListings
-- (No changes needed here)
-- =================================================================

DROP PROCEDURE IF EXISTS CreateActiveListings;

DELIMITER $$

CREATE PROCEDURE CreateActiveListings(IN num_listings INT)
BEGIN
    DECLARE i INT DEFAULT 0;

    DECLARE v_seller_id CHAR(36);
    DECLARE v_product_id INT UNSIGNED;
    DECLARE v_size_id INT UNSIGNED;
    DECLARE v_retail_price DECIMAL(10, 2);
    DECLARE v_ask_price DECIMAL(10, 2);
    DECLARE v_fee_id INT UNSIGNED DEFAULT 1;
    DECLARE v_created_at DATETIME;

    WHILE i < num_listings DO
        -- 1. Get random user and product
        SELECT uuid INTO v_seller_id FROM users ORDER BY RAND() LIMIT 1;

        SELECT ps.product_id, ps.size_id, p.retail_price
        INTO v_product_id, v_size_id, v_retail_price
        FROM products_sizes ps
        JOIN products p ON ps.product_id = p.product_id
        ORDER BY RAND() LIMIT 1;

        IF v_retail_price IS NULL OR v_retail_price = 0 THEN
            SET v_retail_price = 150.00;
        END IF;

        -- 2. Calculate realistic ask price
        SET v_ask_price = ROUND(v_retail_price * (0.9 + RAND() * 2.0), 2);

        -- 3. Set random creation date
        SET v_created_at = NOW() - INTERVAL FLOOR(RAND() * 60) DAY;

        -- 4. === INSERT into listings (active 'ask') ===
        INSERT INTO listings (
            user_id, product_id, size_id, listing_type, price,
            fee_structure_id, item_condition, status, created_at, updated_at
        ) VALUES (
            v_seller_id, v_product_id, v_size_id, 'sale', v_ask_price,
            v_fee_id, ELT(FLOOR(1 + RAND() * 3), 'new', 'used', 'worn'), 'active', v_created_at, v_created_at
        );

        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;


-- =================================================================
-- PROCEDURE 3: CreateActiveBids (*** NOW CHECKS BALANCE ***)
-- Creates N active 'bids'. Checks if buyer has enough balance.
-- If not, uses 'credit_card' as origin.
-- =================================================================

DROP PROCEDURE IF EXISTS CreateActiveBids;

DELIMITER $$

CREATE PROCEDURE CreateActiveBids(IN num_bids INT)
BEGIN
    DECLARE i INT DEFAULT 0;

    DECLARE v_buyer_id CHAR(36);
    DECLARE v_product_id INT UNSIGNED;
    DECLARE v_size_id INT UNSIGNED;
    DECLARE v_retail_price DECIMAL(10, 2);
    DECLARE v_bid_amount DECIMAL(10, 2);

    -- Fee variables
    DECLARE v_fee_id INT UNSIGNED DEFAULT 1;
    DECLARE v_buyer_fee_pct DECIMAL(10, 4);
    DECLARE v_buyer_tx_fee DECIMAL(10, 2);
    DECLARE v_total_bid_amount DECIMAL(10, 2);
    DECLARE v_created_at DATETIME;

    -- NEW: Balance check variables
    DECLARE v_buyer_current_balance DECIMAL(15, 2);
    DECLARE v_payment_origin ENUM('account_balance', 'credit_card', 'other');

    -- Get fee percentage
    SELECT buyer_fee_percentage
    INTO v_buyer_fee_pct
    FROM fee_structures WHERE id = v_fee_id;

    WHILE i < num_bids DO
        -- 1. Get random user and product
        SELECT uuid, b.balance
        INTO v_buyer_id, v_buyer_current_balance
        FROM users u
        JOIN account_balance b ON u.uuid = b.user_id
        ORDER BY RAND() LIMIT 1;

        SELECT ps.product_id, ps.size_id, p.retail_price
        INTO v_product_id, v_size_id, v_retail_price
        FROM products_sizes ps
        JOIN products p ON ps.product_id = p.product_id
        ORDER BY RAND() LIMIT 1;

        IF v_retail_price IS NULL OR v_retail_price = 0 THEN
            SET v_retail_price = 150.00;
        END IF;

        -- 2. Calculate realistic bid price
        SET v_bid_amount = ROUND(v_retail_price * (0.6 + RAND() * 0.9), 2);

        -- 3. Calculate total bid amount with fees
        SET v_buyer_tx_fee = ROUND(v_bid_amount * v_buyer_fee_pct, 2);
        SET v_total_bid_amount = v_bid_amount + v_buyer_tx_fee;

        -- *** NEW LOGIC: Check balance to determine payment origin ***
        IF v_buyer_current_balance >= v_total_bid_amount THEN
            SET v_payment_origin = 'account_balance';
        ELSE
            SET v_payment_origin = 'credit_card';
        END IF;

        -- 4. Set random creation date
        SET v_created_at = NOW() - INTERVAL FLOOR(RAND() * 30) DAY;

        -- 5. === INSERT into bids (active 'bid') ===
        INSERT INTO bids (
            bid_id, user_id, product_id, size_id, product_condition,
            bid_amount, transaction_fee, fee_structure_id, total_bid_amount,
            bid_status, payment_origin, created_at, updated_at
        ) VALUES (
            UUID(), v_buyer_id, v_product_id, v_size_id, ELT(FLOOR(1 + RAND() * 3), 'new', 'used', 'worn'),
            v_bid_amount, v_buyer_tx_fee, v_fee_id, v_total_bid_amount,
            'active', v_payment_origin, v_created_at, v_created_at -- Use v_payment_origin
        );

        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;


-- =================================================================
-- CALL PROCEDURES
-- =================================================================

CALL CreatePastSales(10000);
CALL CreateActiveListings(2000);
CALL CreateActiveBids(1500);