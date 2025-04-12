{{ config(materialized='table') }}

WITH base AS (
    SELECT
        f.date,
        c.weekday,
        c.wday,
        c.month,
        c.year,
        FORMAT_DATE('%Y-%W', f.date) AS week,
        FORMAT_DATE('%Y-%m', f.date) AS month_str,
        f.sales,
        CAST(f.sell_price AS FLOAT64) AS sell_price
    FROM {{ ref('fact_sales') }} f
    JOIN {{ ref('dim_calendar') }} c
      ON f.date = c.date
),

aggregated AS (
    SELECT
        'daily' AS time_granularity,
        FORMAT_DATE('%Y-%m-%d', date) AS time_value,
        SUM(sales) AS total_sales,
        ROUND(SUM(sales * sell_price), 2) AS total_revenue
    FROM base
    GROUP BY time_granularity, time_value

    UNION ALL

    SELECT
        'weekly' AS time_granularity,
        week AS time_value,
        SUM(sales) AS total_sales,
        ROUND(SUM(sales * sell_price), 2) AS total_revenue
    FROM base
    GROUP BY time_granularity, time_value

    UNION ALL

    SELECT
        'monthly' AS time_granularity,
        month_str AS time_value,
        SUM(sales) AS total_sales,
        ROUND(SUM(sales * sell_price), 2) AS total_revenue
    FROM base
    GROUP BY time_granularity, time_value
)

SELECT *
FROM aggregated
ORDER BY time_granularity, time_value

-- time_granularity: Specifies the time aggregation level for the current row (e.g., daily, weekly, monthly).

-- time_value: The timestamp or date value (stored as a string).

-- total_sales, total_revenue: Key sales performance indicators (KPIs).

-- Benefits:
-- ✔ Flexible time hierarchy – Supports easy scaling (e.g., adding quarters/years).
-- ✔ Optimized for dashboards – Pre-calculated fields (like weekday) improve usability.
-- ✔ Model-compliant – dim_calendar works natively as a slicer/filter, adhering to star schema principles.