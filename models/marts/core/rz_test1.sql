{{
    config(
        materialized = 'table',
        transient=false
    )
}}

select name as cust_name, * from raw.dbt_qzhao7.dim_customers