WITH src AS (
    SELECT * FROM {{ ref('stg_cleaned') }}
)
SELECT DISTINCT
    d,
    date,
    EXTRACT(DAYOFWEEK FROM date) AS weekday,
    EXTRACT(DAY FROM date) AS wday,
    EXTRACT(MONTH FROM date) AS month,
    EXTRACT(YEAR FROM date) AS year,
    event_name_1,
    event_type_1,
    event_name_2,
    event_type_2,
    snap_CA,
    snap_TX,
    snap_WI
FROM src
