WITH src AS (
    SELECT * FROM {{ ref('stg_cleaned') }}
)
SELECT DISTINCT
    item_id,
    store_id,
    wm_yr_wk,
    SAFE_CAST(sell_price AS FLOAT64) AS sell_price
FROM src
