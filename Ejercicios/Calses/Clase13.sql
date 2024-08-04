use sakila;

-- query 1:
-- To store 1
-- For address use an existing address. The one that has the biggest address_id in 'United States'

INSERT INTO customer (store_id, first_name, last_name, email, address_id, create_date) VALUES
(2, 'Carlos', 'Martínez', 'carlosmartinez@example.com',
(SELECT MAX(address.address_id) FROM address
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
WHERE country.country = 'United States'),
NOW());

-- query 2
-- Add a rental

-- Make easy to select any film title. I.e. I should be able to put 'film tile' in the where, and not the id.
-- Do not check if the film is already rented, just use any from the inventory, e.g. the one with highest id.
-- Select any staff_id from Store 2.


INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id, return_date)
SELECT NOW(), inventory_id, customer_id, staff_id, NULL
FROM (
    SELECT i.inventory_id, c.customer_id, s.staff_id
    FROM inventory i
    JOIN film f ON i.film_id = f.film_id
    JOIN customer c ON c.store_id = i.store_id
    JOIN staff s ON s.store_id = i.store_id
    WHERE f.title = 'film title'
    AND i.store_id = 2
    ORDER BY i.inventory_id DESC
    LIMIT 1
) AS subquery;

-- Query 3: Update film year based on the rating
-- For example if rating is 'G' release date will be '2001'
-- You can choose the mapping between rating and year.
-- Write as many statements are needed.

UPDATE film
SET release_year = CASE rating
    WHEN 'G' THEN '2001'
    WHEN 'PG' THEN '2002'
    WHEN 'PG-13' THEN '2003'
    WHEN 'R' THEN '2004'
    WHEN 'NC-17' THEN '2005'
    ELSE 'Unknown'
END;

-- Query 4: Return a film
-- Write the necessary statements and queries for the following steps.
-- Find a film that was not yet returned. And use that rental id. Pick the latest that was rented for example.
-- Use the id to return the film.

UPDATE rental SET 
return_date = NOW()
WHERE rental_id = (SELECT MAX(rental_id) WHERE rental_date = 
(SELECT MAX(rental_date) WHERE return_date IS null));


-- Query 5: Try to delete a film
-- Check what happens, describe what to do.
-- Write all the necessary delete statements to entirely remove the film from the DB.

DELETE FROM inventory
WHERE film_id = 1000;

DELETE FROM rental
WHERE inventory_id IN (
    SELECT inventory_id
    FROM inventory
    WHERE film_id = 1000
);

DELETE FROM film_actor
WHERE film_id = 1000;


DELETE FROM film_category
WHERE film_id = 1000;


DELETE FROM film
WHERE film_id = 1000;

-- Query 6: Rent a film
-- Find an inventory id that is available for rent (available in store) pick any movie. Save this id somewhere.
-- Add a rental entry
-- Add a payment entry
-- Use sub-queries for everything, except for the inventory id that can be used directly in the queries.

SELECT * 
FROM inventory 
LEFT JOIN rental ON inventory.inventory_id = rental.inventory_id 
WHERE rental.rental_id IS NULL 
LIMIT 1;

INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update) 
VALUES
(NOW(), 5, (SELECT customer_id FROM customer ORDER BY RAND() LIMIT 1), 
DATE_ADD(NOW(), INTERVAL 30 DAY),
(SELECT staff_id FROM staff WHERE store_id = (SELECT store_id FROM inventory WHERE inventory_id = 5) 
ORDER BY RAND() LIMIT 1), NOW());

INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date, last_update) 
VALUES
((SELECT customer_id FROM rental WHERE inventory_id = 5), (SELECT staff_id FROM rental WHERE inventory_id = 5), 
(SELECT rental_id FROM rental WHERE inventory_id = 5),
3.99, DATE_ADD((SELECT rental_date FROM rental WHERE inventory_id = 5), INTERVAL 1 DAY), NOW());

SELECT * FROM rental WHERE inventory_id = 5;
SELECT * FROM payment WHERE rental_id = 16050;