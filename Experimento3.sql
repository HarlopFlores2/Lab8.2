-- Crear la tabla Articles con los atributos textuales
CREATE TABLE articles (
    id SERIAL PRIMARY KEY,
    title TEXT,
    publication TEXT,
    author TEXT,
    content TEXT
);

-- Llenar los datos desde los archivos CSV pero hay que asegurarse que este en el formato correcto.
COPY articles(title, publication, author, content)
FROM '/path/articles1.csv'
DELIMITER ','
CSV HEADER;

-- Crear un nuevo atributo indexado compuesto por el título, la publicación, el autor y el contenido
ALTER TABLE articles ADD COLUMN indexado tsvector;

-- Actualizar
UPDATE articles SET indexado = T.indexado
FROM (
    SELECT id,
        setweight(to_tsvector('english', title), 'A') ||
        setweight(to_tsvector('english', publication), 'B') ||
        setweight(to_tsvector('english', author), 'C') ||
        setweight(to_tsvector('english', content), 'D')
        AS indexado
    FROM articles
) AS T
WHERE articles.id = T.id;

-- Crear un índice GIN en el nuevo atributo
CREATE INDEX indexado_gin_idx ON articles USING gin(indexado);

-- Ejecutar consultas 

-- Consulta sin indexar
\o '/path/output1.csv'
EXPLAIN ANALYZE SELECT title, publication, author, content FROM articles WHERE title LIKE '%query%' OR publication LIKE '%query%' OR author LIKE '%query%' OR content LIKE '%query%';
\o

-- Consulta indexada
\o '/path/output2.csv'
EXPLAIN ANALYZE SELECT title, publication, author, content FROM articles WHERE to_tsquery('english', 'query') @@ indexado;
\o

-- Consulta indexada con ranking
\o '/path/output3.csv'
EXPLAIN ANALYZE SELECT title, publication, author, content, ts_rank_cd(indexado, to_tsquery('english', 'query')) AS rank FROM articles, to_tsquery('english', 'query') AS query WHERE query @@ indexado ORDER BY rank DESC LIMIT 2;
\o
