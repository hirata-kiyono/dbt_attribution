{{config(
  materialized = 'table',
  partition_by={'field': 'report_month', 'data_type': 'DATE'}
)}}


{% if execute %}
{% set model_info = load_relation(ref('attribution_04_base')) %}
{% set query %}
    SELECT DISTINCT CAST(DATE_TRUNC(event_date, MONTH) AS STRING) as m
    FROM `{{model_info.schema}}`.`{{ model_info.identifier}}`
{% endset %}

{% set result = run_query(query) %}
{% set months = result.rows %}

{% for month in months %}
SELECT * FROM (
WITH cv_change_session as (
  SELECT 
    *,
    IF(LAG(cv_flg)OVER(PARTITION BY customer_id ORDER BY event_datetime)=1,1,0) AS is_new_session
  FROM
    `{{model_info.schema}}`.`{{ model_info.identifier}}`
    {{ month_filter('event_date',month.m) }}
)

,add_session_id as (
  SELECT  
    * except(is_new_session),
  SUM(is_new_session)OVER(partition by customer_id ORDER BY event_datetime ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as cust_session_id,
  FROM 
    cv_change_session
)
, agg as (
  SELECT 
    * except(cv_volume),
    SUM(cv_flg)over(partition by customer_id, cust_session_id) include_cv,
    ROW_NUMBER()OVER(PARTITION BY customer_id, cust_session_id ORDER BY event_datetime) node_no,
    ROW_NUMBER()OVER(PARTITION BY customer_id, cust_session_id ORDER BY event_datetime DESC) node_no_desc,
    LAST_VALUE(utm_source)OVER(PARTITION BY customer_id, cust_session_id, cv_flg ORDER BY event_datetime DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) landing_source,
    LAST_VALUE(utm_medium)OVER(PARTITION BY customer_id, cust_session_id, cv_flg ORDER BY event_datetime DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) landing_medium,
    LAST_VALUE(utm_campaign)OVER(PARTITION BY customer_id, cust_session_id, cv_flg ORDER BY event_datetime DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) landing_campaign,
    if(cv_flg=1,
      LAG(utm_source)OVER(PARTITION BY customer_id, cust_session_id order by event_datetime),
      LAST_VALUE(utm_source)OVER(PARTITION BY customer_id, cust_session_id, cv_flg ORDER BY event_datetime ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)) last_source,
    if(cv_flg=1,
      LAG(utm_medium)OVER(PARTITION BY customer_id, cust_session_id order by event_datetime),
      LAST_VALUE(utm_medium)OVER(PARTITION BY customer_id, cust_session_id, cv_flg ORDER BY event_datetime ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)) last_medium,
    if(cv_flg=1,
      LAG(utm_campaign)OVER(PARTITION BY customer_id, cust_session_id order by event_datetime),
      LAST_VALUE(utm_campaign)OVER(PARTITION BY customer_id, cust_session_id, cv_flg ORDER BY event_datetime ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)) last_campaign,
    CONCAT(customer_id, "#", cust_session_id) as session_id,
    COUNT(1)OVER(PARTITION BY customer_id, cust_session_id) as path_length,
    MIN(event_datetime)OVER(PARTITION BY customer_id, cust_session_id) as landing_time,
    if(cv_flg=1,
      LAG(event_datetime)OVER(PARTITION BY customer_id, cust_session_id order by event_datetime),
      MAX(event_datetime)OVER(PARTITION BY customer_id, cust_session_id, cv_flg ORDER BY event_datetime ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)) as last_time,
    MAX(event_datetime)OVER(PARTITION BY customer_id, cust_session_id) as cv_time,
    if(SUM(cv_flg)over(partition by customer_id, cust_session_id) = 1,
      last_value(utm_source)OVER(PARTITION BY customer_id, cust_session_id ORDER BY event_datetime ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
      "未CV" 
    ) as cv_event_source,
    if(SUM(cv_flg)over(partition by customer_id, cust_session_id) = 1,
      last_value(utm_medium)OVER(PARTITION BY customer_id, cust_session_id ORDER BY event_datetime ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
      "未CV" 
    ) as cv_event_medium,
    if(SUM(cv_flg)over(partition by customer_id, cust_session_id) = 1,
      last_value(utm_campaign)OVER(PARTITION BY customer_id, cust_session_id ORDER BY event_datetime ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
      "未CV" 
    ) as cv_event_campaign,
    SUM(cv_volume)OVER(PARTITION BY customer_id, cust_session_id) as cv_volume
  FROM
    add_session_id
)
SELECT
  DATE('{{month.m}}') as report_month,
  *,
  if(include_cv = 1 and node_no=1,1,0) as landing_score,
  if(include_cv = 1 and node_no_desc=2,1,0) as last_score,
  if(include_cv = 1 and cv_flg=0 ,1/(path_length-1),0) as equal_score,
  if(include_cv = 1 and cv_flg=0 ,node_no/(1/2*path_length*(path_length-1)),0) as linear_score,
FROM
  agg
)
{% if not loop.last %} UNION ALL {% endif %}
{% endfor %}

{% endif %}
{% if not execute %}
SELECT 1 FROM {{ref('attribution_04_base')}}
{% endif %}