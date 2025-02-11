{% macro test_expect_compound_columns_to_be_unique(model,
                                                    column_list,
                                                    quote_columns=False,
                                                    ignore_row_if="all_values_are_missing",
                                                    row_condition=None
                                                    ) %}

{% if not quote_columns %}
    {%- set columns=column_list %}
{% elif quote_columns %}
    {%- set columns=[] %}
        {% for column in column_list -%}
            {% set columns = columns.append( adapter.quote(column) ) %}
        {%- endfor %}
{% else %}
    {{ exceptions.raise_compiler_error(
        "`quote_columns` argument for expect_compound_columns_to_be_unique test must be one of [True, False] Got: '" ~ quote_columns ~"'.'"
    ) }}
{% endif %}

{% set row_condition_ext %}

{% if row_condition  %}
    {{ row_condition }} and
{% endif %}

{% if ignore_row_if == "all_values_are_missing" %}
    (
        {% for column in columns -%}
        {{ column }} is not null{% if not loop.last %} and {% endif %}
        {%- endfor %}
    )
{% elif ignore_row_if == "any_value_is_missing" %}
    (
        {% for column in columns -%}
        {{ column }} is not null{% if not loop.last %} or {% endif %}
        {%- endfor %}
    )
{% endif %}
{% endset %}

with validation_errors as (

    select
        {% for column in columns -%}
        {{ column }}{% if not loop.last %},{% endif %}
        {%- endfor %}
    from {{ model }}
    where 1=1
    {% if row_condition %}
        and {{ row_condition }}
    {% endif %}
    group by
        {% for column in columns -%}
        {{ column }}{% if not loop.last %},{% endif %}
        {%- endfor %}
    having count(*) > 1

)
select count(*) from validation_errors
{% endmacro %}



