{% test valid_timestamp_order(model, created_column, updated_column) %}

    SELECT
        *
    FROM {{ model }}
    WHERE {{ created_column }} IS NOT NULL
      AND {{ updated_column }} IS NOT NULL
      AND {{ updated_column }} < {{ created_column }}

{% endtest %}
