{% test line_amount_consistency(
    model,
    quantity_column,
    unit_price_column,
    line_amount_column,
    tolerance=0.01
) %}

    SELECT
        *
    FROM {{ model }}
    WHERE {{ quantity_column }} IS NOT NULL
      AND {{ unit_price_column }} IS NOT NULL
      AND {{ line_amount_column }} IS NOT NULL
      AND ABS(
          {{ line_amount_column }}
          - ({{ quantity_column }} * {{ unit_price_column }})
      ) > {{ tolerance }}

{% endtest %}
