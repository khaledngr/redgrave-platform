-- Gold: one row per day, for the chairwoman's daily dashboard.
-- TODO (step 5.2): columns order_date, orders, refunded_orders, paid_revenue_gbp. Expected: 30 rows.
--   Hint: count(distinct case when status = 'refunded' then order_id end)
select 1 as todo_replace_me
