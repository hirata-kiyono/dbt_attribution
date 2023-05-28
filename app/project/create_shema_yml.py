from google.cloud import bigquery
import yaml
import sys
import datetime
import re

# BigQueryクライアントの初期化
client = bigquery.Client()

# BigQueryテーブルのメタデータを取得してschema.ymlを生成する関数
def generate_schema_yml(
  project_id, 
  dataset_id, 
  table_id, 
  output_file) -> None:

  # ファイル名に.yml, .yamlが入っていないか確認
  if re.match(".*\.ya?ml", output_file):
    sp = output_file.split(".")
    del sp[-1]
    output_file = ".".join(sp)
  output_file = f"{output_file}_{datetime.datetime.now()}.yml"

  # テーブルのフルパスを作成
  table_ref = f"{project_id}.{dataset_id}.{table_id}"

  # テーブルのスキーマを取得
  table = client.get_table(table_ref)
  schema = table.schema

  # schema.ymlのディクショナリを初期化
  schema_dict = {
    "version": 2, 
    "models": []}

  table_dict = {
    "name": table_id,
    "columns": []
  }

  # テーブルの各列に対して、schema.ymlの形式で情報を追加
  for field in schema:
    column_dict = {
      "name": field.name,
      "type": field.field_type,
      "description": field.description if field.description is not None else ""
      # 必要に応じて他の属性を追加
    }

    table_dict["columns"].append(column_dict)

  schema_dict["models"].append(table_dict)
  # schema.ymlファイルを出力
  with open(output_file, "w",encoding="utf-8") as file:
    yaml.dump(schema_dict, file,allow_unicode=True)

  print(f"\n{output_file}\n")

if __name__ == "__main__":
  # BigQueryのプロジェクト、データセット、テーブルを指定してschema.ymlを生成する
  project_id = sys.argv[1]
  dataset_id = sys.argv[2]
  table_id = sys.argv[3]
  generate_schema_yml(project_id, dataset_id, table_id, "tmp_schema")