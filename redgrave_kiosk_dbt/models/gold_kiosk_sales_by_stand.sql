-- Gold: what the commercial director looks at during the match.
select
    kiosk,
    category,
    count(*)                    as sales,
    sum(qty)                    as items,
    sum(revenue_gbp)            as revenue_gbp
from {{ ref('silver_kiosk_sales') }}
group by kiosk, category
