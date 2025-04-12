{{ config(
    materialized='table',
    partition_by={'field': 'date', 'data_type': 'date'},
    cluster_by=['item_id', 'store_id']
) }}

SELECT DISTINCT
  date,
  item_id,
  store_id,
  sales,
  CAST(sell_price AS FLOAT64) AS sell_price,
  wm_yr_wk,
  d
FROM {{ ref('stg_cleaned') }}

