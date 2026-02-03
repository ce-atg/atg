-- Example 1: Detect duplicate customer records by business key
select
    customer_id,
    count(*) as row_count
from atg.public.customers
group by customer_id
having count(*) > 1;


-- Example 2: Check for critical nulls in orders
select *
from atg.public.orders
where order_id is null
   or customer_id is null
   or product_id is null
   or order_date is null;


-- Example 3: Identify late-arriving or updated records
-- Records updated after their original creation date
select *
from atg.public.customers
where updated_at > created_at
  and updated_at >= dateadd(day, -7, current_timestamp);
