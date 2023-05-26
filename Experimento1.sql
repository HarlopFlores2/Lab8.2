CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- Paso 1:
CREATE TABLE test_table (
    non_indexed_column TEXT,
    indexed_column TEXT
);

CREATE INDEX idx_gin_trgm ON test_table USING gin (indexed_column gin_trgm_ops);

-- Paso 2:
INSERT INTO test_table (non_indexed_column, indexed_column)
SELECT md5(random()::text), md5(random()::text)
-- Cambiar el valor a lo que se desee
FROM generate_series(1, 200000); 

-- Paso 3:
-- Cambiar el path a donde quieras exportar un CSV.
\o 'C:/BD/output.csv'
EXPLAIN ANALYZE SELECT * FROM test_table WHERE non_indexed_column LIKE '%query%';
EXPLAIN ANALYZE SELECT * FROM test_table WHERE indexed_column LIKE '%query%';
\o

-- Repetir pasos 2 y 3 para crear el grafico
