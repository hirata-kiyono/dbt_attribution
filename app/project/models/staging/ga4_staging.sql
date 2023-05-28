SELECT
    event_date,
    DATETIME(FORMAT_TIMESTAMP("%Y-%m-%d %H:%M:%S", TIMESTAMP_MICROS(event_timestamp), "Asia/Tokyo")) event_datetime,
    event_name,
    user_pseudo_id,
    (select as struct
       any_value(case when key = 'ga_session_id' then value.int_value end)          ga_session_id
      ,any_value(case when key = 'page_referrer' then value.string_value end)       page_referrer
      ,any_value(case when key = 'page_title' then value.string_value end)          page_title
      ,any_value(case when key = 'session_engaged' then value.string_value end)     session_engaged
      ,any_value(case when key = 'ga_session_number' then value.int_value end)      ga_session_number
      ,any_value(case when key = 'medium' then value.string_value end)              utm_medium
      ,any_value(case when key = 'source' then value.string_value end)              utm_source
      ,any_value(case when key = 'campaign' then value.string_value end)            utm_campaign
      ,any_value(case when key = 'term' then value.string_value end)                utm_term
      ,any_value(case when key = 'page_type' then value.string_value end)           page_type
      ,any_value(case when key = 'page_location' then value.string_value end)       page_location
      ,any_value(case when key = 'ip_address' then value.string_value end)          ip_address
      ,any_value(case when key = 'optimize_id' then value.string_value end)         optimize_id
      ,any_value(case when key = 'percent_scrolled' then value.float_value end)     percent_scrolled
      ,any_value(case when key = 'experiment_id' then value.string_value end)       experiment_id
      ,any_value(case when key = 'hashed_email' then value.string_value end)        hashed_email
    from unnest(event_params)
    ).*,
from {{ ref('ga4_view') }}
