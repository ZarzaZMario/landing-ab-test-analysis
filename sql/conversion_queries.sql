-- Consultas SQL (DuckDB) que reproducen las métricas principales del notebook.
-- Ejecutar desde la raíz del repositorio:  python sql/run_queries.py
-- La tabla `landing` se crea a partir de data/landing_experiment.csv.

-- name: 01_conversion_por_variante
SELECT
    landing,
    COUNT(*)                                    AS usuarios,
    SUM(converted)                              AS compradores,
    ROUND(100.0 * AVG(converted), 2)            AS conversion_pct,
    ROUND(AVG(gasto), 2)                        AS arpu,
    ROUND(AVG(gasto) FILTER (WHERE converted = 1), 2) AS ticket_promedio
FROM landing
GROUP BY landing
ORDER BY landing;

-- name: 02_conversion_por_fuente_y_variante
SELECT
    traffic_source,
    ROUND(100.0 * AVG(converted) FILTER (WHERE landing = 'A'), 2) AS conv_a_pct,
    ROUND(100.0 * AVG(converted) FILTER (WHERE landing = 'B'), 2) AS conv_b_pct,
    ROUND(100.0 * (AVG(converted) FILTER (WHERE landing = 'B')
                 - AVG(converted) FILTER (WHERE landing = 'A')), 2) AS diff_pp,
    COUNT(*) AS usuarios
FROM landing
GROUP BY traffic_source
ORDER BY usuarios DESC;

-- name: 03_conversion_por_tipo_usuario_y_variante
SELECT
    user_type,
    ROUND(100.0 * AVG(converted) FILTER (WHERE landing = 'A'), 2) AS conv_a_pct,
    ROUND(100.0 * AVG(converted) FILTER (WHERE landing = 'B'), 2) AS conv_b_pct,
    ROUND(100.0 * (AVG(converted) FILTER (WHERE landing = 'B')
                 - AVG(converted) FILTER (WHERE landing = 'A')), 2) AS diff_pp,
    COUNT(*) AS usuarios
FROM landing
GROUP BY user_type
ORDER BY usuarios DESC;

-- name: 04_control_srm_y_duplicados
SELECT
    COUNT(*)                                   AS filas,
    COUNT(DISTINCT user_id)                    AS usuarios_unicos,
    SUM(CASE WHEN landing = 'B' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS proporcion_b,
    SUM(CASE WHEN converted = 1 AND gasto = 0 THEN 1 ELSE 0 END)  AS compras_sin_gasto,
    SUM(CASE WHEN converted = 0 AND gasto > 0 THEN 1 ELSE 0 END)  AS gasto_sin_compra
FROM landing;
