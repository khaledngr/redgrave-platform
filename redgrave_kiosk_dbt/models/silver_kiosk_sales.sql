-- Step 3 · SILVER: valid rows only, one row per sale_id.
select
    s.sale_id,
    s.match_id,
    s.kiosk,
    s.sold_at_utc,
    s.sold_at_utc < dateadd(hour, -6, s._loaded_at)  as is_late_event,
    s.product_sku,
    p.category,
    s.qty,
    s.unit_price_gbp,
    s.qty * s.unit_price_gbp                        as revenue_gbp,
    s.payment,
    s.customer_email_hash,
    s._batch,
    s._loaded_at
from {{ ref('stg_kiosk_sales') }} s
join {{ ref('kiosk_products') }} p on p.product_sku = s.product_sku
where s.sale_id is not null
  and s.sold_at_utc is not null
  and s.sold_at_utc <= dateadd(minute, 5, sysdate())
  and s.qty between 1 and 20
  and s.unit_price_gbp is not null
-- the till retried after a timeout: same sale sent twice -> keep the first one received
qualify row_number() over (partition by s.sale_id order by s._loaded_at) = 1
