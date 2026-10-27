-- Silver: one row per order line, enriched with the order and the product.
-- TODO (step 3.2): replace the three ____ , then run:  dbt run --select silver_order_lines
-- Notice: bronze tables are read with source(), silver models with ref().
select
    i.order_id,
    i.line_no,
    o.order_date,
    o.channel,
    o.status,
    p.product_id,
    p.sku,
    p.category,
    i.qty,
    i.unit_price_gbp,
    i.qty * i.unit_price_gbp        as line_revenue_gbp
from {{ source('bronze', 'order_items') }} i
join {{ ref('silver_orders') }}   o on o.order_id   = i.order_id
join {{ ref('silver_products') }} p on p.product_id = i.product_id
