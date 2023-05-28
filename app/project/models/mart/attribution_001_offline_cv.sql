SELECT
  event_date,
  DATETIME_ADD(DATETIME_ADD(CAST(event_date as DATETIME), INTERVAL 1 DAY), INTERVAL -1 SECOND) as event_datetime,
  TO_HEX(SHA256(email)) as customer_id,
  "cv" as event_name,
  utm_source,
  utm_medium,
  utm_campaign,
  1 as cv_flg,
  1 as cv_volume
FROM
  {{ source('devlab','ot_offline_cv') }}
WHERE 0 = 0
  AND event_date IS NOT NULL