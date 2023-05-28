{% macro month_filter(date_column, month) %}
    WHERE {{date_column}} >= DATE_TRUNC(DATE('{{ month }}'), MONTH)
    AND {{date_column}} < DATE_ADD(DATE_TRUNC(DATE('{{ month }}'), MONTH), INTERVAL 1 MONTH)
{% endmacro %}