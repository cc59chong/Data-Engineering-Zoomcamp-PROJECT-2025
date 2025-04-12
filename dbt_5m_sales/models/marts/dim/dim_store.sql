WITH src AS (
    SELECT * FROM {{ ref('stg_cleaned') }}
)
SELECT DISTINCT
    store_id,
    state_id
FROM src
