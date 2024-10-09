USE sakila;

-- CONSULTA 1
-- Crear dos o tres consultas utilizando la tabla de direcciones en la base de datos sakila:
--    incluir postal_code en la cláusula where (intenta con los operadores in/not in)
--    eventualmente unir la tabla con las tablas ciudad/pais.
--    medir el tiempo de ejecución.
--    Luego, crear un índice para postal_code en la tabla de direcciones.
--    medir el tiempo de ejecución nuevamente y comparar con los anteriores.
--    Explicar los resultados.

-- Ejemplos de consultas
SELECT postal_code AS 'Código Postal' 
FROM address 
WHERE postal_code IN (SELECT postal_code FROM address WHERE address_id > 500);

SELECT district AS 'Distrito', 
    GROUP_CONCAT('Dirección: ', address, ' ', address2, ', Código Postal: ', postal_code SEPARATOR ' // ') AS 'Dirección y Código Postal' 
FROM address 
GROUP BY district;

SELECT CONCAT(a.address, ' ', a.address2) AS 'Dirección', 
    a.postal_code AS 'Código Postal', 
    CONCAT(ci.city, ', ', co.country) AS 'Ciudad y País' 
FROM address a 
INNER JOIN city ci USING (city_id) 
INNER JOIN country co USING (country_id)
WHERE a.postal_code NOT IN (SELECT a.postal_code 
    FROM address a 
    INNER JOIN city ci USING (city_id) 
    INNER JOIN country co USING (country_id) 
    WHERE ci.city NOT LIKE 'A%' AND ci.city NOT LIKE 'E%' 
        AND ci.city NOT LIKE 'I%' AND ci.city NOT LIKE 'O%' 
        AND ci.city NOT LIKE 'U%');

DROP INDEX postal_code ON address;
/*
Duraciones sin Índices:
Duración Consulta 1: 0.00094 sec / 0.000017 sec
Duración Consulta 2: 0.0010 sec / 0.00018 sec
Duración Consulta 3: 0.0082 sec / 0.000021 sec
*/

CREATE INDEX postal_code ON address(postal_code);
/*
Duraciones con Índices:
Duración Consulta 1: 0.00066 sec / 0.000016 sec
Duración Consulta 2: 0.00093 sec / 0.00018 sec
Duración Consulta 3: 0.0061 sec / 0.000021 sec
*/

/*
Los índices en MySQL funcionan almacenando físicamente las filas de las tablas indexadas en el almacenamiento del disco para recuperar rápidamente la información. 
Esto lleva a tiempos de consulta más bajos, ya que no es necesario escanear toda la tabla al obtener la información.

Aunque es difícil notar, hay una mejora en la velocidad de búsqueda y comparación de las consultas, principalmente en las consultas 1 y 3, donde se utiliza 
postal_code para filtrar y comparar. Dado que estas consultas son bastante simples, las diferencias en duración pueden ser pequeñas. Sin embargo, en consultas a mayor escala, 
los cambios en la velocidad serán evidentes.
*/

-- CONSULTA 2
-- Ejecutar consultas utilizando la tabla actor, buscando las columnas de nombre y apellido de manera independiente. 
-- Explicar las diferencias y por qué están ocurriendo.

SELECT first_name FROM actor WHERE first_name LIKE 'A%';
SELECT last_name FROM actor WHERE last_name LIKE 'A%';

/*
Al ejecutar estas dos consultas, hay una diferencia ligeramente más clara en sus tiempos de ejecución en comparación con la actividad anterior.
La primera consulta, que recupera el `first_name` de cada actor (una columna que no está indexada), tiene una duración promedio de 0.0011 sec / 0.000025 sec,
mientras que la segunda consulta, que utiliza la columna indexada `last_name`, tiene una duración promedio de 0.00076 sec / 0.000016 sec.

Dado que el conjunto de datos es relativamente pequeño, al igual que en la Actividad N°1, la diferencia sigue siendo mínima. Sin embargo, la brecha en los tiempos de ejecución se volvería 
significativamente más pronunciada con un conjunto de datos más grande. Esto se debe a que `last_name` se beneficia de la presencia de un índice, lo que permite a la base de datos localizar rápidamente 
las filas que coinciden con los criterios, mientras que `first_name` no tiene índice y requiere un escaneo completo de cada fila para encontrar los valores coincidentes.
*/

-- CONSULTA 3
-- Comparar resultados buscando texto en la descripción de la tabla film con LIKE y en film_text usando MATCH ... AGAINST. Explicar los resultados.

SELECT f.film_id AS 'ID', f.title AS 'Título', f.description AS 'Texto de Descripción' 
FROM film f 
WHERE f.description LIKE '%Girl%';

SELECT ft.film_id AS 'ID', ft.title AS 'Título', ft.description AS 'Texto de Descripción' 
FROM film_text ft 
WHERE MATCH(ft.title, ft.description) AGAINST ('Girl');

/*
Al comparar estas dos consultas, la diferencia más importante es que la consulta que utiliza MATCH / AGAINST se ejecuta más rápido que la que usa LIKE. 
Esto se debe a que el operador LIKE escanea toda la tabla, verificando cada fila de descripción individualmente para ver si contiene 'Girl', lo que es ineficiente para campos de texto grandes. 
Por otro lado, MATCH / AGAINST utiliza el índice FULLTEXT creado en la tabla film_text para encontrar rápidamente todos los resultados coincidentes sin tener que escanear cada fila.

Esto significa que, para consultas que necesitan analizar registros con campos de texto grandes, crear un índice FULLTEXT sería ideal para filtrar los resultados de manera eficiente, 
mientras que LIKE aún puede ser útil para objetos de texto más pequeños o patrones simples. Esto significa que, dependiendo del tamaño y tipo de datos de texto que se buscan, 
usar índices FULLTEXT puede mejorar significativamente el rendimiento en comparación con LIKE.
*/
