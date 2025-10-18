USE ecommerce;

DELIMITER //

CREATE PROCEDURE updateUser(
    IN input_uuid CHAR(36),
    IN input_email VARCHAR(225),
    IN input_first_name VARCHAR(100),
    IN input_last_name VARCHAR(100),
    IN input_location VARCHAR(255),
    IN input_birth_date DATE,
    IN input_role ENUM('user', 'admin')
)

BEGIN

  UPDATE users
  SET
    email = IF(input_email IS NULL, email, input_email),
    first_name = IF(input_first_name IS NULL, first_name, input_first_name),
    last_name = IF(input_last_name IS NULL, last_name, input_last_name),
    location = IF(input_location IS NULL, location, input_location),
    birth_date = IF(input_birth_date IS NULL, birth_date, input_birth_date),
    role = IF(input_role IS NULL, role, input_role)
  WHERE uuid = input_uuid;

  SELECT
    uuid,
    email,
    first_name,
    last_name,
    location,
    birth_date,
    role,
    created_at,
    updated_at
  FROM users
  WHERE uuid = input_uuid;

END//

DELIMITER ;