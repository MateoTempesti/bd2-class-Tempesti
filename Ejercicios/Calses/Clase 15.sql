USE sakila;

-- CONSULTA 1
-- Crear una vista llamada lista_de_clientes que contenga las siguientes columnas:
--    id del cliente
--    nombre completo del cliente,
--    dirección
--    código postal
--    teléfono
--    ciudad
--    país
--    estado (cuando la columna activa sea 1, mostrar como 'activo', de lo contrario 'inactivo')
--    id de tienda

CREATE VIEW lista_de_clientes AS 
	SELECT cus.customer_id AS 'ID del Cliente', CONCAT(cus.first_name, ' ', cus.last_name) AS 'Nombre del Cliente',
    a.address AS 'Dirección', a.postal_code AS 'Código Postal', a.phone AS 'Teléfono', ci.city AS 'Ciudad', co.country AS 'País',
    CASE WHEN cus.active = 1 THEN 'activo' ELSE 'inactivo' END AS 'Estado', cus.store_id AS 'ID de Tienda' 
    FROM customer cus 
    INNER JOIN address a USING (address_id) 
    INNER JOIN city ci USING (city_id) 
    INNER JOIN country co USING (country_id);
    
SELECT * FROM lista_de_clientes;

-- CONSULTA 2
-- Crear una vista llamada detalles_de_peliculas que contenga las siguientes columnas: 
-- id de película, título, descripción, categoría, precio, duración, calificación, actores - como una cadena de todos los actores separados por comas. 
-- Sugerencia: usar GROUP_CONCAT

CREATE VIEW detalles_de_peliculas AS
	SELECT f.film_id AS 'ID de Película', f.title AS 'Título', f.description AS 'Descripción', cat.name AS 'Categoría', 
    f.rental_rate AS 'Precio', f.length AS 'Duración', f.rating AS 'Calificación', 
    GROUP_CONCAT(' ', a.first_name, ' ', a.last_name) AS 'Actores'
    FROM film f 
    INNER JOIN film_category fc USING (film_id) 
    INNER JOIN category cat USING (category_id) 
    INNER JOIN film_actor fa USING (film_id) 
    INNER JOIN actor a USING (actor_id) 
    GROUP BY f.film_id, cat.name;

SELECT * FROM detalles_de_peliculas;
DROP VIEW detalles_de_peliculas;

-- CONSULTA 3
-- Crear una vista llamada ventas_por_categoria_de_peliculas que devuelva las columnas 'categoría' y 'total_renta'.

CREATE VIEW ventas_por_categoria_de_peliculas AS
	SELECT c.name AS 'Categoría', COUNT(r.rental_id) AS 'Total de Rentas' 
    FROM category c 
    INNER JOIN film_category USING (category_id) 
    INNER JOIN film f USING (film_id) 
    INNER JOIN inventory i USING (film_id) 
    INNER JOIN rental r USING (inventory_id) 
    GROUP BY c.category_id;
    
SELECT * FROM ventas_por_categoria_de_peliculas;

-- CONSULTA 4
-- Crear una vista llamada información_de_actores que retorne, id de actor, nombre, apellido y la cantidad de películas en las que actuó.

CREATE VIEW información_de_actores AS
	SELECT a.actor_id AS 'ID de Actor', a.first_name AS 'Nombre', a.last_name AS 'Apellido', COUNT(fa.film_id) AS 'Películas Actuadas'
    FROM actor a 
    INNER JOIN film_actor fa USING (actor_id) 
    GROUP BY a.actor_id;
    
SELECT * FROM información_de_actores;

-- CONSULTA 5
-- Analizar la vista información_de_actores, explicar toda la consulta y, especialmente, cómo funciona la subconsulta. 
-- Sé muy específico, tómate un tiempo y descompón cada parte y da una explicación para cada una.

SELECT * FROM información_de_actores;
/*
Esta vista tiene como objetivo retornar información para cada actor en la base de datos, junto con las películas en las que ha participado, agrupadas por categoría de la película. 
La vista selecciona el id del actor, nombre, apellido y un campo llamado info_peliculas, que consiste en una concatenación de cada categoría distinta y 
una lista de todas las películas que pertenecen a esa categoría en las que el actor ha aparecido. Esto se logra mediante un LEFT JOIN desde la tabla de actores a film_actor, 
film_category y category para recopilar datos sobre las películas en las que trabajó cada actor y sus respectivas categorías, asegurando que los actores que no están en ninguna película también se incluyan.

La subconsulta que construye info_peliculas funciona de la siguiente manera: Primero, el GROUP_CONCAT externo une cada nombre de categoría distinto con el resultado de la subconsulta interna, separados por dos puntos (:). 
La subconsulta interna devuelve un GROUP_CONCAT de todos los títulos de las películas (ordenados alfabéticamente y separados por comas) para cada película que coincide tanto con el category_id de 
la categoría actual (de la tabla film_category) como con el actor_id del actor actual (de la tabla film_actor). De esta forma, la vista completa devolverá: 
id_actor, nombre_actor, apellido_actor y un campo como [categoria1: pelicula1, pelicula2..., categoria2:...] para cada actor.
*/

-- CONSULTA 6
-- Vistas materializadas, escribe una descripción, por qué se utilizan, alternativas, SGBD donde existen, etc.

/*
Una vista materializada es un tipo de vista que almacena el resultado de una consulta como una tabla física en disco. La principal diferencia entre este tipo y las vistas regulares es que 
las vistas materializadas almacenan el resultado específico de una consulta en un momento dado directamente en el disco, en lugar de ser almacenadas virtualmente y actualizadas dinámicamente cuando se requieren. 
Esto significa que la información se puede acceder sin consumir los recursos que llevaría recuperar los datos, lo cual es especialmente beneficioso 
para consultas más grandes con muchas uniones y filtros. Sin embargo, debido a la forma en que se almacenan, los datos en una vista materializada no se actualizan a menos que se actualicen manualmente, 
por lo que la información puede volverse obsoleta.

Este tipo de vista es útil cuando se tienen tablas con un gran número de operaciones, como uniones, agregaciones y filtros, que no necesitan ser actualizadas con frecuencia. 
Un ejemplo de esto sería un informe periódico que captura el estado actual de la base de datos y que no necesita ser refrescado en tiempo real.

Algunas alternativas a las vistas materializadas son las vistas regulares y los índices. Las vistas regulares tienen la ventaja de actualizarse constantemente, pero esto puede causar problemas de rendimiento. 
Los índices pueden usarse para almacenar columnas específicas en la RAM, que también se actualizan automáticamente, pero tienen un rango limitado y disminuyen el rendimiento a medida que se usan más índices.

Algunos de los SGBD (Sistemas de Gestión de Bases de Datos) que soportan vistas materializadas incluyen Oracle, PostgreSQL, Snowflake y Google BigQuery. 
Aunque MySQL no soporta nativamente las vistas materializadas, se pueden simular usando vistas regulares y triggers.
*/
