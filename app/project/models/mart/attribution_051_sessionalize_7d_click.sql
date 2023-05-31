-- アトリビューション有効期間無制限
WITH cv_change_session as (
  SELECT 
    *,
    IF(LAG(cv_flg)OVER(PARTITION BY customer_id ORDER BY event_datetime)=1,1,0) AS is_new_session
  FROM
    {{ ref('attribution_04_base') }}
)
, with_time_limit_session as (
  SELECT
    *,
    if(
      SUM(cv_flg)OVER(
        PARTITION BY customer_id 
        ORDER BY UNIX_DATE(event_date) 
        RANGE BETWEEN CURRENT ROW AND 7 FOLLOWING)
      >1,
      1,0)as is_new_time_session,
  FROM
    cv_change_session
)
SELECT
  * except(is_new_session,is_new_time_session),
  CASE
    WHEN LAG(cv_flg)OVER(PARTITION BY customer_id ORDER BY event_datetime)=1 then 1
    ELSE is_new_time_session END
     AS is_new_session
FROM
  with_time_limit_session