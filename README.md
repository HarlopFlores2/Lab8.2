# Lab8.2
# Experimento 1:
## Ejemplo de plan de ejecucion:
### Ejemplo para 1 Millon de registros:
```sql
QUERY PLAN							
---------------------------------------------------------------------------------------------------------------------------							
Gather  (cost=1000.00..18564.05 rows=100 width=66) (actual time=101.111..105.577 rows=0 loops=1)							
Workers Planned: 2							
Workers Launched: 2							
->  Parallel Seq Scan on test_table  (cost=0.00..17554.05 rows=42 width=66) (actual time=63.437..63.438 rows=0 loops=3)							
Filter: (non_indexed_column ~~ '%query%'::text)							
Rows Removed by Filter: 333333							
Planning Time: 0.088 ms							
Execution Time: 105.593 ms							
(8 filas)							
							
QUERY PLAN							
---------------------------------------------------------------------------------------------------------------------							
Bitmap Heap Scan on test_table  (cost=596.77..971.03 rows=100 width=66) (actual time=0.442..0.442 rows=0 loops=1)							
Recheck Cond: (indexed_column ~~ '%query%'::text)							
->  Bitmap Index Scan on trgm_idx  (cost=0.00..596.75 rows=100 width=0) (actual time=0.441..0.441 rows=0 loops=1)							
Index Cond: (indexed_column ~~ '%query%'::text)							
Planning Time: 0.073 ms							
Execution Time: 0.465 ms							
(6 filas)							
```

Grafico Final:
