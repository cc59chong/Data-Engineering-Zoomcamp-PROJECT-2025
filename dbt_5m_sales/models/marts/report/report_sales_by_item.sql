{{ config(materialized='table') }}

SELECT
    i.item_id,
    i.dept_id,
    i.cat_id,
    SUM(f.sales) AS total_sales,
    ROUND(AVG(CAST(f.sell_price AS FLOAT64)), 2) AS avg_price,
    ROUND(SUM(f.sales * CAST(f.sell_price AS FLOAT64)), 2) AS total_revenue
FROM {{ ref('fact_sales') }} f
JOIN {{ ref('dim_item') }} i ON f.item_id = i.item_id
GROUP BY i.item_id, i.dept_id, i.cat_id
ORDER BY total_sales DESC
