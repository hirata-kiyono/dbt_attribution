SELECT  
  user_pseudo_id,
  -- ここはGA4上にある顧客のIDを入れる
  COALESCE(MAX(hashed_email),MAX(user_pseudo_id)) customer_id
FROM 
  {{ ref('ga4_staging') }}
GROUP BY 1