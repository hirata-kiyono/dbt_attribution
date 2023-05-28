-- macros/months_from_table.sql

{% macro months_from_table(model_name, date_column) %}
    {% set model_info = load_relation(ref(model_name)) %}

    {% set query %}
        SELECT ARRAY_AGG(DISTINCT CAST(DATE_TRUNC({{date_column}}, MONTH) AS STRING)) as m
        FROM `{{model_info.schema}}`.`{{ model_info.identifier}}`
    {% endset %}

    {% set result = run_query(query) %}
{% endmacro %}
