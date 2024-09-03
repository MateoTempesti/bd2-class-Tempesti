use sakila;

-- Query1: Insert a new employee to , but with an null email. Explain what happens.

INSERT INTO employees (employeeNumber, lastName, firstName, extension, officeCode, reportsTo, jobTitle, email)
VALUES (142, 'Argento', 'Pepe', 'a', 1, 1, 'Employee', NULL);

-- Error Code: 1048. Column 'email' cannot be null
-- El campo 'email' está configurado con la restricción NOT NULL, por lo que no acepta valores nulos.


-- Ejercicio 2 
-- Run the first the query "UPDATE employees SET employeeNumber = employeeNumber - 20" What did happen? Explain. 
-- Then run this other "UPDATE employees SET employeeNumber = employeeNumber + 20"


UPDATE employees SET employeeNumber = employeeNumber - 20;
--  Se resta 20 al valor de employeeNumber para todas las filas existentes.

UPDATE employees SET employeeNumber = employeeNumber + 20;
-- Se incrementa en 20 el valor de employeeNumber para cada fila en la tabla employees.


-- query3 Add a age column to the table employee where and it can only accept values from 16 up to 70 years old.

ALTER TABLE employees 
ADD COLUMN age int DEFAULT 16, 
ADD CONSTRAINT check_age CHECK (age BETWEEN 16 AND 70);


-- 4 Describe the referential integrity between tables film, actor and film_actor in sakila db.

--  La clave foránea que enlaza las tablas film y actor asegura la integridad referencial.
-- La tabla intermedia guarda las claves primarias de ambas tablas, evitando que se eliminen
-- registros de film o actor sin antes eliminar los registros relacionados en la tabla intermedia.


-- query 5 Create a new column called lastUpdate to table employee and use trigger(s) to keep the date-time updated on inserts and updates operations. Bonus: 
-- add a column lastUpdateUser and the respective trigger(s) to specify who was the last MySQL user that changed the row 
-- (assume multiple users, other than root, can connect to MySQL and change this table).


ALTER TABLE employees
ADD COLUMN lastUpdate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN lastUpdateUser VARCHAR(50) NOT NULL DEFAULT CURRENT_USER();

DELIMITER $$

CREATE TRIGGER before_employee_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    SET NEW.lastUpdate = CURRENT_TIMESTAMP;
    SET NEW.lastUpdateUser = CURRENT_USER();
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER before_employee_update
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    SET NEW.lastUpdate = CURRENT_TIMESTAMP;
    SET NEW.lastUpdateUser = CURRENT_USER();
END$$

DELIMITER ;


-- query 6 Find all the triggers in sakila db related to loading film_text table. What do they do? 
-- Explain each of them using its source code for the explanation.

SELECT TRIGGER_NAME, EVENT_MANIPULATION, ACTION_TIMING, ACTION_STATEMENT FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'sakila' AND EVENT_OBJECT_TABLE = 'film_text';

DELIMITER $$

CREATE TRIGGER film_text_insert_trigger
BEFORE INSERT ON film_text
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM film WHERE film_id = NEW.film_id) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid film_id';
    END IF;

    SET NEW.title = (SELECT title FROM film WHERE film_id = NEW.film_id);
    SET NEW.description = (SELECT description FROM film WHERE film_id = NEW.film_id);
END$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER film_text_update_trigger
BEFORE UPDATE ON film_text
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM film WHERE film_id = NEW.film_id) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid film_id';
    END IF;

    SET NEW.title = (SELECT title FROM film WHERE film_id = NEW.film_id);
    SET NEW.description = (SELECT description FROM film WHERE film_id = NEW.film_id);
END$$

DELIMITER ;

