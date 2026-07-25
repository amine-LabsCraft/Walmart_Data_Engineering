{% macro drop_dbt_schema() %}

    {% set drop_query %}
        DROP SCHEMA IF EXISTS walmart.dbt_schema CASCADE
    {% endset %}

    {% do run_query(drop_query) %}

    {{ log("Schema walmart.dbt_schema supprimé avec succès.", info=True) }}

{% endmacro %}

