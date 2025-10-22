-- =================================================================================
--  REALISTIC E-COMMERCE DATABASE POPULATION SCRIPT
-- =================================================================================
--  This script will first WIPE ALL EXISTING DATA from the tables
--  and then populate them with a large, interconnected, and realistic dataset.
-- =================================================================================

-- Set the target database
USE ecommerce;

-- =============================================
--  PREPARATION: WIPE EXISTING DATA
-- =============================================
-- Disable foreign key checks to allow truncation of tables in any order
SET FOREIGN_KEY_CHECKS = 0;

-- Truncate tables to clear all existing data
TRUNCATE TABLE transactions;
TRUNCATE TABLE orders;
TRUNCATE TABLE listings;
TRUNCATE TABLE addresses;
TRUNCATE TABLE products_sizes;
TRUNCATE TABLE products;
TRUNCATE TABLE account_balance;
TRUNCATE TABLE users;
TRUNCATE TABLE brands;
TRUNCATE TABLE sizes;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Start a single transaction for the entire data insertion process
START TRANSACTION;

-- =============================================
--  1. STATIC DATA: BRANDS & SIZES
-- =============================================
INSERT INTO brands (brand_id, brand_name, brand_logo_url) VALUES
(1, 'Adidas', '/images/adidasLogo.png'), (2, 'ASICS', '/images/AsicsLogo.png'), (3, 'Balenciaga', '/images/BalenciagaLogo.png'), (4, 'BAPE (A Bathing Ape)', '/images/BapeLogo.webp'), (5, 'Converse', '/images/ConverseLogo.png'), (6, 'Dior', '/images/DiorLogo.png'), (7, 'Fear of God', '/images/FearOfGodLogo.png'), (8, 'Jordan Brand', '/images/JordanLogo.png'), (9, 'Kith', '/images/KithLogo.png'), (10, 'Maison Margiela', '/images/MaisonMargielaLogo.png'), (11, 'New Balance', '/images/NewBalanceLogo.png'), (12, 'Nike', '/images/NikeLogo.svg'), (13, 'Off-White', '/images/OffWhiteLogo.svg'), (14, 'Palace', '/images/PalaceLogo.webp'), (15, 'Puma', '/images/PumaLogo.svg'), (16, 'Reebok', '/images/ReebokLogo.png'), (17, 'Salomon', '/images/SalomonLogo.svg'), (18, 'Stüssy', '/images/StussyLogo.png'), (19, 'Supreme', '/images/SupremeLogo.png'), (20, 'Vans', '/images/VansLogo.png');

INSERT INTO sizes (size_id, size_value) VALUES
-- Sneaker Sizes (US Men's)
(1, '4'), (2, '4.5'), (3, '5'), (4, '5.5'), (5, '6'), (6, '6.5'), (7, '7'), (8, '7.5'), (9, '8'), (10, '8.5'), (11, '9'), (12, '9.5'), (13, '10'), (14, '10.5'), (15, '11'), (16, '11.5'), (17, '12'), (18, '13'), (19, '14'), (20, '15'),
-- Apparel Sizes
(21, 'XS'), (22, 'S'), (23, 'M'), (24, 'L'), (25, 'XL'), (26, 'XXL');

-- =============================================
--  2. PRODUCTS (EXPANDED TO ALL BRANDS)
-- =============================================
INSERT INTO products (brand_id, name, sku, colorway, retail_price, release_date, image_url) VALUES
-- Nike (12)
(12, 'Dunk Low "Panda"', 'DD1391-100', 'White/Black-White', 110.00, '2021-03-10', 'https://images.stockx.com/images/Nike-Dunk-Low-Retro-White-Black-2021-Product.jpg'),
(12, 'Air Force 1 \'07', 'CW2288-111', 'White/White', 115.00, '2007-11-24', 'https://images.stockx.com/images/Nike-Air-Force-1-Low-White-07-Product.jpg'),
(12, 'Kobe 6 Protro Reverse Grinch', 'FV4921-600', 'Bright Crimson/Black-Electric Green', 190.00, '2023-12-15', 'https://images.stockx.com/images/Nike-Kobe-6-Protro-Reverse-Grinch-Product.jpg'),
(12, 'SB Dunk Low Pro Concepts Orange Lobster', 'FD8776-800', 'Orange Frost/Electro Orange-White', 120.00, '2022-12-02', 'https://images.stockx.com/images/Nike-SB-Dunk-Low-Concepts-Orange-Lobster-Product.jpg'),
-- Jordan Brand (8)
(8, '1 Retro High OG "Lost & Found"', 'DZ5485-612', 'Varsity Red/Black/Sail/Muslin', 180.00, '2022-11-19', 'https://images.stockx.com/images/Air-Jordan-1-Retro-High-OG-Chicago-Reimagined-Product.jpg'),
(8, '4 Retro SB "Pine Green"', 'DR5415-103', 'Sail/Pine Green/Neutral Grey/White', 225.00, '2023-03-21', 'https://images.stockx.com/images/Air-Jordan-4-Retro-SP-Nike-SB-Pine-Green-Product.jpg'),
(8, '3 Retro "White Cement Reimagined"', 'DN3707-100', 'Summit White/Fire Red/Black/Cement Grey', 210.00, '2023-03-11', 'https://images.stockx.com/images/Air-Jordan-3-Retro-White-Cement-Reimagined-Product.jpg'),
(8, '11 Retro "Gratitude"', 'CT8012-170', 'White/Black/Metallic Gold', 230.00, '2023-12-09', 'https://images.stockx.com/images/Air-Jordan-11-Retro-DMP-Defining-Moments-Pack-2023-Product.jpg'),
-- Adidas (1)
(1, 'Yeezy Slide "Onyx"', 'HQ6448', 'Onyx/Onyx/Onyx', 70.00, '2022-03-07', 'https://images.stockx.com/images/adidas-Yeezy-Slide-Onyx-Product.jpg'),
(1, 'Campus 00s "Core Black"', 'HQ8708', 'Core Black/Footwear White/Off White', 110.00, '2023-02-17', 'https://images.stockx.com/images/adidas-Campus-00s-Core-Black-Product.jpg'),
(1, 'Samba OG "Cloud White"', 'B75806', 'Cloud White/Core Black/Clear Granite', 100.00, '2018-01-01', 'https://images.stockx.com/images/adidas-Samba-OG-Cloud-White-Core-Black-Product.jpg'),
-- New Balance (11)
(11, '550 "White Green"', 'BB550WT1', 'White/Green', 110.00, '2021-06-24', 'https://images.stockx.com/images/New-Balance-550-White-Green-Product.jpg'),
(11, '2002R "Protection Pack - Rain Cloud"', 'M2002RDA', 'Rain Cloud/Magnet', 150.00, '2021-08-20', 'https://images.stockx.com/images/New-Balance-2002R-Protection-Pack-Rain-Cloud-Product.jpg'),
-- Salomon (17)
(17, 'XT-6 "Black Phantom"', 'L41086600', 'Black/Phantom', 190.00, '2022-08-01', 'https://images.stockx.com/images/Salomon-XT-6-Black-Phantom-Product.jpg'),
(17, 'XT-4 OG "Fiery Red"', 'L47132900', 'Fiery Red/Black', 220.00, '2023-03-01', 'https://images.stockx.com/images/Salomon-XT-4-OG-Fiery-Red-Aurora-Borealis-Pack-Product.jpg'),
-- ASICS (2)
(2, 'GEL-Kayano 14 "JJJJound Silver Black"', '1201A922-100', 'White/Silver/Black', 180.00, '2022-08-26', 'https://images.stockx.com/images/ASICS-Gel-Kayano-14-JJJJound-Silver-Black-Product.jpg'),
-- Converse (5)
(5, 'Chuck Taylor All-Star 70s Hi "Off-White"', '162204C', 'White/Cone-Black', 130.00, '2018-05-12', 'https://images.stockx.com/images/Converse-Chuck-Taylor-All-Star-70s-Hi-Off-White-Product.jpg'),
-- Puma (15)
(15, 'LaMelo Ball MB.03 "LaFrancé"', '379233-01', 'LaFrancé', 125.00, '2023-10-06', 'https://images.stockx.com/images/Puma-LaMelo-Ball-MB03-LaFrance-Product.jpg'),
-- Supreme (19)
(19, 'Box Logo Hooded Sweatshirt "FW23 Black"', 'FW23SW2', 'Black', 168.00, '2023-12-07', 'https://images.stockx.com/images/supreme-box-logo-hooded-sweatshirt-fw23-black.jpg'),
(19, 'Nike Air Force 1 Low "White"', 'CU9225-100', 'White/White', 100.00, '2020-03-05', 'https://images.stockx.com/images/Nike-Air-Force-1-Low-Supreme-Box-Logo-White-Product.jpg'),
-- Fear of God (7)
(7, 'Essentials Hoodie "Light Oatmeal"', '192BT212050F', 'Light Oatmeal', 90.00, '2022-03-10', 'https://images.stockx.com/images/Fear-of-God-Essentials-Pull-Over-Hoodie-String-Oatmeal-Product.jpg'),
-- BAPE (4)
(4, 'Color Camo Shark Full Zip Hoodie "Red"', '001ZPH801001M', 'Red', 435.00, '2022-01-15', 'https://images.stockx.com/images/A-Bathing-Ape-Color-Camo-Shark-Full-Zip-Hoodie-Red.jpg'),
-- Palace (14)
(14, 'Tri-Ferg T-Shirt "White"', 'P14TS001', 'White', 48.00, '2018-05-04', 'https://images.stockx.com/images/Palace-Tri-Ferg-T-shirt-White.jpg'),
-- Off-White (13)
(13, 'Out of Office "OOO" Sneaker "White Black"', 'OMIA189S21LEA0010110', 'White/Black', 550.00, '2021-01-15', 'https://images.stockx.com/images/Off-White-Out-of-Office-Sneaker-White-Black-Product.jpg'),
-- Balenciaga (3)
(3, 'Track Sneaker "Black"', '542023W1GB11000', 'Black', 1050.00, '2018-09-24', 'https://images.stockx.com/images/Balenciaga-Track-Black-Product.jpg'),
-- Stüssy (18)
(18, '8 Ball Sherpa Reversible Jacket "Natural"', '118499-NAT', 'Natural', 240.00, '2022-11-04', 'https://images.stockx.com/images/Stussy-8-Ball-Sherpa-Reversible-Jacket-Natural.jpg'),
(18, 'Converse Chuck 70 High "8-Ball"', 'A05351C', 'White/Black', 110.00, '2023-11-15', 'https://images.stockx.com/images/Converse-Chuck-70-Hi-Stussy-8-Ball-Product.jpg'),
-- Maison Margiela (10)
(10, 'Replica "GAT" Sneaker "White/Grey"', 'S57WS0236P1895', 'White/Grey', 540.00, '2017-01-01', 'https://images.stockx.com/images/Maison-Margiela-Replica-Gat-Sneaker-White-Grey-Product.jpg'),
-- Kith (9)
(9, 'Cyber Monday Hoodie "Statue"', 'KH2322-102', 'Statue', 165.00, '2021-11-29', 'https://images.stockx.com/images/Kith-Cyber-Monday-Hoodie-Statue-Product.jpg'),
-- Dior (6)
(6, 'B23 High-Top "Dior Oblique"', '3SH118YJP_H069', 'Black/White', 1200.00, '2019-01-01', 'https://images.stockx.com/images/Dior-B23-High-Top-Logo-Oblique-Product.jpg'),
-- Reebok (16)
(16, 'Club C 85 "Vintage Chalk"', 'BS8242', 'Chalk/Green', 85.00, '2016-07-01', 'https://images.stockx.com/images/Reebok-Club-C-85-Vintage-Chalk-Product.jpg'),
(16, 'JJJJound x Club C 85 "White/Chalk"', 'GX3854', 'White/Chalk', 150.00, '2022-08-05', 'https://images.stockx.com/images/Reebok-Club-C-JJJJound-White-Chalk-Product.jpg'),
-- Vans (20)
(20, 'Old Skool "Black/White"', 'VN000D3HY28', 'Black/White', 70.00, '2015-01-01', 'https://images.stockx.com/images/Vans-Old-Skool-Product.jpg'),
(20, 'Knu Skool "Black/White"', 'VN0009QCBKA', 'Black/True White', 75.00, '2023-02-01', 'https://images.stockx.com/images/Vans-Knu-Skool-Black-White-Product.jpg');

-- =============================================
--  3. LINK PRODUCTS TO SIZES
-- =============================================
-- This section populates the 'products_sizes' junction table, connecting
-- sneakers to sneaker sizes and apparel to apparel sizes.

-- Set variables for the range of sneaker and apparel size IDs
SET @sneaker_size_start_id = 1;
SET @sneaker_size_end_id = 20;
SET @apparel_size_start_id = 21;
SET @apparel_size_end_id = 26;

-- Link SNEAKER products to sneaker sizes
INSERT INTO products_sizes (product_id, size_id)
SELECT p.product_id, s.size_id
FROM products p, sizes s
WHERE s.size_id BETWEEN @sneaker_size_start_id AND @sneaker_size_end_id
  AND (
    p.name NOT LIKE '%Hoodie%' AND
    p.name NOT LIKE '%T-Shirt%' AND
    p.name NOT LIKE '%Jacket%' AND
    p.name NOT LIKE '%Pants%'
  );

-- Link APPAREL products to apparel sizes
INSERT INTO products_sizes (product_id, size_id)
SELECT p.product_id, s.size_id
FROM products p, sizes s
WHERE s.size_id BETWEEN @apparel_size_start_id AND @apparel_size_end_id
  AND (
    p.name LIKE '%Hoodie%' OR
    p.name LIKE '%T-Shirt%' OR
    p.name LIKE '%Jacket%' OR
    p.name LIKE '%Pants%'
  );

-- Commit all the changes to the database

UPDATE fee_structures SET is_active = 0 WHERE is_active = 1;

INSERT INTO fee_structures (seller_fee_percentage, buyer_fee_percentage, is_active)
VALUES (0.0600, 0.0150, 1); -- New 6% seller fee, 1.5% buyer fee

COMMIT;
