USE ecommerce;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE account_balance;
TRUNCATE TABLE users;
TRUNCATE TABLE brands;
TRUNCATE TABLE sizes;
TRUNCATE TABLE products;
TRUNCATE TABLE products_sizes;

SET FOREIGN_KEY_CHECKS = 1;

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

-- Run the procedure
CALL InsertDummyUsers();

INSERT INTO account_balance (user_id)
SELECT uuid FROM users;

INSERT INTO brands (brand_id, brand_name, brand_logo_url) VALUES
(1, 'Adidas', '/images/adidasLogo.png'),
(2, 'ASICS', '/images/AsicsLogo.png'),
(3, 'Balenciaga', '/images/BalenciagaLogo.png'),
(4, 'BAPE', '/images/BapeLogo.webp'),
(5, 'Converse', '/images/ConverseLogo.png'),
(6, 'Dior', '/images/DiorLogo.png'),
(7, 'Fear of God', '/images/FearOfGodLogo.png'),
(8, 'Jordan Brand', '/images/JordanLogo.png'),
(9, 'Kith', '/images/KithLogo.png'),
(10, 'Maison Margiela', '/images/MaisonMargielaLogo.png'),
(11, 'New Balance', '/images/NewBalanceLogo.png'),
(12, 'Nike', '/images/NikeLogo.svg'),
(13, 'Off-White', '/images/OffWhiteLogo.svg'),
(14, 'Palace', '/images/PalaceLogo.webp'),
(15, 'Puma', '/images/PumaLogo.svg'),
(16, 'Reebok', '/images/ReebokLogo.png'),
(17, 'Salomon', '/images/SalomonLogo.svg'),
(18, 'Stüssy', '/images/StussyLogo.png'),
(19, 'Supreme', '/images/SupremeLogo.png'),
(20, 'Vans', '/images/VansLogo.png');

INSERT INTO sizes (size_id, size_value) VALUES
(1, '4'), (2, '4.5'), (3, '5'), (4, '5.5'), (5, '6'), (6, '6.5'), (7, '7'), (8, '7.5'), (9, '8'), (10, '8.5'),
(11, '9'), (12, '9.5'), (13, '10'), (14, '10.5'), (15, '11'), (16, '11.5'), (17, '12'), (18, '13'), (19, '14'), (20, '15'),
(21, 'XS'), (22, 'S'), (23, 'M'), (24, 'L'), (25, 'XL'), (26, 'XXL');

INSERT INTO Products (brand_id, name, sku, colorway, product_type, retail_price, release_date) VALUES
-- Nike
(12, 'Nike Air Force 1 ''07 ''Triple White''', 'DD8959-100', 'White/White/White/White', 'Sneakers', 115.00, '2020-12-21'),
(12, 'Nike Dunk Low ''Panda'' (Black/White)', 'DD1391-100', 'White/White/Black', 'Sneakers', 115.00, '2021-03-09'),
(12, 'Nike Air Max 270 ''Black''', 'AH8050-005', ' Black/Black/Black', 'Sneakers', 170.00, '2018-03-16'),
(12, 'Nike Zoom Vomero 5 ''White/Metallic Silver''', 'IM2219-121', 'Summit White/Light Smoke Grey/Smoke Grey/Metallic Silver', '''Sneakers', 170.00, '2025-08-05'),
(12, 'Nike P-6000 ''White/Silver''', 'CN0149-001', 'Metallic Silver/Sail/Black/Metallic Silver', '''Sneakers', 115.00, '2023-10-06'),
(12, 'Nike Tech Fleece Windrunner Full-Zip Jacket ''Grey''', 'FB7921-063', 'Dark Grey Heather/Black', 'Apparel - Jacket', 135.00, '2023-08-12'),
(12, 'Nike Tech Fleece Joggers ''Grey''', 'HV0959-063', 'Dark Grey Heather/Black', 'Apparel - Pants', 125.00, '2025-09-10'),
(12, 'Nike Sportswear Phoenix Fleece Wide-Leg Sweatpants ''Black''', 'IH1011-010', 'IH1011-010', 'Apparel - Pants', 80.00, NULL),
(12, 'Nike Solo Swoosh Pullover Hoodie ''Black''', 'HV1082-010', 'Black/Black/White', 'Apparel - Hoodie', 85.00, NULL),
(12, 'Nike Air Max 1 ''86 OG ''Big Bubble''', 'DQ3989-100', 'White/University Red-Neutral Grey-Black', 'Sneakers', 150.00, '2023-03-26'),
(12, 'Nike Air Max 90 ''Infrared''', 'CT1685-100', 'White/Black-Cool Grey-Radiant Red', 'Sneakers', 135.00, '2020-11-09'),
(12, 'Nike Sportswear Club Fleece Crew ''Grey''', 'BV2662-063', 'Dark Grey Heather/White', '''Apparel - Crewneck', 70.00, '2022-01-26'),
(12, 'Nike V2K Run ''Metallic Silver''', 'FD0736-100', 'Summit White/Pure Platinum/Light Iron Ore/Metallic Silver', '''Sneakers', 110.00, '2023-09-28'),
-- Adidas
(1, 'Adidas Samba OG ''White/Black''', 'BZ0057', 'Cloud White/Core Black/Clear Granite', 'Sneakers', 110.00, '2018-01-01'),
(1, 'Adidas Gazelle Bold Shoes ''Core Black''', 'BB5476', 'Core Black/White/Gold Metallic', 'Sneakers', 120.00, '2018-05-01'),
(1, 'Adidas Originals Satin Wide Leg Pants ''Black''', 'JF3604', 'Black/White', 'Apparel - Pants', 70.00, '2025-03-14'),
(1, 'Adidas Stan Smith ''White/Green''', 'M20324', 'Running White/Running White/Fairway', 'Sneakers', 100.00, '2014-01-15'),
(1, 'Adidas Ultraboost 22 ''Core Black''', 'GZ0127', 'Core Black/Core Black/Core Black', 'Sneakers', 190.00, '2021-12-09'),
(1, 'Adidas NMD_R1 ''Core Black''', 'GZ9256', 'Core Black/Core Black/Core Black', 'Sneakers', 140.00, '2021-06-06'),
(1, 'Adidas Adilette Slides ''Black Scarlet''', 'ID4925', 'Core Black/Core Black/Better Scarlet', 'Sandals', 50.00, '2023-06-15'),
(1, 'Adidas Superstar ''White/Black''', 'EG4958', 'Cloud White/Core Black/Cloud White', 'Sneakers', 100.00, '2019-12-01'),
(1, 'Adidas Gazelle Indoor ''Blue''', 'JI2061', 'Blue Bird/Cloud White/Gum', 'Sneakers', 120.00, '2024-01-30'),
(1, 'Adidas Campus 00s ''Core Black''', 'HQ8708', 'Core Black/Footwear White/Off White', 'Sneakers', 110.00, '2023-02-14'),
(1, 'adidas Fear of God Athletics Basketball 2 "Ash Silver"', 'JS0979', 'Ash Silver/Ash Silver/Ash Silver', 'Sneakers', 180.00, '2025-09-17'),
(1, 'Bad Bunny x adidas Adiracer GT', 'HQ2570', 'Branch/Sand/Cinder', 'Sneakers', 160.00, '2025-10-24'),

-- Jordan
(8, 'Air Jordan 1 Retro High OG ''Chicago'' (Lost & Found)', 'DZ5485-612', 'Varsity Red/Black/Sail/Muslin', 'Sneakers', 180.00, '2022-11-19'),
(8, 'Air Jordan 1 Retro High OG ''Shattered Backboard''', '555088-005', 'Black/Starfish-Sail', 'Sneakers', 160.00, '2015-06-27'),
(8, 'Air Jordan 3 Retro ''White Cement'' (Reimagined)', 'DN3707-100', 'Summit White/Fire Red/Black/Cement Grey', 'Sneakers', 210.00, '2023-03-11'),
(8, 'Air Jordan 4 Retro ''Bred'' (Reimagined)', 'FV5029-006', 'Black/Fire Red/Cement Grey/Summit White', 'Sneakers', 215.00, '2024-02-17'),
(8, 'Air Jordan 11 Retro ''Concord'' (2018)', '378037-100', 'White/Black-Dark Concord', 'Sneakers', 220.00, '2018-12-08'),
(8, 'Air Jordan 5 Retro ''Fire Red'' (2020)', 'DA1911-102', 'White/Black-Metallic Silver-Fire Red', 'Sneakers', 200.00, '2020-05-02'),
(8, 'Air Jordan 4 Retro ''Black Cat'' (2025)', 'FV5029-010', 'Black/Black-Light Graphite', 'Sneakers', 225.00, '2025-11-28'),
(8, 'Air Jordan 1 Mid ''White/Black''', 'DQ8426-132', 'White/Black-White-Black', 'Sneakers', 125.00, '2023-12-12'),
(8, 'Air Jordan 3 Retro ''El Vuelo''', 'IO1752-100', 'Summit White/Metallic Gold/Pine Green/Dragon Red/Sail', 'Sneakers', 230.00, '2025-09-16'),
(8, 'Air Jordan 1 Retro High OG ''Pro Green'' (Women''s)', 'FD2596-101', 'Pale Ivory/Pro Green-Fir-Coconut Milk', 'Sneakers', 185.00, '2025-10-18'),
(8, 'Air Jordan 1 Retro Low OG ''Black Toe''', 'CZ0790-106', 'White/Black/Varsity Red', 'Sneakers', 140.00, '2023-08-04'),
(8, 'A Ma Maniére x Air Jordan 4 ''Dark Mocha''', 'IF3102-200', 'Dark Mocha/Bronze Eclipse/Black/Violet Ore', 'Sneakers', 225.00, '2025-12-12'),
(8, 'Travis Scott x Jordan Jumpman Jack "Bright Cactus"', 'FZ8117-102', 'Muslin/Black/Bright Cactus', 'Sneakers', 200.00, '2025-04-30'),

-- Supreme
(19, 'Supreme x Swarovski Box Logo Hooded Sweatshirt ''Heather Grey''', 'SS19SW9 HEATHER GREY', 'Heather Grey', 'Apparel - Hoodie', 598.00, '2019-04-25'),
(19, 'Supreme x Swarovski Box Logo Hooded Sweatshirt ''Black''', 'SS19SW9 BLACK', 'Black', 'Apparel - Hoodie', 598.00, '2019-04-25'),
(19, 'Supreme x Swarovski Box Logo Hooded Sweatshirt ''Red''', 'SS19SW9 RED', 'Red', 'Apparel - Hoodie', 598.00, '2019-04-25'),
(19, 'Supreme x Swarovski Box Logo Tee ''White''', 'SS19T1 WHITE', 'White', 'Apparel - T-Shirt', 398.00, '2019-04-25'),
(19, 'Supreme x Swarovski Box Logo Tee ''Black''', 'SS19T1 BLACK', 'Black', 'Apparel - T-Shirt', 398.00, '2019-04-25'),
(19, 'Supreme x Nike Air Force 1 Low ''White''', 'CU9225-100', 'White/White', 'Sneakers', 124.00, '2020-03-05'),
(19, 'Supreme x Nike Air Force 1 Low ''Black''', 'CU9225-001', 'Black/Black-Black', 'Sneakers', 124.00, '2020-03-05'),
(19, 'Supreme x The North Face ''By Any Means Necessary'' Nuptse Jacket ''Black''', 'FW15J2 BLACK', 'Black', 'Apparel - Jacket', 368.00, '2015-11-19'),
(19, 'Supreme x The North Face ''By Any Means Necessary'' Mountain Jacket ''Black''', 'FW15J1 BLACK', 'Black', 'Apparel - Jacket', 298.00, '2015-11-19'),
(19, 'Supreme x The North Face ''Arc Logo'' Denali Fleece Jacket ''Red''', 'SS19J4 RED', 'Red', 'Apparel - Jacket', 268.00, '2019-03-28'),
(19, 'Supreme Hanes Boxer Briefs (4 Pack) ''White''', '99HAA36-WHITE', 'White', 'Accessory', 48.00, '2024-02-15'),
(19, 'Supreme Hanes Tagless Tees (3 Pack) ''White''', 'SS21', 'White', 'Apparel - T-Shirt', 38.00, '2021-08-19'),

-- Balenciaga
(3, 'Balenciaga Triple S Sneaker ''Black''', '534217W2CA11000', 'Black', 'Sneakers', 1150.00, '2018-02-14'),
(3, 'Balenciaga Triple S Sneaker ''Beige''', '809496190', 'Beige', 'Sneakers', 1150.00, '2019-01-01'),
(3, 'Balenciaga Triple S Clear Sole Sneaker ''White''', '541624W2FB19000', 'White', 'Sneakers', 1150.00, '2017-09-21'),
(3, 'Balenciaga Speed 2.0 Full Clear Sole Sneaker ''Black''', '617239W2DC41000', 'Black', 'Sneakers', 1100.00, '2020-07-01'),
(3, 'Balenciaga Speed 2.0 LT Sock Sneaker ''Black/White''', '617239W2DB21015', 'Black/White', 'Sneakers', 995.00, '2020-07-01'),
(3, 'Balenciaga Runner Sneaker ''White''', '772774W3RMU9000', 'White', 'Sneakers', 1190.00, '2024-12-19'),
(3, 'Balenciaga Runner Sneaker ''Multicolor''', '677403W3RB68123', 'Multicolor', 'Sneakers', 1190.00, '2022-04-07'),
(3, 'Balenciaga Track Sneaker ''White''', '542023W1GB19000', 'White', 'Sneakers', 1150.00, '2019-01-01'),
(3, 'Balenciaga Track Trail Sneaker ''Black''', '800592WTRHK1000', 'Black/Orange', 'Sneakers', 1250.00, '2024-04-22'),
(3, 'Balenciaga 3XL Extreme Lace Sneaker ''White''', '778698W3XLL9114', 'White/Grey', 'Sneakers', 1290.00, '2025-03-01'),
(3, 'Balenciaga Political Campaign Hoodie ''White''', '600583TKVI99084', 'White', 'Apparel - Hoodie', 1150.00, '2017-01-01'),
(3, 'Balenciaga Political Campaign Hoodie ''Black''', '620947TKVI99034', 'Black', 'Apparel - Hoodie', 1150.00, '2017-01-01'),
(3, 'Balenciaga 10XL Sneaker ''Grey''', '792779-W2MV2-9110', 'White/Black/Grey', 'Sneakers', 1290.00, '2023-12-02'),

-- Off-White
(13, 'Off-White x Nike Air Jordan 1 ''Chicago'' (The Ten)', 'AA3834-101', 'White/Black-Varsity Red', 'Sneakers', 190.00, '2017-11-09'),
(13, 'Off-White x Nike Blazer ''The Ten''', 'AA3832-100', 'White/Black-Muslin', 'Sneakers', 130.00, '2017-09-06'),
(13, 'Off-White x Nike Air Max 97 ''The Ten''', 'AJ4585-100', 'White/Cone/Ice Blue', 'Sneakers', 190.00, '2017-11-20'),
(13, 'Off-White x Nike Air Presto ''The Ten''', 'AA3830-001', 'Black/Black/Muslin', 'Sneakers', 160.00, '2017-09-07'),
(13, 'Off-White x Nike Air Max 90 ''The Ten''', 'AA7293-100', 'Sail/White/Muslin', 'Sneakers', 160.00, '2017-09-06'),
(13, 'Off-White x Nike React Hyperdunk 2017 ''The Ten''', 'AJ4578-100', 'White/White-White', 'Sneakers', 200.00, '2017-11-01'),
(13, 'Off-White x Nike Zoom Fly ''The Ten''', 'AJ4588-100', 'White/White-Muslin', 'Sneakers', 170.00, '2017-11-20'),
(13, 'Off-White x Nike Air Presto ''Black'' (2018)', 'AA3830-002', 'Black/White-Cone', 'Sneakers', 160.00, '2018-07-27'),
(13, 'Off-White x Nike Air Max 90 ''Black''', 'AA7293-001', 'Black/Black-Cone-White', 'Sneakers', 160.00, '2019-02-07'),
(13, 'Off-White x Nike Air Force 1 ''Volt''', 'AO4606-700', 'Volt/Hyper Jade-Cone-Black', 'Sneakers', 170.00, '2018-12-19'),
(13, 'Off-White x Air Jordan 1 ''UNC''', 'AQ0818-148', 'White/Dark Powder Blue-Cone', 'Sneakers', 190.00, '2018-06-23'),
(13, 'Off-White x Nike Air Force 1 ''MCA''', 'CI1173-400', 'University Blue/Metallic Silver-White', 'Sneakers', 150.00, '2019-07-20'),

-- BAPE
(4, 'BAPE 1st Camo Shark Full Zip Hoodie ''Green''', '1J80-115-009', 'Green', 'Apparel - Hoodie', 260.00, '2023-11-11'),
(4, 'BAPE 1st Camo Shark Full Zip Hoodie ''Yellow''', NULL, 'Yellow', 'Apparel - Hoodie', 435.00, '2018-09-22'),
(4, 'BAPE ABC Dot Shark Full Zip Hoodie ''Blue''', '1J30 115 007 BLUE', 'Blue', 'Apparel - Hoodie', 475.00, '2023-03-17'),
(4, 'BAPE Color Camo Shark Full Zip Hoodie ''Red''', '1J20115003RED', 'Red', 'Apparel - Hoodie', 300.00, '2022-01-29'),
(4, 'BAPE STA #1 ''White''', '001FWK801303M', 'White', 'Sneakers', 309.00, '2024-11-23'),
(4, 'BAPE SK8 STA #1 ''Black''', '1K80-191-310-Black', 'Black', 'Sneakers', 309.00, '2024-11-09'),
(4, 'BAPE STA #3 ''White''', '001FWK801303MWHT', 'White', 'Sneakers', 309.00, '2024-11-28'),
(4, 'BAPE x Clot Egra Camo BAPE STA M2', '1L73-191-931', 'Egra Camo', 'Sneakers', 255.00, '2025-07-26'),
(4, 'BAPE STA Icon ''Black''', '1L30-191-306-Black', 'Black', 'Sneakers', 309.00, '2025-03-29'),
(4, 'BAPE One Point Ape Head Shark Relaxed Fit Hoodie ''Black''', '0ZXSWM115305N', 'Black', 'Apparel - Hoodie', 535.00, '2024-07-14'),
(4, 'BAPE 2nd Shark Full Zip Hoodie ''Gray''', '1K70-115-006', 'Gray', 'Apparel - Hoodie', 535.00, '2024-11-23'),
(4, 'BAPE Baby Milo College Relaxed Fit Tee ''White''', '2K80-110-301', 'White', 'Apparel - T-Shirt', 129.00, '2024-10-01'),

-- Brand: Stüssy
(18, 'Stüssy Authentic Gear Pigment Dyed Tee ''Faded Black''', '1905124', 'Faded Black', 'Apparel - T-Shirt', 45.00, '2025-09-06'),
(18, 'Stüssy Personalities Tee ''Slate''', '1905120', 'Slate', 'Apparel - T-Shirt', 45.00, NULL),
(18, 'Stüssy Authorized Tee ''Black''', '1905122', 'Black', 'Apparel - T-Shirt', 45.00, '2025-09-06'),
(18, 'Stüssy Speedway L/S Tee ''Black''', '1995123', 'Black', 'Apparel - T-Shirt', 55.00, '2025-09-06'),
(18, 'Stüssy Lazy L/S Tee ''Vintage Navy''', '1140333', 'Vintage Navy', 'Apparel - T-Shirt', 60.00, NULL),
(18, 'Stüssy State Crew ''Olive''', '118596', 'Olive', 'Apparel - Crewneck', 130.00, NULL),
(18, 'Stüssy Midweight Hooded Puffer ''Orange''', '115856', 'Orange', 'Apparel - Jacket', 245.00, NULL),
(18, 'Stüssy Warm Up Jacket ''Teal''', '676865', 'Teal', 'Apparel - Jacket', 185.00, '2025-08-14'),
(18, 'Stüssy Workgear Sweatpant ''Ash Heather''', '116720', 'Ash Heather', 'Apparel - Pants', 120.00, NULL),
(18, 'Stüssy Carpenter Pant Canvas ''Black''', '116722', 'Black', 'Apparel - Pants', 155.00, '2025-09-19'),
(18, 'Stüssy Training Pant ''Digi Camo''', '116717', 'Digi Camo', 'Apparel - Pants', 135.00, '2025-09-06'),
(18, 'Stüssy Basic Cuff Beanie ''Black''', '1321019', 'Black', 'Accessory', 40.00, '2021-09-17'),
(18, 'Stüssy x Nike Air Force 1 Mid ''Fossil''', 'DJ7841-200', 'Fossil/Sail', 'Sneakers', 150.00, '2022-05-13'),
(18, 'Stüssy x Nike Air Penny 2 ''Black''', 'DQ5674-001', 'Black/Cobalt Pulse-White', 'Sneakers', 200.00, '2022-12-20'),
(18, 'Stüssy x Nike Air Max 2013 ''Fossil''', 'DM6447-200', 'Fossil/Black-Fossil', 'Sneakers', 210.00, '2022-08-05'),

-- Palace
(14, 'Palace Zodiac Tri-Ferg Hood ''Grey Marl''', 'P28CS080', 'Grey Marl', 'Apparel - Hoodie', 138.00, '2025-02-07'),
(14, 'Palace Zodiac Tri-Ferg Hood ''Navy''', NULL, 'Navy', 'Apparel - Hoodie', 138.00, '2025-02-07'),
(14, 'Palace ''Basically a Tri-Ferg'' T-Shirt ''Black''', NULL, 'Black', 'Apparel - T-Shirt', 48.00, '2021-02-12'),
(14, 'Palace ''Basically a Tri-Ferg'' T-Shirt ''White''', NULL, 'White', 'Apparel - T-Shirt', 48.00, '2021-02-12'),
(14, 'Palace 09 Tri-Ferg T-Shirt ''Grey Marl''', 'P29TS149', 'Grey Marl', 'Apparel - T-Shirt', 48.00, '2025-10-17'),
(14, 'Palace S-Line Hood ''Grey Marl''', NULL, 'Grey Marl', 'Apparel - Hoodie', 148.00, '2018-12-07'),
(14, 'Palace S-Line Hood ''Black''', NULL, 'Black', 'Apparel - Hoodie', 148.00, '2018-12-07'),
(14, 'Palace Shell Out Joggers ''Black''', NULL, 'Black', 'Apparel - Pants', 128.00, '2021-05-07'),
(14, 'Palace Shell Jogger ''Navy''', 'P29JG028', 'Navy', 'Apparel - Pants', 158.00, '2025-10-24'),
(14, 'Palace Barbour Field Casual Jacket ''Kelp Forest Camo''', 'MCA1079GN51', 'Kelp Forest Camo', 'Apparel - Jacket', 970.00, '2025-10-24'),
(14, 'Palace Horses Jacket ''Navy/Red''', 'P29JK082', 'Navy/Red', 'Apparel - Jacket', 288.00, '2025-10-24'),
(14, 'Palace Pertex Puffa Beanie ''Black''', 'P29BN021', 'Black', 'Accessory', 52.00, '2025-10-24'),

-- Kith
(9, 'Kith Classic Logo Hoodie ''Sand''', 'Apparel - Hoodie', NULL, 'FW17', NULL, 150.00),
(9, 'Kith Classic Logo Hoodie ''Tiger Camo''', 'Apparel - Hoodie', NULL, 'FW17', '2017-12-04', 150.00),
(9, 'Kith Classic Logo Williams II Hoodie ''Heather Grey''', 'Apparel - Hoodie', NULL, 'FW18', '2018-11-26', 160.00),
(9, 'Kith Retro Logo Tee ''White''', 'Apparel - T-Shirt', 'khm034785-101', NULL, NULL, 65.00),
(9, 'Kith Retro Logo Tee ''Black''', 'Apparel - T-Shirt', 'khm034785-001', NULL, NULL, 65.00),
(9, 'Kith x Looney Tunes KithJam Vintage Tee ''Black''', 'Apparel - T-Shirt', 'KH3808-100', 'SS20', '2020-07-13', 75.00),
(9, 'Kith x Disney Plush Through the Ages (Box set of 8)', 'Accessory', '697', NULL, '2019-11-18', 105.00),
(9, 'Kith x ASICS Gel-Lyte III ''The Palette'' (Hallow)', 'Sneakers', '1201A224-253', NULL, '2020-11-27', 180.00),
(9, 'Kith x Nike Air Force 1 Low ''Knicks Home''', 'Sneakers', 'CZ7928-100', NULL, '2020-12-18', 130.00),
(9, 'Kith x New Balance 990v3 ''Daytona''', 'Sneakers', 'M990KH3', NULL, '2022-06-16', 235.00),
(9, 'Kith x New Balance 990v2 ''Cyclades''', 'Sneakers', 'M990KC2', NULL, '2022-06-17', 225.00),
(9, 'Kith x New Balance 990v6 ''MSG (Sandrift)''', 'Sneakers', 'NBU990KN6', NULL, '2023-11-06', 220.00),

-- Fear of God
(7, 'Fear of God Athletics Pullover Hoodie ''Black''', 'IM8935', 'Black', 'Apparel - Hoodie', 230.00, '2023-12-03'),
(7, 'Fear of God Athletics Pullover Hoodie ''White''', 'IS5308', 'White', 'Apparel - Hoodie', 230.00, '2023-12-25'),
(7, 'Fear of God Athletics Cotton Fleece Hoodie ''Cement''', 'KA4570', 'Cement', 'Apparel - Hoodie', 165.00, '2024-06-07'),
(7, 'Fear of God Athletics Suede Fleece Hoodie ''Black''', 'KA4568', 'Black', 'Apparel - Hoodie', 280.00, '2023-12-03'),
(7, 'Fear of God Athletics Running Leggings ''Black''', 'IT1932', 'Black', 'Apparel - Pants', 180.00, '2024-04-03'),
(7, 'Fear of God Athletics Base Layer Running Tights ''Black''', 'IT1926', 'Black', 'Apparel - Pants', 150.00, '2024-04-03'),
(7, 'Fear of God Athletics Mock Neck 3/4 Sleeve T-Shirt ''Black''', 'IS6839', 'Black', 'Apparel - T-Shirt', 180.00, '2023-12-03'),
(7, 'Fear of God Essentials Vintage Fit Tee ''Jet Black''', '125SP254280F', 'Jet Black', 'Apparel - T-Shirt', 60.00, NULL),
(7, 'Fear of God Essentials Pullover Hoodie ''Off Black''', '0192250500017522', 'Off Black', 'Apparel - Hoodie', 100.00, NULL),
(7, 'Fear of God The California Slip-On ''Oat''', 'FG80-100EVA-991', 'Oat', 'Sneakers', 195.00, '2021-07-09'),
(7, 'Fear of God The California Slip-On ''Cream''', 'FG80-100EVA-CRM', 'Cream', 'Sneakers', 195.00, '2021-07-09'),
(7, 'Fear of God Athletics Adilette Slide Sandals ''Black''', NULL, 'Black', 'Sneakers', 100.00, NULL),

-- New Balance
(11, 'New Balance 9060 ''Rain Cloud''', 'Sneakers', 159.99),
(11, 'New Balance 9060 ''Black Cat''', 'Sneakers', 160.00),
(11, 'New Balance 9060 ''Mushroom''', 'Sneakers', 159.99),
(11, 'New Balance 2002R ''Protection Pack - Rain Cloud''', 'Sneakers', 145.00),
(11, 'New Balance 2002R ''Arid Stone/Black Coffee''', 'Sneakers', 145.00),
(11, 'New Balance 574 Core ''Grey''', 'Sneakers', 99.99),
(11, 'New Balance 574 Core ''Navy''', 'Sneakers', 99.99),
(11, 'New Balance Made in USA 993 ''Grey''', 'Sneakers', 199.99),
(11, 'New Balance Made in USA 990v6 ''Grey''', 'Sneakers', 199.99),
(11, 'New Balance 997H ''Team Red''', 'Sneakers', 90.00),
(11, 'New Balance 580 ''Black''', 'Sneakers', 150.00),
(11, 'New Balance 57/40 ''White''', 'Sneakers', 100.00),
(11, 'New Balance Fresh Foam X 1080v14 ''White''', 'Sneakers', 164.99),

-- ASICS
(2, 'ASICS GEL-KAYANO 14 ''White/Midnight''', 'Sneakers', 150.00),
(2, 'ASICS GEL-KAYANO 14 ''White/Pure Silver''', 'Sneakers', 150.00),
(2, 'ASICS GEL-1130 ''Clay Canyon''', 'Sneakers', 95.00),
(2, 'ASICS GEL-1130 ''White/Oatmeal''', 'Sneakers', 100.00),
(2, 'ASICS GEL-1130 ''Black/Slate Grey''', 'Sneakers', 99.99),
(2, 'ASICS GEL-NYC ''White''', 'Sneakers', 130.00),
(2, 'ASICS GEL-NYC ''Cream/Oyster Grey''', 'Sneakers', 140.00),
(2, 'ASICS GT-2160 ''White/Pure Silver''', 'Sneakers', 130.00),
(2, 'ASICS GEL-LYTE III OG ''Hydrangea''', 'Sneakers', 130.00),
(2, 'ASICS GEL-NIMBUS 9 ''White''', 'Sneakers', 160.00),
(2, 'ASICS GEL-QUANTUM KINETIC ''Black''', 'Sneakers', 250.00),
(2, 'ASICS GEL-TERRAIN ''Black''', 'Sneakers', 120.00),
(2, 'ASICS SKYHAND OG ''White/Blue''', 'Sneakers', 100.00),

-- Salomon
(17, 'Salomon XT-6 ''White/Lunar Rock''', 'Sneakers', 180.00),
(17, 'Salomon XT-6 GORE-TEX ''Black''', 'Sneakers', 200.00),
(17, 'Salomon XT-6 ''Black/Phantom''', 'Sneakers', 180.00),
(17, 'Salomon XT-6 EXPANSE ''Almond Milk''', 'Sneakers', 160.00),
(17, 'Salomon XT-4 OG ''Fiery Red''', 'Sneakers', 190.00),
(17, 'Salomon XT-4 OG ''White''', 'Sneakers', 190.00),
(17, 'Salomon ACS Pro ''Black''', 'Sneakers', 200.00),
(17, 'Salomon ACS Pro ''Almond Milk/Cement''', 'Sneakers', 230.00),
(17, 'Salomon ACS Pro LEATHER ''Black''', 'Sneakers', 200.00),
(17, 'Salomon XT-WINGS 2 ''Black''', 'Sneakers', 160.00),
(17, 'Salomon RX MOC 3.0 ''Black''', 'Sneakers', 100.00),
(17, 'Salomon Speedcross 3 ''Black''', 'Sneakers', 140.00),
(17, 'Salomon XA Pro 3D v8 ''Black''', 'Sneakers', 130.00),

-- Vans
(20, 'Vans Old Skool ''Black/White''', 'Sneakers', 70.00),
(20, 'Vans Classic Slip-On ''Checkerboard''', 'Sneakers', 60.00),
(20, 'Vans Sk8-Hi ''Black/White''', 'Sneakers', 75.00),
(20, 'Vans Knu Skool ''Black''', 'Sneakers', 80.00),
(20, 'Vans Authentic ''True White''', 'Sneakers', 55.00),
(20, 'Vans Authentic ''Black''', 'Sneakers', 55.00),
(20, 'Vans Old Skool Platform ''Black/White''', 'Sneakers', 90.00),
(20, 'Vans UltraRange 2.0 ''Black''', 'Sneakers', 100.00),
(20, 'Vans Ward Skate Shoes ''Black/White''', 'Sneakers', 69.99),
(20, 'Vans Asher Slip-On Skate Shoes ''Checkerboard''', 'Sneakers', 54.99),
(20, 'Vans Caldrone Skate Shoes ''Black''', 'Sneakers', 74.99),
(20, 'Vans Filmore High-Top Sneakers ''Black''', 'Sneakers', 74.99),

-- Converse
(5, 'Converse Chuck 70 High Top ''Black''', 'Sneakers', 85.00),
(5, 'Converse Chuck 70 High Top ''Parchment''', 'Sneakers', 85.00),
(5, 'Converse Chuck 70 Low Top ''Black''', 'Sneakers', 80.00),
(5, 'Converse Chuck Taylor All Star Classic ''White'' (High Top)', 'Sneakers', 60.00),
(5, 'Converse Chuck Taylor All Star Classic ''Black'' (Low Top)', 'Sneakers', 55.00),
(5, 'Converse Chuck Taylor All Star Lift Platform ''White''', 'Sneakers', 75.00),
(5, 'Converse Run Star Hike Platform ''Black''', 'Sneakers', 110.00),
(5, 'Converse Chuck Taylor All Star Lugged ''White''', 'Sneakers', 80.00),
(5, 'Converse One Star Pro ''Black/White''', 'Sneakers', 75.00),
(5, 'Converse Jack Purcell ''White''', 'Sneakers', 65.00),
(5, 'Converse x CDG PLAY Chuck 70 ''Black''', 'Sneakers', 150.00),
(5, 'Converse x CDG PLAY Chuck 70 ''Parchment''', 'Sneakers', 150.00),

-- Puma
(15, 'Puma Suede Classic ''Black''', 'Sneakers', 90.00),
(15, 'Puma Suede Classic ''Team Regal Red''', 'Sneakers', 90.00),
(15, 'Puma Suede XL ''Black''', 'Sneakers', 85.00),
(15, 'Puma Palermo ''Black/Feather Gray''', 'Sneakers', 90.00),
(15, 'Puma Speedcat ''Black/White''', 'Sneakers', 100.00),
(15,'Puma x LaMelo Ball MB.01 ''Red''', 'Sneakers', 125.00),
(15, 'Puma x LaMelo Ball MB.01 50th ''Black/White''', 'Sneakers', 125.00),
(15, 'Puma x LaMelo Ball MB.01 Lo ''White/Silver''', 'Sneakers', 120.00),
(15, 'Fenty x Puma Creeper Phatty ''Lavender''', 'Sneakers', 140.00),
(15, 'Fenty x Puma Creeper Phatty ''Speed Blue''', 'Sneakers', 140.00),
(15, 'Fenty x Puma Creeper Phatty ''Totally Taupe''', 'Sneakers', 140.00),
(15, 'Fenty x Puma Creeper Phatty ''Warm White''', 'Sneakers', 120.00),

-- Reebok
(16, 'Reebok Club C 85 Vintage ''Chalk/Glen Green''', 'Sneakers', 90.00),
(16,'Reebok Club C 85 Vintage ''Footwear White/Barely Grey''', 'Sneakers', 85.00),
(16, 'Reebok Classic Leather ''White''', 'Sneakers', 75.00),
(16, 'Reebok Classic Leather ''Black''', 'Sneakers', 75.00),
(16, 'Reebok Question Mid ''Red Toe'' (Red/White)', 'Sneakers', 170.00),
(16, 'Reebok Question Mid ''Banner''', 'Sneakers', 170.00),
(16, 'Reebok Club C Revenge ''White/Glen Green''', 'Sneakers', 90.00),
(16, 'Reebok Premier Road Ultra ''Black''', 'Sneakers', 130.00),
(16, 'Reebok Nano X5 ''Black''', 'Sneakers', 140.00),
(16, 'Reebok ERS World Shoes ''Barely Grey''', 'Sneakers', 120.00),
(16, 'Reebok x JJJJOUND Club C ''Olive''', 'Sneakers', 150.00),
(16, 'Reebok Phase Court ''White''', 'Sneakers', 85.00),

-- Dior
(6, 'Dior B27 Low-Top Sneaker ''White Dior Oblique''', 'Sneakers', 1200.00),
(6, 'Dior B27 Low-Top Sneaker ''Brown''', 'Sneakers', 1200.00),
(6, 'Dior B57 Dribble Low-Top Sneaker ''Black/White Oblique''', 'Sneakers', 1350.00),
(6, 'Dior Chrono Sneaker ''White Mesh''', 'Sneakers', 1250.00),
(6, 'Dior Chrono Sneaker ''Gray Mesh/Suede''', 'Sneakers', 1250.00),
(6, 'Dior Vibe Sneaker ''Gray Dior Oblique''', 'Sneakers', 1250.00),
(6, 'Dior B101 Slip-On Sneaker ''White''', 'Sneakers', 655.00),
(6, 'Dior B23 High-Top Sneaker ''Dior Oblique Canvas''', 'Sneakers', 1100.00),
(6, 'Dior Oblique Hooded Sweatshirt ''Navy Blue''', 'Apparel - Hoodie', 2250.00),
(6, 'Dior Oblique Hooded Sweatshirt ''Black''', 'Apparel - Hoodie', 2250.00),
(6, 'Dior Oblique Sweater ''Black Cotton Jacquard''', 'Apparel - Crewneck', 2250.00),
(6, 'Dior T-Shirt with Bee Embroidery ''Black''', 'Apparel - T-Shirt', 660.00),
(6, 'Dior T-Shirt with Bee Embroidery ''White''', 'Apparel - T-Shirt', 660.00),

-- Maison Margiela
(10, 'Maison Margiela Replica GAT ''White''', 'Sneakers', 540.00),
(10, 'Maison Margiela Replica GAT ''Black Gum''', 'Sneakers', 540.00),
(10, 'Maison Margiela Replica GAT ''Dirty Wash''', 'Sneakers', 620.00),
(10, 'Maison Margiela Replica GAT ''Paint Splatter''', 'Sneakers', 755.00),
(10, 'Maison Margiela 50-50 Sneakers ''Black''', 'Sneakers', 870.00),
(10, 'Maison Margiela ''AIDS'' T-Shirt ''Black''', 'Apparel - T-Shirt', 125.00),
(10, 'Maison Margiela 4-Stitch T-Shirt ''Grey''', 'Apparel - T-Shirt', 495.00),
(10, 'Maison Margiela 4-Stitch T-Shirt ''Black''', 'Apparel - T-Shirt', 495.00),
(10, 'Maison Margiela 4-Stitch Logo Hoodie ''Black''', 'Apparel - Hoodie', 790.00),
(10, 'Maison Margiela Embroidered Logo T-shirt ''White''', 'Apparel - T-Shirt', 595.00),
(10, 'Maison Margiela Low-Profile Leather Sneakers ''White''', 'Sneakers', 504.00),
(10, 'Maison Margiela Frayed-Edges Distressed Sneakers ''Black''', 'Sneakers', 663.00);

INSERT INTO products_sizes (product_id, size_id)
SELECT p.product_id, s.size_id
FROM products p
CROSS JOIN sizes s
WHERE
    p.product_type = 'Sneakers'
    AND s.size_id BETWEEN 1 AND 20;


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
    p.name = 'Supreme Hanes Boxer Briefs (4 Pack) ''White'''
    AND s.size_id BETWEEN 21 AND 26;