-- Singular test: every raw row is either clean, quarantined or a duplicate.
-- Nothing may disappear silently. FAILS if a row is lost.
select *
from {{ ref('gold_kiosk_data_quality') }}
where duplicate_rows < 0
