SELECT
    order_item_id,
    quantity,
    unit_price,
    line_amount,
    quantity * unit_price AS expected_line_amount

FROM {{ ref('order_items_t') }}

WHERE ABS(
    line_amount - (quantity * unit_price)
) > 0.01