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

INSERT INTO Products (brand_id, name, product_type, retail_price) VALUES
(12, 'Nike Air Force 1 ''07 ''Triple White''', 'Sneakers', 115.00),
(12, 'Nike Dunk Low ''Panda'' (Black/White)', 'Sneakers', 115.00),
(12, 'Nike Air Max 270 ''Black''', 'Sneakers', 170.00),
(12, 'Nike Zoom Vomero 5 ''White/Metallic Silver''', 'Sneakers', 180.00),
(12, 'Nike P-6000 ''White/Silver''', 'Sneakers', 115.00),
(12, 'Nike Tech Fleece Windrunner Full-Zip Jacket ''Grey''', 'Apparel - Jacket', 135.00),
(12, 'Nike Tech Fleece Joggers ''Grey''', 'Apparel - Pants', 125.00),
(12, 'Nike Sportswear Phoenix Fleece Wide-Leg Sweatpants ''Black''', 'Apparel - Pants', 80.00),
(12, 'Nike Solo Swoosh Pullover Hoodie ''Black''', 'Apparel - Hoodie', 85.00),
(12, 'Nike Air Max 1 ''86 OG ''Big Bubble''', 'Sneakers', 150.00),
(12, 'Nike Air Max 90 ''Infrared''', 'Sneakers', 135.00),
(12, 'Nike Sportswear Club Fleece Crew ''Grey''', 'Apparel - Crewneck', 70.00),
(12, 'Nike V2K Run ''Metallic Silver''', 'Sneakers', 110.00),

-- Brand: Adidas (brand_id = 1)
(1, 'Adidas Samba OG ''White/Black''', 'Sneakers', 110.00),
(1, 'Adidas Gazelle Bold Shoes ''Core Black''', 'Sneakers', 120.00),
(1, 'Adidas Adicolor Classic Firebird Loose Track Pants ''Black''', 'Apparel - Pants', 75.00),
(1, 'Adidas Originals Satin Wide Leg Pants ''Black''', 'Apparel - Pants', 70.00),
(1, 'Adidas Stan Smith ''White/Green''', 'Sneakers', 100.00),
(1, 'Adidas Ultraboost 22 ''Core Black''', 'Sneakers', 190.00),
(1, 'Adidas NMD_R1 ''Core Black''', 'Sneakers', 150.00),
(1,'Adidas Adilette Slides ''Core Black''', 'Sneakers', 50.00),
(1, 'Adidas Superstar ''White/Black''', 'Sneakers', 100.00),
(1, 'Adidas Gazelle Indoor ''Blue''', 'Sneakers', 120.00),
(1, 'Adidas Campus 00s ''Core Black''', 'Sneakers', 110.00),
(1, 'Adidas Adicolor Classics 3-Stripes Tee ''White''', 'Apparel - T-Shirt', 40.00),

-- Brand: Jordan (brand_id = 8)
(8, 'Air Jordan 1 Retro High OG ''Chicago'' (Lost & Found)', 'Sneakers', 180.00),
(8, 'Air Jordan 1 Retro High OG ''Shattered Backboard''', 'Sneakers', 185.00),
(8, 'Air Jordan 3 Retro ''White Cement'' (Reimagined)', 'Sneakers', 215.00),
(8, 'Air Jordan 4 Retro ''Bred'' (Reimagined)', 'Sneakers', 220.00),
(8, 'Air Jordan 11 Retro ''Concord''', 'Sneakers', 230.00),
(8, 'Air Jordan 5 Retro ''Fire Red''', 'Sneakers', 215.00),
(8, 'Air Jordan 1 Low SE ''Team Red''', 'Sneakers', 130.00),
(8, 'Air Jordan 1 Mid ''White/Black''', 'Sneakers', 130.00),
(8, 'Air Jordan 3 Retro ''El Vuelo''', 'Sneakers', 230.00),
(8, 'Air Jordan 1 Retro High OG ''Pro Green'' (Women''s)', 'Sneakers', 185.00),
(8, 'Air Jordan 1 Retro Low ''Black Toe''', 'Sneakers', 165.00),
(8, 'Jordan Flight Essentials Oversized T-Shirt ''Black''', 'Apparel - T-Shirt', 40.00),
(8, 'Jordan Flight Fleece Pants ''Black''', 'Apparel - Pants', 90.00),

-- Brand: Supreme (brand_id = 19)
(19, 'Supreme Box Logo Hooded Sweatshirt ''Heather Grey''', 'Apparel - Hoodie', 168.00),
(19, 'Supreme Box Logo Hooded Sweatshirt ''Black''', 'Apparel - Hoodie', 168.00),
(19, 'Supreme Box Logo Hooded Sweatshirt ''Red''', 'Apparel - Hoodie', 168.00),
(19, 'Supreme Box Logo Tee ''White''', 'Apparel - T-Shirt', 44.00),
(19, 'Supreme Box Logo Tee ''Black''', 'Apparel - T-Shirt', 44.00),
(19, 'Supreme x Nike Air Force 1 Low ''White''', 'Sneakers', 124.00),
(19, 'Supreme x Nike Air Force 1 Low ''Black''', 'Sneakers', 124.00),
(19, 'Supreme x The North Face Nuptse Jacket ''Statue of Liberty''', 'Apparel - Jacket', 368.00),
(19, 'Supreme x The North Face Mountain Parka ''By Any Means Necessary''', 'Apparel - Jacket', 348.00),
(19, 'Supreme x The North Face Denali Fleece Jacket ''Red''', 'Apparel - Jacket', 288.00),
(19, 'Supreme Hanes Boxer Briefs (4 Pack) ''White''', 'Accessory', 48.00),
(19, 'Supreme Hanes Tagless Tees (3 Pack) ''White''', 'Apparel - T-Shirt', 38.00),

-- Brand: Balenciaga (brand_id = 3)
(3, 'Balenciaga Triple S Sneaker ''Black''', 'Sneakers', 1150.00),
(3, 'Balenciaga Triple S Sneaker ''Beige''', 'Sneakers', 1150.00),
(3, 'Balenciaga Triple S Sneaker ''White''', 'Sneakers', 1150.00),
(3, 'Balenciaga Speed 2.0 Recycled Knit Sneaker ''Black''', 'Sneakers', 1100.00),
(3, 'Balenciaga Speed 2.0 LT Sock Sneaker ''Black/White''', 'Sneakers', 995.00),
(3, 'Balenciaga Runner Sneaker ''White''', 'Sneakers', 1190.00),
(3, 'Balenciaga Runner Sneaker ''Multicolor''', 'Sneakers', 1190.00),
(3, 'Balenciaga Track Sneaker ''White''', 'Sneakers', 1150.00),
(3, 'Balenciaga Track Trail Sneaker ''Black''', 'Sneakers', 1250.00),
(3, 'Balenciaga 3XL Extreme Lace Sneaker ''White''', 'Sneakers', 1290.00),
(3, 'Balenciaga Political Campaign Hoodie ''White''', 'Apparel - Hoodie', 1150.00),
(3, 'Balenciaga Political Campaign Hoodie ''Black''', 'Apparel - Hoodie', 1150.00),
(3, 'Balenciaga 10XL Sneaker ''Grey''', 'Sneakers', 1290.00),

-- Brand: Off-White (brand_id = 13)
(13, 'Off-White x Nike Air Jordan 1 ''Chicago'' (The Ten)', 'Sneakers', 190.00),
(13, 'Off-White x Nike Blazer ''The Ten''', 'Sneakers', 130.00),
(13, 'Off-White x Nike Air Max 97 ''The Ten''', 'Sneakers', 190.00),
(13, 'Off-White x Nike Air Presto ''The Ten''', 'Sneakers', 160.00),
(13, 'Off-White x Nike Air Max 90 ''The Ten''', 'Sneakers', 160.00),
(13, 'Off-White ''Arrows'' Print T-Shirt ''White''', 'Apparel - T-Shirt', 350.00),
(13, 'Off-White ''Arrows'' Print T-Shirt ''Black''', 'Apparel - T-Shirt', 350.00),
(13, 'Off-White ''Brush Arrow'' Crewneck T-Shirt ''Black''', 'Apparel - T-Shirt', 305.00),
(13, 'Off-White Classic Industrial Belt ''Yellow/Black''', 'Accessory', 215.00),
(13, 'Off-White Vulcanized Low Top Sneaker ''White''', 'Sneakers', 350.00),
(13, 'Off-White x Nike React Hyperdunk 2017 ''The Ten''', 'Sneakers', 200.00),
(13, 'Off-White x Nike Zoom Fly ''The Ten''', 'Sneakers', 170.00),

-- Brand: BAPE (A Bathing Ape) (brand_id = 4)
(4, 'BAPE 1st Camo Shark Full Zip Hoodie ''Green''', 'Apparel - Hoodie', 475.00),
(4, 'BAPE 1st Camo Shark Full Zip Hoodie ''Yellow''', 'Apparel - Hoodie', 475.00),
(4, 'BAPE ABC Dot Shark Full Zip Hoodie ''Blue''', 'Apparel - Hoodie', 475.00),
(4, 'BAPE Color Camo Shark Full Zip Hoodie ''Red''', 'Apparel - Hoodie', 475.00),
(4, 'BAPE STA #1 ''White''', 'Sneakers', 309.00),
(4, 'BAPE SK8 STA #1 ''Black''', 'Sneakers', 329.00),
(4, 'BAPE STA #3 ''White''', 'Sneakers', 349.00),
(4, 'BAPE x Clot Egra Camo BAPE STA M2', 'Sneakers', 255.00),
(4, 'BAPE STA Icon ''Black''', 'Sneakers', 309.00),
(4, 'BAPE One Point Ape Head Shark Relaxed Fit Hoodie ''Black''', 'Apparel - Hoodie', 535.00),
(4, 'BAPE 2nd Shark Full Zip Hoodie ''Gray''', 'Apparel - Hoodie', 569.00),
(4, 'BAPE Baby Milo College Relaxed Fit Tee ''White''', 'Apparel - T-Shirt', 129.00),

-- Brand: Stüssy (brand_id = 18)
(18, 'Stüssy Authentic Gear Pigment Dyed Tee ''Faded Black''', 'Apparel - T-Shirt', 45.00),
(18, 'Stüssy Personalities Tee ''Slate''', 'Apparel - T-Shirt', 45.00),
(18, 'Stüssy Authorized Tee ''Black''', 'Apparel - T-Shirt', 45.00),
(18, 'Stüssy Speedway L/S Tee ''Black''', 'Apparel - T-Shirt', 55.00),
(18, 'Stüssy Lazy L/S Tee ''Vintage Navy''', 'Apparel - T-Shirt', 60.00),
(18, 'Stüssy State Crew ''Olive''', 'Apparel - Crewneck', 130.00),
(18, 'Stüssy Midweight Hooded Puffer ''Orange''', 'Apparel - Jacket', 245.00),
(18, 'Stüssy Warm Up Jacket ''Teal''', 'Apparel - Jacket', 185.00),
(18, 'Stüssy Workgear Sweatpant ''Ash Heather''', 'Apparel - Pants', 120.00),
(18, 'Stüssy Carpenter Pant Canvas ''Black''', 'Apparel - Pants', 155.00),
(18, 'Stüssy Training Pant ''Digi Camo''', 'Apparel - Pants', 135.00),
(18, 'Stüssy Basic Cuff Beanie ''Black''', 'Accessory', 40.00),
(18, 'Stüssy x Nike Air Force 1 Mid ''Fossil''', 'Sneakers', 103.00),
(18, 'Stüssy x Nike Air Penny 2 ''Black''', 'Sneakers', 200.00),
(18, 'Stüssy x Nike Air Max 2013 ''Fossil''', 'Sneakers', 210.00),

-- Brand: Palace (brand_id = 14)
(14, 'Palace Tri-Ferg Hood ''Grey Marl''', 'Apparel - Hoodie', 138.00),
(14, 'Palace Tri-Ferg Hood ''Navy''', 'Apparel - Hoodie', 138.00),
(14, 'Palace ''Basically a Tri-Ferg'' T-Shirt ''Black''', 'Apparel - T-Shirt', 48.00),
(14, 'Palace ''Basically a Tri-Ferg'' T-Shirt ''White''', 'Apparel - T-Shirt', 48.00),
(14, 'Palace 09 Tri-Ferg T-Shirt ''Grey Marl''', 'Apparel - T-Shirt', 46.00),
(14, 'Palace Skyline Hood ''Grey Marl''', 'Apparel - Hoodie', 148.00),
(14, 'Palace Skyline Hood ''Black''', 'Apparel - Hoodie', 148.00),
(14, 'Palace Shell Jogger ''Black''', 'Apparel - Pants', 128.00),
(14, 'Palace Shell Jogger ''Navy''', 'Apparel - Pants', 128.00),
(14, 'Palace Barbour Field Casual Jacket ''Kelp Forest Camo''', 'Apparel - Jacket', 550.00),
(14, 'Palace Horses Jacket ''Navy/Red''', 'Apparel - Jacket', 228.00),
(14, 'Palace Pertex Puffa Beanie ''Black''', 'Accessory', 48.00),

-- Brand: Kith (brand_id = 9)
(9, 'Kith Classic Logo Hoodie ''Sand''', 'Apparel - Hoodie', 165.00),
(9, 'Kith Classic Logo Hoodie ''Tiger Camo''', 'Apparel - Hoodie', 165.00),
(9, 'Kith Classic Logo Hoodie ''Heather Grey''', 'Apparel - Hoodie', 165.00),
(9, 'Kith Box Logo T-Shirt ''White''', 'Apparel - T-Shirt', 65.00),
(9, 'Kith Box Logo T-Shirt ''Black''', 'Apparel - T-Shirt', 65.00),
(9, 'Kith x Looney Tunes KithJam Vintage Tee ''Black''', 'Apparel - T-Shirt', 65.00),
(9, 'Kith x Disney Plush Through the Ages (Box set of 8)', 'Accessory', 129.00),
(9, 'Kith x ASICS Gel-Lyte III ''The Palette'' (Hallow)', 'Sneakers', 240.00),
(9, 'Kith x Nike Air Force 1 Low ''Knicks Home''', 'Sneakers', 130.00),
(9, 'Kith x New Balance 990v3 ''Daytona''', 'Sneakers', 210.00),
(9, 'Kith x New Balance 990v2 ''Cyclades''', 'Sneakers', 200.00),
(9, 'Kith x New Balance 990v6 ''Madison Square Garden''', 'Sneakers', 220.00),

-- Brand: Fear of God (brand_id = 7)
(7, 'Fear of God Athletics Pullover Hoodie ''Black''', 'Apparel - Hoodie', 230.00),
(7, 'Fear of God Athletics Pullover Hoodie ''White''', 'Apparel - Hoodie', 230.00),
(7, 'Fear of God Athletics Cotton Fleece Hoodie ''Cement''', 'Apparel - Hoodie', 165.00),
(7, 'Fear of God Athletics Suede Fleece Hoodie ''Black''', 'Apparel - Hoodie', 280.00),
(7, 'Fear of God Athletics Running Leggings ''Black''', 'Apparel - Pants', 180.00),
(7, 'Fear of God Athletics Base Layer Running Tights ''Black''', 'Apparel - Pants', 150.00),
(7, 'Fear of God Athletics Mock Neck 3/4 Sleeve T-Shirt ''Black''', 'Apparel - T-Shirt', 180.00),
(7, 'Fear of God Essentials Vintage Fit Tee ''Jet Black''', 'Apparel - T-Shirt', 60.00),
(7, 'Fear of God Essentials Pullover Hoodie ''Off Black''', 'Apparel - Hoodie', 100.00),
(7, 'Fear of God The California Slip-On ''Oat''', 'Sneakers', 169.00),
(7, 'Fear of God The California Slip-On ''Cream''', 'Sneakers', 169.00),
(7, 'Fear of God Athletics Adilette Slide Sandals ''Black''', 'Sneakers', 100.00),

-- Brand: New Balance (brand_id = 11)
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

-- Brand: ASICS (brand_id = 2)
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

-- Brand: Salomon (brand_id = 17)
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

-- Brand: Vans (brand_id = 20)
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

-- Brand: Converse (brand_id = 5)
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

-- Brand: Puma (brand_id = 15)
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

-- Brand: Reebok (brand_id = 16)
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

-- Brand: Dior (brand_id = 6)
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

-- Brand: Maison Margiela (brand_id = 10)
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