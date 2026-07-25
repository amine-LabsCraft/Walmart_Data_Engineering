{{
    config(
        materialized = 'incremental',
        unique_key = 'customer_id',
        incremental_strategy = 'merge'
    )
}}

SELECT
    source_data.*,
    current_timestamp() AS processed_at

FROM {{ source('walmart_databricks', 'customers') }} AS source_data

{% if is_incremental() %}
WHERE source_data.updated_timestamp >= (
    SELECT COALESCE(
        MAX(target_data.updated_timestamp),
        CAST('1900-01-01' AS TIMESTAMP)
    )
    FROM {{ this }} AS target_data
)
{% endif %}