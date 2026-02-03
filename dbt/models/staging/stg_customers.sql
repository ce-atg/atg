select
    customer_id,
    first_name,
    last_name,
    email,
    city,
    state,
    country,
    created_at,
    updated_at
from atg.public.customers
qualify row_number() over (
    partition by customer_id
    order by updated_at desc
) = 1;
