{{ config(materialized='table') }}

SELECT
    s.store_id,
    s.state_id,
    SUM(f.sales) AS total_sales,
    ROUND(AVG(CAST(f.sell_price AS FLOAT64)), 2) AS avg_price,
    ROUND(SUM(f.sales * CAST(f.sell_price AS FLOAT64)), 2) AS total_revenue
FROM {{ ref('fact_sales') }} f
JOIN {{ ref('dim_store') }} s ON f.store_id = s.store_id
GROUP BY s.store_id, s.state_id
ORDER BY total_sales DESC
