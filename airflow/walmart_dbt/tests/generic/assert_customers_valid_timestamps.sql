SELECT *
FROM {{ ref('customers_t') }}
WHERE updated_timestamp < created_timestamp