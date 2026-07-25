{% test processed_after_update(model, updated_column, processed_column) %}

    SELECT
        *
    FROM {{ model }}
    WHERE {{ updated_column }} IS NOT NULL
      AND {{ processed_column }} IS NOT NULL
      AND {{ processed_column }} < {{ updated_column }}

{% endtest %}
