USE sakila;

-- QUERY 1
-- Create a user data_analyst.

CREATE USER 'data_analyst'@'localhost' IDENTIFIED BY 'password';
-- Uses localhost
CREATE USER 'data_analyst'@'%' IDENTIFIED BY 'password';
-- Uses any host

-- QUERY 2
-- Grant permissions only to SELECT, UPDATE and DELETE to all sakila tables to it.

GRANT SELECT, UPDATE, DELETE ON sakila.* TO 'data_analyst'@'localhost';
SHOW GRANTS FOR data_analyst;

-- QUERY 3
-- Login with this user and try to create a table. Show the result of that operation.

CREATE TABLE neighborhood (
  neighborhood_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  neighborhood VARCHAR(50) NOT NULL,
  city_id SMALLINT UNSIGNED NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (neighborhood_id),
  KEY idx_fk_city_id (city_id),
  CONSTRAINT fk_neighborhood_city FOREIGN KEY (city_id) REFERENCES city (city_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*
ERROR 1142 (42000): CREATE command denied to user 'data_analyst'@'localhost' for table 'neighborhood'
*/

-- QUERY 4
-- Try to update a title of a film. Write the update script.

SELECT title FROM film WHERE film_id = 371;
UPDATE film SET title='La Mandarina Mecanica' WHERE film_id = 371;

-- QUERY 5
-- With root or any admin user revoke the UPDATE permission. Write the command

REVOKE UPDATE ON sakila.*  FROM 'data_analyst'@'localhost';
FLUSH PRIVILEGES;

-- QUERY 6
-- Login again with data_analyst and try again the update done in step 4. Show the result.

UPDATE film SET title='La Casa de Freezer' WHERE film_id = 371;
/*
ERROR 1142 (42000): UPDATE command denied to user 'data_analyst'@'localhost' for table 'film'
*/