SELECT
  node_no,
  include_cv,
  utm_source,
  utm_medium,
  utm_campaign,
  COUNT(1) AS paths
FROM
  {{ref('attribution_06_result')}}
WHERE 0=0
  AND cv_flg = 0
GROUP BY 1,2,3,4,5