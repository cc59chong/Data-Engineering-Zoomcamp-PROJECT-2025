WITH src AS (
    SELECT * FROM {{ ref('stg_cleaned') }}
)
SELECT DISTINCT
    item_id,
    dept_id,
    cat_id
FROM src
