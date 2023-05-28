SELECT DISTINCT * FROM (
  SELECT
    *
  FROM  
    {{ref('attribution_02_cv_data')}}
  UNION ALL 
  SELECT
    *
  FROM  
    {{ref('attribution_03_non_cv_data')}}
  UNION ALL 
  SELECT
    *
  FROM
    {{ref('attribution_001_offline_cv')}}
  -- オフラインCVの1秒前にカスタムの訪問イベントを追加する
  UNION ALL 
  SELECT  
    event_date,
    DATETIME_ADD(event_datetime, INTERVAL -1 SECOND) as event_datetime,
    customer_id,
    "page_view" as event_name,
    utm_source,
    utm_medium,
    utm_campaign,
    0 as cv_flg,
    0 as cv_volume
  FROM
    {{ref('attribution_001_offline_cv')}}
)