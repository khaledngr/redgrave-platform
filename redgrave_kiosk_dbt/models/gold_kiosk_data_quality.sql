-- Gold: one row per batch. How bad is the feed, and is it getting better?
with raw_rows as (
    select _batch, count(*) as raw_rows
    from {{ ref('stg_kiosk_sales') }}
    group by _batch
),
rejected as (
    select _batch, count(*) as rejected_rows
    from {{ ref('kiosk_quarantine') }}
    group by _batch
),
kept as (
    select _batch, count(*) as clean_rows
    from {{ ref('silver_kiosk_sales') }}
    group by _batch
)
select
    r._batch,
    r.raw_rows,
    coalesce(q.rejected_rows, 0)                                      as rejected_rows,
    coalesce(k.clean_rows, 0)                                         as clean_rows,
    r.raw_rows - coalesce(q.rejected_rows, 0) - coalesce(k.clean_rows, 0) as duplicate_rows,
    round(100 * coalesce(k.clean_rows, 0) / r.raw_rows, 1)            as pct_usable
from raw_rows r
left join rejected q on q._batch = r._batch
left join kept     k on k._batch = r._batch
