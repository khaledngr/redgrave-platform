-- Step 2 · QUARANTINE: rows we cannot trust, with the first reason found.
-- They are kept (never deleted) so the kiosk team can fix the tills.
with checked as (
    select
        s.*,
        case
            when s.sale_id is null                                  then 'missing_sale_id'
            when s.sold_at_utc is null                              then 'unparseable_timestamp'
            when s.sold_at_utc > dateadd(minute, 5, sysdate())      then 'future_timestamp'
            when p.product_sku is null                              then 'unknown_product'
            when s.qty is null or s.qty not between 1 and 20        then 'invalid_quantity'
            when s.unit_price_gbp is null                           then 'invalid_price'
        end as reject_reason
    from {{ ref('stg_kiosk_sales') }} s
    left join {{ ref('kiosk_products') }} p on p.product_sku = s.product_sku
)

select * from checked
where reject_reason is not null
