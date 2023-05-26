-- Crear un nuevo atributo indexado compuesto por el título y la descripción de la película.
ALTER TABLE film ADD COLUMN indexado tsvector;

-- Actualizar el nuevo atributo
UPDATE film SET indexado = T.indexado
FROM (
    SELECT film_id,
        setweight(to_tsvector('english', title), 'A') ||
        setweight(to_tsvector('english', description), 'B')
        AS indexado
    FROM film
) AS T
WHERE film.film_id = T.film_id;

-- Crear un índice GIN en el nuevo atributoo
CREATE INDEX indexado_gin_idx ON film USING gin(indexado);

-- Ejecutar consultas

-- Consulta sin indexar
\o '/path/1-1.csv'
EXPLAIN ANALYZE SELECT title, description FROM film WHERE description ILIKE '%man%' OR description ILIKE '%woman%';
\o

-- Consulta indexada
\o '/path/1-2.csv'
EXPLAIN ANALYZE SELECT title, description FROM film WHERE to_tsquery('english', 'Man | Woman') @@ indexado;
\o

-- Consulta indexada con ranking
\o '/path/1-3.csv'
EXPLAIN ANALYZE SELECT title, description, ts_rank_cd(indexado, to_tsquery('english', 'Man | Woman')) AS rank FROM film, to_tsquery('english', 'Man | Woman') AS query WHERE query @@ indexado ORDER BY rank DESC LIMIT 2;
\o
