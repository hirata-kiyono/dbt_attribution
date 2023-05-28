SELECT
    PARSE_DATE("%Y%m%d",cast(_TABLE_SUFFIX as string)) event_date,
    event_timestamp,
    event_name,
    user_pseudo_id,
    event_params
FROM
    {{source('staging', 'events_*')}}
WHERE 0 = 0
  AND _TABLE_SUFFIX not like '%intra%'
