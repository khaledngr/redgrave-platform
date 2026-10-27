-- Silver: clean orders. One row per order_id.
-- TODO (step 4.2): replace the two ____ , then run:  dbt run --select silver_orders
select
    order_id,
    upper(trim(customer_ref))       as customer_ref,
    ____(trim(channel))             as channel,        -- TODO: lower-case the channel (function LOWER)
    lower(trim(status))             as status,
    order_ts,
    ____(order_ts)                  as order_date,     -- TODO: keep only the date part (function TO_DATE)
    updated_at
from {{ source('bronze', 'orders') }}
qualify row_number() over (partition by order_id order by _loaded_at desc, updated_at desc) = 1
