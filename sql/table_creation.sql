DROP SCHEMA IF EXISTS ecommerce;
CREATE SCHEMA ecommerce;
USE ecommerce;

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS listings;
DROP TABLE IF EXISTS bids;
DROP TABLE IF EXISTS portfolio_items;
DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS products_sizes;
DROP TABLE IF EXISTS account_balance;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS brands;
DROP TABLE IF EXISTS sizes;
DROP TABLE IF EXISTS fee_structures;



CREATE TABLE users(
    uuid CHAR(36) PRIMARY KEY NOT NULL,
    email VARCHAR(225) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    location VARCHAR(255),
    birth_date DATE,
    role ENUM('user', 'admin'),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE brands(
    brand_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    brand_name VARCHAR(250),
    brand_logo_url VARCHAR(2083)
);

CREATE TABLE sizes(
  size_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  size_value VARCHAR(50)
);

CREATE TABLE fee_structures (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    seller_fee_percentage DECIMAL(10, 4) NOT NULL,
    buyer_fee_percentage DECIMAL(10, 4) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dependent tables
CREATE TABLE account_balance(
    user_id CHAR(36) PRIMARY KEY,
    balance DECIMAL(15, 2) DEFAULT 0.00,

    FOREIGN KEY (user_id) REFERENCES users(uuid)
);

CREATE TABLE products(
    product_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    brand_id INT UNSIGNED,
    name VARCHAR(255),
    sku VARCHAR(100),
    colorway VARCHAR(250),
    retail_price DECIMAL(10, 2),
    release_date DATE,
    image_url VARCHAR(2083),
    product_type VARCHAR(100),

    FOREIGN KEY (brand_id) REFERENCES brands(brand_id)
);

CREATE TABLE products_sizes(
    product_id INT UNSIGNED,
    size_id INT UNSIGNED,

    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (size_id) REFERENCES sizes(size_id),
    PRIMARY KEY(product_id, size_id)
);

CREATE TABLE orders(
    order_id CHAR(36) PRIMARY KEY NOT NULL,
    buyer_id CHAR(36) NOT NULL,
    seller_id CHAR(36) NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    size_id INT UNSIGNED NOT NULL,
    product_condition ENUM('new', 'used', 'worn') NOT NULL,

    sale_price DECIMAL(10, 2) NOT NULL,

    buyer_transaction_fee DECIMAL(10, 2) NOT NULL,
    buyer_fee_structure_id INT UNSIGNED,
    buyer_final_price DECIMAL(10, 2) NOT NULL,

    seller_transaction_fee DECIMAL(10, 2) NOT NULL,
    seller_fee_structure_id INT UNSIGNED,
    seller_final_payout DECIMAL(10, 2) NOT NULL,

    order_status ENUM('pending', 'paid', 'shipped', 'completed', 'cancelled', 'refunded') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (buyer_id) REFERENCES users(uuid),
    FOREIGN KEY (seller_id) REFERENCES users(uuid),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (size_id) REFERENCES sizes(size_id),
    FOREIGN KEY (buyer_fee_structure_id) REFERENCES fee_structures(id) ON DELETE SET NULL,
    FOREIGN KEY (seller_fee_structure_id) REFERENCES fee_structures(id) ON DELETE SET NULL
);

CREATE TABLE addresses(
    address_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id CHAR(36),
    order_id CHAR(36),
    purpose ENUM('billing', 'shipping', 'both'),
    name VARCHAR(100),
    address_line_1 VARCHAR(255),
    address_line_2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20),
    country VARCHAR(100),

    FOREIGN KEY (user_id) REFERENCES users(uuid),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE SET NULL
);

CREATE TABLE listings(
    listing_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id CHAR(36),
    product_id INT UNSIGNED,
    size_id INT UNSIGNED,
    listing_type ENUM('sale', 'ask'),
    price DECIMAL(10, 2),
    fee_structure_id INT UNSIGNED NOT NULL,
    item_condition ENUM('new', 'used', 'worn'),
    status ENUM('active', 'sold', 'canceled', 'pending'),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(uuid),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (size_id) REFERENCES sizes(size_id),
    FOREIGN KEY (fee_structure_id) REFERENCES fee_structures(id)
);

CREATE TABLE portfolio_items(
    portfolio_item_id CHAR(36) PRIMARY KEY NOT NULL,
    user_id CHAR(36),
    product_id INT UNSIGNED,
    size_id INT UNSIGNED,
    acquisition_date DATE,
    acquisition_price DECIMAL(10, 2),
    item_condition ENUM('new', 'used', 'worn'),

    FOREIGN KEY (user_id) REFERENCES users(uuid),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (size_id) REFERENCES sizes(size_id)
);

CREATE TABLE bids(
    bid_id CHAR(36) PRIMARY KEY NOT NULL,
    user_id CHAR(36),
    product_id INT UNSIGNED,
    size_id INT UNSIGNED,
    product_condition ENUM('new', 'used', 'worn'),
    bid_amount DECIMAL(10, 2),
    transaction_fee DECIMAL(10, 2),
    fee_structure_id INT UNSIGNED,
    total_bid_amount DECIMAL(10, 2),
    bid_status ENUM('active', 'accepted', 'rejected', 'expired'),
    payment_origin ENUM('account_balance', 'credit_card', 'other') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(uuid),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (size_id) REFERENCES sizes(size_id),
    FOREIGN KEY (fee_structure_id) REFERENCES fee_structures(id)
);

CREATE TABLE transactions(
    transaction_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id CHAR(36) NOT NULL,
    order_id CHAR(36),
    amount DECIMAL(10, 2) NOT NULL,
    transaction_status ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL,
    payment_origin ENUM('account_balance', 'credit_card', 'other'),
    payment_destination ENUM('account_balance', 'bank_transfer', 'other'),
    payment_purpose ENUM('sale_proceeds', 'purchase_funds', 'refund', 'fee', 'balance_adjustment') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(uuid),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE SET NULL
);