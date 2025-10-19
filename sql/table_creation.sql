DROP SCHEMA IF EXISTS ecommerce;
CREATE SCHEMA ecommerce;
USE ecommerce;

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS listings;
DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS products_sizes;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS brands;
DROP TABLE IF EXISTS sizes;


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

CREATE TABLE products(
    product_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    brand_id INT UNSIGNED,
    name VARCHAR(255),
    sku VARCHAR(100),
    colorway VARCHAR(250),
    retail_price DECIMAL(10, 2),
    release_date DATE,
    image_url VARCHAR(2083),

    FOREIGN KEY (brand_id) REFERENCES brands(brand_id)
);

CREATE TABLE sizes(
  size_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  size_value VARCHAR(50)
);

CREATE TABLE products_sizes(
    product_id INT UNSIGNED,
    size_id INT UNSIGNED,

    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (size_id) REFERENCES sizes(size_id),
    PRIMARY KEY(product_id, size_id)
);

CREATE TABLE listings(
    listing_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id CHAR(36),
    product_id INT UNSIGNED,
    size_id INT UNSIGNED,
    listing_type ENUM('sale', 'ask'),
    price DECIMAL(10, 2),
    item_condition ENUM('new', 'used', 'worn'),
    status ENUM('active', 'sold', 'canceled', 'pending'),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(uuid),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (size_id) REFERENCES sizes(size_id)
);

CREATE TABLE orders(
    order_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    buyer_id CHAR(36),
    seller_id CHAR(36),
    product_id INT UNSIGNED,
    size_id INT UNSIGNED,
    sale_price DECIMAL(10, 2),
    transaction_fee DECIMAL(10, 2),
    total_price DECIMAL(10, 2),
    order_status ENUM('pending', 'paid', 'shipped', 'completed', 'cancelled', 'refunded'),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (buyer_id) REFERENCES users(uuid),
    FOREIGN KEY (seller_id) REFERENCES users(uuid),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (size_id) REFERENCES sizes(size_id)
);

CREATE TABLE transactions(
    transaction_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id CHAR(36) NOT NULL,
    order_id INT UNSIGNED,
    amount DECIMAL(10, 2),
    transaction_status ENUM('pending', 'completed', 'failed', 'refunded'),
    payment_gateway_id VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(uuid),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE addresses(
    address_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id CHAR(36),
    purpose ENUM('billing', 'shipping', 'both'),
    name VARCHAR(100),
    address_line_1 VARCHAR(255),
    address_line_2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20),
    country VARCHAR(100),

    FOREIGN KEY (user_id) REFERENCES users(uuid)
);