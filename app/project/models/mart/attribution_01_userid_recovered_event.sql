SELECT  
  ev.*,
  master.customer_id
FROM 
  {{ ref('ga4_staging') }} ev 
LEFT OUTER JOIN 
  {{ ref('attribution_00_cookie_master') }} master 
USING(
  user_pseudo_id
)