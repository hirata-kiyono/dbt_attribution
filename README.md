## DBTを使ったGA4アトリビューション


### 初期

#### 一般的な立ち上げ方
1. .env作成
1. app/project/.secret/secret.jsonにサービスアカウントキーを配置
1. `docker-compose up`
1. `docker exec -it dbt_ga4 bash`
1. クエリ内のオフラインCVなど調整
1. `dbt run`
1. `dbt docs generate`
1. `dbt docs serve`


#### オフラインCVデータの設定
1. app/project/models/source.ymlにてオフラインコンバージョンデータを設定
1. app/project/models/mart/attribution_001_offline_cv.sqlにて適切な形に整形

#### オンラインCVデータ
1. app/project/models/mart/attribution_02_cv_data.sqlにてオンラインCVを定義

#### インプレッション有効期間、クリック有効期間の設定
1. app/project/models/mart/attribution_051_sessionalize_7d_click.sqlにて記載しているrangeを変更することでコンバージョンに寄与したクリックを制限できる。
```attribution_051_sessionalize_7d_click.sql
    if(
      SUM(cv_flg)OVER(
        PARTITION BY customer_id 
        ORDER BY UNIX_DATE(event_date) 
        RANGE BETWEEN CURRENT ROW AND 7 FOLLOWING)
      >1,
      1,0)as is_new_time_session,
```