## DBTを使ったGA4アトルビューション


### 初期

#### 一般的な立ち上げ方
1. .env作成
1. .secret/secret.jsonにサービスアカウントキーを配置
1. `docker-compose up`
1. `docker exec -it dbt_ga4 bash`
1. `dbt init`
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
1. app/project/models/mart/attribution_051_sessionalize_7d_click.sqlにて