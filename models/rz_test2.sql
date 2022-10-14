{{
    config(
        materialized = 'table',
        transient=false
    )
}}
select * from raw.dbt_qzhao7.rz_test1