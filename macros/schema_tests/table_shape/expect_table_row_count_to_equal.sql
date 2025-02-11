{%- macro test_expect_table_row_count_to_equal(model,
                                                value,
                                                group_by=None,
                                                row_condition=None
                                                ) -%}
    {{ adapter.dispatch('test_expect_table_row_count_to_equal',
                        packages=dbt_expectations._get_namespaces()) (model,
                                                                        value,
                                                                        group_by,
                                                                        row_condition
                                                                        ) }}
{% endmacro %}



{%- macro default__test_expect_table_row_count_to_equal(model,
                                                value,
                                                group_by,
                                                row_condition
                                                ) -%}
{% set expression %}
count(*) = {{ value }}
{% endset %}
{{ dbt_expectations.expression_is_true(model,
                                        expression=expression,
                                        group_by_columns=group_by,
                                        row_condition=row_condition)
                                        }}
{%- endmacro -%}
