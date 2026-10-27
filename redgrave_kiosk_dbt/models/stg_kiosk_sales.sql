-- Step 1 · PARSE every raw row into typed columns. Nothing is filtered yet.
-- Each line fixes one defect of the feed (see the comment on the right).
with source as (
    select raw, _batch, _loaded_at
    from {{ source('kiosk', 'kiosk_sales_raw') }}
),

parsed as (
    select
        raw:sale_id::string                                         as sale_id,
        raw:match_id::string                                        as match_id,

        -- "north stand ", "NORTH-STAND", "N. Stand" -> first letter is enough
        case left(upper(trim(raw:kiosk::string)), 1)
            when 'N' then 'North Stand'
            -- TODO (step 4.1): add the three other kiosks: South Stand, East Stand, Family Zone
        end                                                         as kiosk,

        -- 3 formats: ISO with offset, "26/10/2026 15:04" (UTC), epoch milliseconds
        case
            when typeof(raw:sold_at) = 'INTEGER'
                then to_timestamp_ntz(try_to_number(raw:sold_at::string), 3)
            else coalesce(
                convert_timezone('UTC', try_to_timestamp_tz(raw:sold_at::string))::timestamp_ntz,
                try_to_timestamp_ntz(raw:sold_at::string, '____'))   -- TODO (4.2): format of "26/10/2026 15:04"
        end                                                         as sold_at_utc,

        nullif(upper(trim(raw:product_sku::string)), '')            as product_sku,   -- "rdg-mug" -> "RDG-MUG"
        try_to_number(trim(raw:qty::string))                        as qty,           -- "two" -> null, "1 " -> 1

        -- schema drift: some tills send unitPrice instead of unit_price
        coalesce(raw:unit_price, ____)                              as unit_price_raw,   -- TODO (4.3): the drifted field name
        -- "£4.50" -> 4.50, "4,50" -> 4.50
        try_to_decimal(replace(replace(unit_price_raw::string, '£', ''), ',', '.'), 10, 2) as price_number,
        -- nothing at a kiosk costs 100 pounds: 100 or more means the till sent pence (450 -> 4.50)
        iff(price_number >= 100, price_number / 100, price_number)  as unit_price_gbp,

        case
            when lower(trim(raw:payment::string)) in ('card', 'cash', 'contactless')
                then lower(trim(raw:payment::string))
            -- TODO (4.4): 'apple pay' is a contactless payment: map it
            else 'unknown'
        end                                                         as payment,

        -- personal data: keep only a hash of valid e-mails, never the address
        case when raw:customer_email::string rlike '^[^@ ]+@[^@ ]+\\.[a-z]+$'
             then sha2(lower(raw:customer_email::string)) end       as customer_email_hash,

        raw:promo_code::string                                      as promo_code,
        _batch,
        _loaded_at
    from source
)

select * from parsed
