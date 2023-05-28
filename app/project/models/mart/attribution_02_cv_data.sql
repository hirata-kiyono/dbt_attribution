SELECT
  event_date,
  event_datetime,
  customer_id,
  event_name,
  "web" as utm_source,
  "cooperate_site" as utm_medium,
  "お問い合わせ" as  utm_campaign,
  1 as cv_flg,
  1 as cv_volume
FROM 
  {{ ref('attribution_01_userid_recovered_event') }} AS event
WHERE 0=0
  AND event_name = 'get_hashed_email'