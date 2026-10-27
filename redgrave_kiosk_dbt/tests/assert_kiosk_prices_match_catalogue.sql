-- Singular test: a parsed price that differs from the catalogue means a till is misconfigured.
-- severity warn: dbt reports it but does not stop the build.
{{ config(severity='warn') }}
select s.sale_id, s.product_sku, s.unit_price_gbp, p.list_price_gbp
from {{ ref('silver_kiosk_sales') }} s
join {{ ref('kiosk_products') }} p on p.product_sku = s.product_sku
where s.unit_price_gbp <> p.list_price_gbp
