-- macros/generate_schema_name.sql
-- https://docs.getdbt.com/docs/build/custom-schemas?version=2.0&name=Fusion

{% macro generate_schema_name(custom_schema_name, node) %}

    {% if custom_schema_name is none %}
        {{ target.schema }}
    {% else %}
        {{ custom_schema_name }}
    {% endif %}

{% endmacro %}