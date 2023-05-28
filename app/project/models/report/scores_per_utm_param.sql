SELECT
  CASE 
    WHEN LOWER(utm_source) like "%google%" THEN "Google"
    WHEN LOWER(utm_source) like "%facebook%" THEN "Facebook"
    WHEN LOWER(utm_source) like "%teams%" THEN "Microsoft"
    WHEN LOWER(utm_source) like "%bing%" THEN "Microsoft"
    WHEN LOWER(utm_source) like "%sansan%" THEN "Sansan"
    WHEN LOWER(utm_source) like "%rakuten%" THEN "Rakuten"
    WHEN LOWER(utm_source) =    "t.co" THEN "Twitter"
    WHEN LOWER(utm_source) like "%yahoo%" THEN "Yahoo"
    WHEN LOWER(utm_source) like "%spotify%" THEN "Spotify"
    WHEN LOWER(utm_source) like "%shopify%" THEN "Shopify"
    WHEN utm_source        like "%Shopify%" THEN "Shopify"
    WHEN LOWER(utm_source) like "%lightning.force.com" THEN REGEXP_EXTRACT(utm_source,r'^([^.]+)')
    WHEN LOWER(utm_source) like "%.cybozu.com" THEN REGEXP_EXTRACT(utm_source,r'^([^.]+)')
    ELSE utm_source END AS utm_source,
  utm_medium,
  utm_campaign,
  SUM(landing_score * cv_volume) landing_score,
  SUM(last_score * cv_volume) last_score,
  SUM(linear_score * cv_volume) linear_score,
FROM
  {{ref('attribution_06_result')}}
WHERE 0=0
  AND cv_flg = 0
GROUP BY 1,2,3