SELECT  
  landing_source,
  landing_medium,
  landing_campaign,
  utm_source,
  utm_medium,
  utm_campaign,
  last_source,
  last_medium,
  last_campaign,
  COUNT(1) paths,
  SUM(include_cv) as cv_paths,
  COUNT(DISTINCT session_id) sessions,
  COUNT(DISTINCT if(include_cv=1,session_id,NULL)) cv_sessions,
  AVG(DATETIME_DIFF(last_time,landing_time, DAY)) path_days,
  AVG(IF(include_cv=1,DATETIME_DIFF(last_time,landing_time, DAY),NULL)) cv_path_days,
FROM
  {{ref('attribution_06_result')}}
WHERE 0=0
  AND cv_flg = 0
GROUP BY 1,2,3,4,5,6,7,8,9

