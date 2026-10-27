-- Step 2 · QUARANTINE: rows we cannot trust, with the first reason found.
-- They are kept (never deleted) so the kiosk team can fix the tills.
with checked as (
    select
        s.*,
        case
            when s.sale_id is null                                  then 'missing_sale_id'
            when s.sold_at_utc is null                              then 'unparseable_timestamp'
            when s.sold_at_utc > dateadd(minute, 5, sysdate())      then 'future_timestamp'
            when ____                                               then 'unknown_product'    -- TODO (5.1): sku not found in the catalogue
            when ____                                               then 'invalid_quantity'   -- TODO (5.1): null, or not between 1 and 20
            when s.unit_price_gbp is null                           then 'invalid_price'
        end as reject_reason
    from {{ ref('stg_kiosk_sales') }} s
    left join {{ ref('kiosk_products') }} p on p.product_sku = s.product_sku
)

select * from checked
where reject_reason is not null
