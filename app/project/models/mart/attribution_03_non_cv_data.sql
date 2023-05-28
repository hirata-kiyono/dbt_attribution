SELECT
  event_date,
  event_datetime,
  customer_id,
  event_name,
  CASE
    WHEN utm_source IS NULL and page_referrer IS NULL then "direct"
    ELSE utm_source END AS utm_source,
  CASE
    WHEN utm_medium IS NULL and page_referrer IS NULL then "(none)"
    ELSE utm_medium END AS utm_medium,
  CASE
    WHEN utm_campaign IS NULL and page_referrer IS NULL then "(none)"
    ELSE utm_campaign END AS utm_campaign,
  0 as cv_flg,
  0 as cv_volume
FROM 
  {{ ref('attribution_01_userid_recovered_event') }} AS event
WHERE 0=0
  AND event_name = 'page_view'
  AND utm_source IS NOT NULL