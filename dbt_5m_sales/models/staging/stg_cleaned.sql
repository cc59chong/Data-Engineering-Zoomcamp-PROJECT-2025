SELECT *
FROM {{ source('m5_sales_data', 'cleaned_parquet_external') }}
WHERE date >= '2016-01-01'
