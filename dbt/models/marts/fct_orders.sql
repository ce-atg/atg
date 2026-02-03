select
    o.order_id,
    o.order_date,
    o.status,

    -- foreign keys
    o.customer_id,
    o.product_id,

    -- measures
    o.quantity,
    o.total_amount

from {{ ref('stg_orders') }} o

