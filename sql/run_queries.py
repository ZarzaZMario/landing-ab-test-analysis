"""Ejecuta las consultas de sql/conversion_queries.sql con DuckDB sobre el CSV del repositorio."""
from pathlib import Path
import duckdb

RAIZ = Path(__file__).resolve().parent.parent
sql_text = (RAIZ / 'sql' / 'conversion_queries.sql').read_text(encoding='utf-8')

con = duckdb.connect()
con.execute(f"CREATE TABLE landing AS SELECT * FROM read_csv_auto('{(RAIZ / 'data' / 'landing_experiment.csv').as_posix()}')")

for bloque in sql_text.split('-- name: ')[1:]:
    nombre, consulta = bloque.split('\n', 1)
    print(f"\n=== {nombre.strip()} ===")
    print(con.sql(consulta.strip().rstrip(';')))
